import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../services/database_service.dart';
import '../repositories/pin_repository.dart';
import '../repositories/language_repository.dart';
import '../repositories/discount_preset_repository.dart';
import '../repositories/calculation_record_repository.dart';

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
  
  // Initialize database
  await getIt<DatabaseService>().initDatabase();
}