import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/di.dart' as di;
import 'package:story_genie/firebase_options.dart';
import 'package:story_genie/presentation/bloc/add_to_saved_stories_cubit.dart';
import 'package:story_genie/presentation/bloc/auth_bloc.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/firebase_notifications_cubit.dart';
import 'package:story_genie/presentation/bloc/generate_story_cubit.dart';
import 'package:story_genie/presentation/bloc/get_stories_list_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_credits_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/bloc/theme_cubit.dart';
import 'package:story_genie/presentation/view/home/home_screen.dart';
import 'package:story_genie/presentation/view/login/email_login_view.dart';
import 'package:story_genie/presentation/view/login/email_singup_view.dart';
import 'package:story_genie/presentation/view/login/login_view.dart';
import 'package:story_genie/presentation/view/search/search_screen.dart';
import 'package:story_genie/presentation/view/story/generate_story/generate_story_form_view.dart';
import 'package:story_genie/presentation/view/story/generate_story/story_screen.dart';
import 'package:story_genie/presentation/view/story/stories_list_screen/stories_list_screen.dart';
import 'package:story_genie/presentation/view/user_profile/edit_profile_screen.dart';
import 'package:story_genie/presentation/view/user_profile/user_profile_screen.dart';
import 'package:story_genie/services/models/story_model.dart';
import 'package:story_genie/services/models/user_profile_model.dart';
import 'package:story_genie/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
    webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Dependency Injection
  await di.setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GoRouter configuration
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MyHomePage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                return const LoginView();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'email-login',
                  builder: (BuildContext context, GoRouterState state) {
                    return const EmailLoginView();
                  },
                ),
                GoRoute(
                  path: 'email-signup',
                  builder: (BuildContext context, GoRouterState state) {
                    return const EmailSignUpView();
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'generate-story',
              builder: (BuildContext context, GoRouterState state) {
                return const GenerateStoryFormView();
              },
            ),
            GoRoute(
              path: 'stories-list/:character',
              builder: (BuildContext context, GoRouterState state) {
                final character = state.pathParameters['character']!;
                return StoriesListScreen(character: character);
              },
            ),
            GoRoute(
              path: 'story',
              builder: (BuildContext context, GoRouterState state) {
                final AiStory story = state.extra as AiStory;
                return StoryScreen(story: story);
              },
            ),
            GoRoute(
              path: 'my-profile',
              builder: (BuildContext context, GoRouterState state) {
                final UserProfile profile = state.extra as UserProfile;
                return UserProfileScreen(userProfile: profile);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'edit',
                  builder: (BuildContext context, GoRouterState state) {
                    return const EditProfileScreen();
                  },
                ),
              ],
            ),

            GoRoute(
              path: 'search/:searchTerm',
              builder: (BuildContext context, GoRouterState state) {
                final searchTerm = state.pathParameters['searchTerm']!;
                return SearchScreen(searchTerm: searchTerm);
              },
            ),
          ],
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => di.sl<ManageUserProfileCubit>()),
            BlocProvider(create: (context) => di.sl<AuthBloc>()),
            BlocProvider(create: (context) => di.sl<FirebaseAnalyticsCubit>()),
            BlocProvider(create: (context) => di.sl<FCMCubit>()),
            BlocProvider(create: (context) => di.sl<ThemeCubit>()),
            BlocProvider(create: (context) => di.sl<GenerateStoryCubit>()),
            BlocProvider(create: (context) => di.sl<GetStoriesListCubit>()),
            BlocProvider(create: (context) => di.sl<AddToSavedStoriesCubit>()),
            BlocProvider(create: (context) => di.sl<ManageCreditsCubit>()),
          ],
          child: BlocConsumer<ThemeCubit, ThemeState>(
            listener: (context, state) {},
            builder: (context, state) {
              return MaterialApp.router(
                title: 'Story Genie',
                debugShowCheckedModeBanner: false,
                theme:
                    state == const IsDarkTheme(isDarkTheme: false)
                        ? lightTheme
                        : darkTheme,
                routerConfig: router,
              );
            },
          ),
        );
      },
    );
  }
}
