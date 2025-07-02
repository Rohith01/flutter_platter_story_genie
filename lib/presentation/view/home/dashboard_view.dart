import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/snackbar_util.dart';
import 'package:story_genie/presentation/bloc/auth_bloc.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/view/home/editors_choice_stories_list_widget.dart';
import 'package:story_genie/presentation/view/widgets/creative_credits_widget.dart';
import 'package:story_genie/presentation/view/widgets/no_internet_popup.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  TextEditingController searchController = TextEditingController();

  Timer? _debounce;
  final int _debouncetime = 1000;
  @override
  void initState() {
    BlocProvider.of<AuthBloc>(context).add(const IsUserLoggedIn());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is UserLoggedOutState) {
            context.go('/login');
          } else if (authState is AuthVerifiedOldUser ||
              authState is AuthVerifiedNewUser) {
            BlocProvider.of<ManageUserProfileCubit>(context).getUserProfile();
          } else if (authState is AuthNoInternetError) {
            if (context.canPop()) {
              context.pop();
            }
            showNoInternetPopup(context: context);
          }
        },
        builder: (context, authState) {
          return BlocConsumer<ManageUserProfileCubit, ManageUserProfileState>(
            listener: (context, state) {
              if (state is ManageUserProfileError) {
                showSnackBar(
                  context: context,
                  message: 'Something went wrong! Please try again later.',
                  showAction: false,
                );
              }
              if (state is UpdateUserProfileLoaded) {
                BlocProvider.of<ManageUserProfileCubit>(
                  context,
                ).getUserProfile();
              }
              if (state is GetUserProfileLoaded) {
                if (authState is AuthVerifiedNewUser &&
                    state.userProfile.kidsAge == null) {
                  showSnackBar(
                    context: context,
                    message: 'Please update kids age to get customised stories',
                    showAction: true,
                    actionLabel: 'Update',
                    onPressed: () {
                      context.push('/my-profile/edit');
                    },
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is GetUserProfileLoaded) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 30.h,
                    ),
                    child: SizedBox(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(eventName: 'clicked_profile_icon');
                                  context.go(
                                    '/my-profile',
                                    extra: state.userProfile,
                                  );
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(eventName: 'click_home_profile');
                                },
                                child: Hero(
                                  tag: 'profile',
                                  child: CircleAvatar(
                                    backgroundImage: const AssetImage(
                                      'assets/image/avatar.jpg',
                                    ),
                                    radius: 25.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.h),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello,',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${state.userProfile.name}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              CreativeCreditsWidget(
                                credits: state.userProfile.credits ?? '0',
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Container(
                            height: 40.h,
                            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for a story',
                                contentPadding: const EdgeInsets.all(10),
                                border: InputBorder.none,
                                suffixIcon:
                                    (searchController.text.isEmpty)
                                        ? Icon(
                                          Icons.search,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        )
                                        : IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(FocusNode());
                                          },
                                        ),
                              ),
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce?.cancel();
                                }
                                _debounce = Timer(
                                  Duration(milliseconds: _debouncetime),
                                  () {
                                    WidgetsBinding
                                        .instance
                                        .focusManager
                                        .primaryFocus
                                        ?.unfocus();

                                    context.go(
                                      '/search/${searchController.text}',
                                    );
                                    BlocProvider.of<FirebaseAnalyticsCubit>(
                                      context,
                                    ).addEvent(
                                      eventName: 'click_home_search',
                                      eventParams: {
                                        'searchTerm': searchController.text,
                                      },
                                    );
                                    searchController.clear();
                                  },
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                'Stories by character',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  context.go('/stories-list/all');
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(
                                    eventName: 'click_home_story_character',
                                    eventParams: {'character': 'all'},
                                  );
                                },
                                label: Row(
                                  children: [
                                    Text(
                                      'View all',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 140.h,
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(10),
                              itemCount: characters.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    context.go(
                                      '/stories-list/${characters[index].characterName.toLowerCase()}',
                                    );
                                    BlocProvider.of<FirebaseAnalyticsCubit>(
                                      context,
                                    ).addEvent(
                                      eventName: 'click_home_story_character',
                                      eventParams: {
                                        'character':
                                            characters[index].characterName
                                                .toLowerCase(),
                                      },
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 5.0,
                                    child: Hero(
                                      tag: characters[index].characterName,
                                      child: Image.asset(
                                        characters[index].characterImage,
                                        width: 120.h,
                                        height: 120.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Center(
                            child: InkWell(
                              onTap: () {
                                context.go('/generate-story');
                                BlocProvider.of<FirebaseAnalyticsCubit>(
                                  context,
                                ).addEvent(eventName: 'click_home_banner');
                              },
                              child: Container(
                                height: 180.h,
                                width: 340.w,
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  top: 10.h,
                                  right: 20.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Theme.of(context).colorScheme.primary,
                                  image: const DecorationImage(
                                    image: AssetImage('assets/image/cover.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary.withAlpha(100),
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 160.h,
                                      width: 340.w,
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 15.h),
                                            child: Image.asset(
                                              'assets/image/genie_banner.png',
                                              height: 160.h,
                                              width: 150.w,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10.h,
                                            left: 60.w,
                                            child: SizedBox(
                                              height: 80.h,
                                              width: 80.w,
                                              child: Lottie.network(
                                                'https://lottie.host/d5b7b8c9-406a-4f45-9f1c-084da7871c80/IFYfRcYp87.json',
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const SizedBox();
                                                },
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              'Craft your own story with AI',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: RoundedButton(
                                              height: 40.h,
                                              width: 150.w,
                                              isLoading: false,
                                              title: 'Generate Story',
                                              titleTextStyle: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              onTap: () {
                                                context.go('/generate-story');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            'Editors Picks',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const EditorsChoiceStoriesListScreen(),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const Center(child: Text('Loading...'));
            },
          );
        },
      ),
    );
  }
}
