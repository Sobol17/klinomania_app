import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/core/storage/preferences_storage.dart';
import '../src/core/theme/app_theme.dart';
import '../src/features/auth/data/datasources/auth_local_data_source.dart';
import '../src/features/auth/data/datasources/auth_remote_data_source.dart';
import '../src/features/auth/data/repositories/auth_repository_impl.dart';
import '../src/features/auth/domain/repositories/auth_repository.dart';
import '../src/features/auth/presentation/controllers/auth_controller.dart';
import '../src/features/auth/presentation/pages/auth_page.dart';
import '../src/features/home/presentation/controllers/home_controller.dart';
import '../src/features/orders/data/datasources/cleaner_order_history_remote_data_source.dart';
import '../src/features/orders/data/datasources/cleaner_orders_remote_data_source.dart';
import '../src/features/orders/data/datasources/order_history_remote_data_source.dart';
import '../src/features/orders/data/repositories/cleaner_order_history_repository_impl.dart';
import '../src/features/orders/data/repositories/cleaner_orders_repository_impl.dart';
import '../src/features/orders/data/repositories/order_history_repository_impl.dart';
import '../src/features/orders/domain/repositories/cleaner_order_history_repository.dart';
import '../src/features/orders/domain/repositories/cleaner_orders_repository.dart';
import '../src/features/orders/domain/repositories/order_history_repository.dart';
import '../src/features/orders/presentation/controllers/cleaner_order_history_controller.dart';
import '../src/features/orders/presentation/controllers/cleaner_orders_controller.dart';
import '../src/features/orders/presentation/controllers/order_history_controller.dart';
import '../src/features/profile/presentation/controllers/profile_controller.dart';
import '../src/features/profile/data/datasources/profile_remote_data_source.dart';
import '../src/features/profile/data/repositories/profile_repository_impl.dart';
import '../src/features/profile/domain/repositories/profile_repository.dart';
import '../src/features/services/data/datasources/services_remote_data_source.dart';
import '../src/features/services/data/repositories/services_repository_impl.dart';
import '../src/features/services/domain/repositories/services_repository.dart';
import '../src/features/services/presentation/controllers/services_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.preferencesStorage,
    required this.useApi,
  });

  final PreferencesStorage preferencesStorage;
  final bool useApi;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesStorage>.value(value: preferencesStorage),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(),
            localDataSource: AuthLocalDataSource(preferencesStorage),
          ),
        ),
        Provider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(
            remoteDataSource: ProfileRemoteDataSource(),
          ),
        ),
        Provider<ServicesRepository>(
          create: (_) => ServicesRepositoryImpl(
            remoteDataSource: ServicesRemoteDataSource(),
          ),
        ),
        Provider<OrderHistoryRepository>(
          create: (_) => OrderHistoryRepositoryImpl(
            remoteDataSource: OrderHistoryRemoteDataSource(),
          ),
        ),
        Provider<CleanerOrderHistoryRepository>(
          create: (_) => CleanerOrderHistoryRepositoryImpl(
            remoteDataSource: CleanerOrderHistoryRemoteDataSource(),
          ),
        ),
        Provider<CleanerOrdersRepository>(
          create: (_) => CleanerOrdersRepositoryImpl(
            remoteDataSource: CleanerOrdersRemoteDataSource(),
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            repository: context.read<AuthRepository>(),
            useApi: useApi,
          )..restoreSession(),
        ),
        ChangeNotifierProvider<HomeController>(create: (_) => HomeController()),
        ChangeNotifierProvider<OrderHistoryController>(
          create: (context) => OrderHistoryController(
            repository: context.read<OrderHistoryRepository>(),
            useApi: useApi,
          ),
        ),
        ChangeNotifierProvider<CleanerOrderHistoryController>(
          create: (context) => CleanerOrderHistoryController(
            repository: context.read<CleanerOrderHistoryRepository>(),
            useApi: useApi,
          ),
        ),
        ChangeNotifierProvider<CleanerOrdersController>(
          create: (context) => CleanerOrdersController(
            repository: context.read<CleanerOrdersRepository>(),
            useApi: useApi,
          ),
        ),
        ChangeNotifierProvider<ProfileController>(
          create: (context) => ProfileController(
            repository: context.read<ProfileRepository>(),
            useApi: useApi,
          ),
        ),
        ChangeNotifierProvider<ServicesController>(
          create: (context) => ServicesController(
            repository: context.read<ServicesRepository>(),
            useApi: useApi,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time2Clean',
        theme: AppTheme.lightTheme,
        home: const AuthPage(),
      ),
    );
  }
}
