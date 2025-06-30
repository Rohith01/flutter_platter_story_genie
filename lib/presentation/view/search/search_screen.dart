import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/get_stories_list_cubit.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.searchTerm});
  final String searchTerm;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  Timer? _debounce;
  final int _debouncetime = 1000;

  @override
  void initState() {
    searchController.text = widget.searchTerm;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (searchController.text.isNotEmpty) {
      BlocProvider.of<GetStoriesListCubit>(
        context,
      ).searchStories(searchController.text);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210,
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          GoRouter.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      const Spacer(),
                    ],
                  ),
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
                                      Theme.of(context).colorScheme.secondary,
                                )
                                : IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                            BlocProvider.of<GetStoriesListCubit>(
                              context,
                            ).searchStories(searchController.text);
                            BlocProvider.of<FirebaseAnalyticsCubit>(
                              context,
                            ).addEvent(
                              eventName: 'click_search',
                              eventParams: {
                                'searchTerm': searchController.text,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<GetStoriesListCubit, GetStoriesListState>(
                builder: (context, state) {
                  if (state is GetStoriesListLoaded) {
                    if (state.stories.isEmpty) {
                      return SizedBox(
                        height: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'There are no stories here',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 20),
                            RoundedButton(
                              isLoading: false,
                              title: 'Generate Story',
                              width: 200,
                              titleTextStyle: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(color: kPrimary),
                              onTap: () {
                                context.go('/generate-story');
                                BlocProvider.of<FirebaseAnalyticsCubit>(
                                  context,
                                ).addEvent(
                                  eventName:
                                      'click_search_generate_story_button',
                                  eventParams: {
                                    'searchTerm': searchController.text,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.stories.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            BlocProvider.of<FirebaseAnalyticsCubit>(
                              context,
                            ).addEvent(
                              eventName: 'clicked_on_excuse_tile',
                              eventParams: {
                                'excuse_desc': state.stories[index].title,
                              },
                            );
                            context.go('/story', extra: state.stories[index]);
                          },
                          child: Container(
                            height: 75,
                            width: 300,
                            margin: const EdgeInsets.symmetric(vertical: 4),

                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: pastelColorsList[index % 4],
                            ),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Text(state.stories[index].title, maxLines: 2),
                                  Text(
                                    'Click to view details',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorsList[index % 4],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(
                                    eventName: 'click_search_share_button',
                                    eventParams: {
                                      'storyId': state.stories[index].id!,
                                    },
                                  );
                                  Share.share(
                                    '${state.stories[index].story}\nGenerated by AI stories app',
                                  );
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: colorsList[index % 4],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is GetStoriesListLoading) {
                    return Column(
                      children: [
                        Lottie.network(
                          'https://lottie.host/3fa5105b-7bc7-46ae-b0ad-e5e0fdbb1429/S54upxfnli.json',
                          errorBuilder: (context, error, stackTrace) {
                            return const CircularProgressIndicator();
                          },
                        ),
                        Text(
                          'Searching for ${searchController.text}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  } else if (state is GetStoriesListError) {
                    return Column(
                      children: [
                        Text(
                          'Unable Search for ${searchController.text}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
