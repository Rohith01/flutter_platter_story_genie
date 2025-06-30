import 'package:algoliasearch/algoliasearch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/presentation/bloc/add_to_saved_stories_cubit.dart';
import 'package:story_genie/presentation/bloc/auth_bloc.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/firebase_notifications_cubit.dart';
import 'package:story_genie/presentation/bloc/generate_story_cubit.dart';
import 'package:story_genie/presentation/bloc/get_stories_list_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_credits_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/bloc/theme_cubit.dart';
import 'package:story_genie/services/repository/auth_repository.dart';
import 'package:story_genie/services/repository/firebase_analytics_repository.dart';
import 'package:story_genie/services/repository/firebase_db_repository.dart';
import 'package:story_genie/services/repository/generate_story_repository.dart';
import 'package:story_genie/services/repository/search_stories_repository.dart';

// sl - Service locator
final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Register Blocs and Cubits here
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => FCMCubit(sl()));
  sl.registerFactory(() => FirebaseAnalyticsCubit(sl()));
  sl.registerFactory(() => ManageUserProfileCubit(sl()));
  sl.registerFactory(() => ThemeCubit(sl()));
  sl.registerFactory(() => GenerateStoryCubit(sl(), sl()));
  sl.registerFactory(() => GetStoriesListCubit(sl(), sl()));
  sl.registerFactory(() => AddToSavedStoriesCubit(sl()));
  sl.registerFactory(() => ManageCreditsCubit(sl()));

  // Register repositories here
  sl.registerLazySingleton<GenerateStoryRepository>(
    () => GenerateStoryRepositoryImpl(sl(), sl(), sl()),
  );

  // Register services here
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<FirebaseAnalyticsRepository>(
    () => FirebaseAnalyticsRepositoryImpl(
      analytics: sl(),
      deviceInfoPlugin: sl(),
      firebaseAnalyticsObserver: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseDBRepository>(
    () => FirebaseDBRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SearchStoriesRepository>(
    () => SearchStoriesRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  sl.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());
  sl.registerLazySingleton<FirebaseAnalyticsObserver>(
    () => FirebaseAnalyticsObserver(analytics: sl()),
  );
  sl.registerLazySingleton(() => Connectivity());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<SearchClient>(
    () => SearchClient(appId: kAlgoliaAppId, apiKey: kAlgoliApiKey),
  );
}
