import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../services/database_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/price_calculation_service.dart';
import '../services/authentication_service.dart';
import '../services/validation_service.dart';
import '../services/error_handling_service.dart';
import '../repositories/pin_repository.dart';
import '../repositories/language_repository.dart';
import '../repositories/discount_preset_repository.dart';
import '../repositories/calculation_record_repository.dart';
import '../core/architecture/clean_architecture_provider.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  // Database Service
  getIt.registerLazySingleton<DatabaseService>(() => HiveDatabaseService());
  
  // Repositories
  getIt.registerLazySingleton<PinRepository>(() => HivePinRepository(getIt<DatabaseService>()));
  getIt.registerLazySingleton<LanguageRepository>(() => HiveLanguageRepository(getIt<DatabaseService>()));
  getIt.registerLazySingleton<DiscountPresetRepository>(() => HiveDiscountPresetRepository(getIt<DatabaseService>()));
  getIt.registerLazySingleton<CalculationRecordRepository>(() => HiveCalculationRecordRepository(getIt<DatabaseService>()));
  
  // Business Services
  getIt.registerLazySingleton<ExchangeRateService>(() => WebExchangeRateService());
  getIt.registerLazySingleton<PriceCalculationService>(() => StandardPriceCalculationService());
  getIt.registerLazySingleton<AuthenticationService>(() => PinAuthenticationService(getIt<PinRepository>()));
  getIt.registerLazySingleton<ValidationService>(() => StandardValidationService());
  getIt.registerLazySingleton<ErrorHandlingService>(() => StandardErrorHandlingService());
  
  // Clean Architecture Provider
  getIt.registerLazySingleton<CleanArchitectureProvider>(() => CleanArchitectureProvider());
  
  // Initialize database
  await getIt<DatabaseService>().initDatabase();
}