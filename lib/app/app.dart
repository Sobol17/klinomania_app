import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/core/network/api_client.dart';
import '../src/core/storage/preferences_storage.dart';
import '../src/features/auth/data/datasources/auth_local_data_source.dart';
import '../src/features/auth/data/datasources/auth_remote_data_source.dart';
import '../src/features/auth/data/repositories/auth_repository_impl.dart';
import '../src/features/auth/domain/repositories/auth_repository.dart';
import '../src/features/auth/presentation/controllers/auth_controller.dart';
import '../src/features/home/presentation/controllers/home_controller.dart';
import '../src/features/home/data/datasources/home_remote_data_source.dart';
import '../src/features/orders/data/datasources/cleaner_order_history_remote_data_source.dart';
import '../src/features/orders/data/datasources/cleaner_orders_remote_data_source.dart';
import '../src/features/orders/data/datasources/order_history_remote_data_source.dart';
import '../src/features/orders/data/repositories/address_suggestions_repository_impl.dart';
import '../src/features/orders/data/repositories/cleaner_order_history_repository_impl.dart';
import '../src/features/orders/data/repositories/cleaner_orders_repository_impl.dart';
import '../src/features/orders/data/repositories/order_history_repository_impl.dart';
import '../src/features/orders/data/repositories/order_checkout_repository_impl.dart';
import '../src/features/orders/data/datasources/order_checkout_remote_data_source.dart';
import '../src/features/orders/data/services/address_suggest_service.dart';
import '../src/features/orders/domain/repositories/address_suggestions_repository.dart';
import '../src/features/orders/domain/repositories/cleaner_order_history_repository.dart';
import '../src/features/orders/domain/repositories/cleaner_orders_repository.dart';
import '../src/features/orders/domain/repositories/order_history_repository.dart';
import '../src/features/orders/domain/repositories/order_checkout_repository.dart';
import '../src/features/orders/domain/use_cases/fetch_address_suggestions.dart';
import '../src/features/orders/presentation/controllers/cleaner_order_history_controller.dart';
import '../src/features/orders/presentation/controllers/cleaner_orders_controller.dart';
import '../src/features/orders/presentation/controllers/order_history_controller.dart';
import '../src/features/profile/data/datasources/profile_remote_data_source.dart';
import '../src/features/profile/data/repositories/profile_repository_impl.dart';
import '../src/features/profile/domain/repositories/profile_repository.dart';
import '../src/features/profile/presentation/controllers/profile_controller.dart';
import '../src/features/services/data/datasources/services_remote_data_source.dart';
import '../src/features/services/data/repositories/services_repository_impl.dart';
import '../src/features/services/domain/repositories/services_repository.dart';
import '../src/features/services/presentation/controllers/services_controller.dart';
import 'router_host.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.preferencesStorage,
    required this.useApi,
    required this.apiBaseUrl,
  });

  final PreferencesStorage preferencesStorage;
  final bool useApi;
  final String apiBaseUrl;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesStorage>.value(value: preferencesStorage),
        Provider<ApiClient>(create: (_) => ApiClient(baseUrl: apiBaseUrl)),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(
              apiClient: context.read<ApiClient>(),
            ),
            localDataSource: AuthLocalDataSource(preferencesStorage),
          ),
        ),
        Provider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(
            remoteDataSource: ProfileRemoteDataSource(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        Provider<ServicesRepository>(
          create: (context) => ServicesRepositoryImpl(
            remoteDataSource: ServicesRemoteDataSource(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        Provider<OrderHistoryRepository>(
          create: (_) => OrderHistoryRepositoryImpl(
            remoteDataSource: OrderHistoryRemoteDataSource(),
          ),
        ),
        Provider<OrderCheckoutRepository>(
          create: (context) => OrderCheckoutRepositoryImpl(
            remoteDataSource: OrderCheckoutRemoteDataSource(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        Provider<AddressSuggestService>(create: (_) => AddressSuggestService()),
        Provider<AddressSuggestionsRepository>(
          create: (context) => AddressSuggestionsRepositoryImpl(
            service: context.read<AddressSuggestService>(),
          ),
        ),
        Provider<FetchAddressSuggestionsUseCase>(
          create: (context) => FetchAddressSuggestionsUseCase(
            repository: context.read<AddressSuggestionsRepository>(),
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
            apiClient: context.read<ApiClient>(),
            useApi: useApi,
          )..restoreSession(),
        ),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            useApi: useApi,
            remoteDataSource: HomeRemoteDataSource(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
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
          create: (context) =>
              ProfileController(repository: context.read<ProfileRepository>()),
        ),
        ChangeNotifierProvider<ServicesController>(
          create: (context) => ServicesController(
            repository: context.read<ServicesRepository>(),
            useApi: useApi,
          ),
        ),
      ],
      child: const RouterHost(),
    );
  }
}
