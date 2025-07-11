// Core - Base UseCase interface
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {}

// Result wrapper for use cases
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.error(this.error) : data = null, isSuccess = false;
}

// Base failure types
abstract class Failure {
  final String message;
  final String? localizedKey;
  
  Failure(this.message, [this.localizedKey]);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message, [String? localizedKey]) 
      : super(message, localizedKey);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  StorageFailure(String message) : super(message);
}

class CalculationFailure extends Failure {
  CalculationFailure(String message) : super(message);
}