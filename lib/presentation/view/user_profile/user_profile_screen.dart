import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/presentation/bloc/auth_bloc.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';
import 'package:story_genie/services/models/user_profile_model.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.userProfile});
  final UserProfile userProfile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Hero(
              tag: 'profile',
              child: CircleAvatar(
                backgroundImage: const AssetImage('assets/image/avatar.jpg'),
                radius: 50.h,
              ),
            ),

            SizedBox(height: 20.h),
            Text(
              '${userProfile.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 5.h),

            InkWell(
              onTap: () {
                context.push('/my-profile/edit', extra: userProfile);
                BlocProvider.of<FirebaseAnalyticsCubit>(
                  context,
                ).addEvent(eventName: 'click_profile_edit');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(width: 5.h),
                  Icon(
                    Icons.edit,
                    size: 10.h,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    context.push('/stories-list/my-stories');
                    BlocProvider.of<FirebaseAnalyticsCubit>(
                      context,
                    ).addEvent(eventName: 'click_profile_my_stories');
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    elevation: 5.0,
                    child: SizedBox(
                      height: 120.h,
                      width: 120.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Hero(
                            tag: 'my-stories',
                            child: Image.asset(
                              'assets/image/my_stories.png',
                              width: 60.h,
                              height: 60.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            'My Stories',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.h),
                InkWell(
                  onTap: () {
                    context.push('/stories-list/saved-stories');
                    BlocProvider.of<FirebaseAnalyticsCubit>(
                      context,
                    ).addEvent(eventName: 'click_profile_saved_stories');
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    elevation: 5.0,

                    child: SizedBox(
                      height: 120.h,
                      width: 120.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Hero(
                            tag: 'saved-stories',
                            child: Image.asset(
                              'assets/image/saved.png',
                              width: 60.h,
                              height: 60.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            'Saved Stories',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return RoundedButton(
                  isLoading: state is AuthLoading,
                  title: 'Logout',
                  titleTextStyle: Theme.of(context).textTheme.bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                  width: 320.w,
                  onTap: () {
                    BlocProvider.of<AuthBloc>(
                      context,
                    ).add(const OnLogOutEvent());
                    BlocProvider.of<FirebaseAnalyticsCubit>(
                      context,
                    ).addEvent(eventName: 'click_profile_logout_button');
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
