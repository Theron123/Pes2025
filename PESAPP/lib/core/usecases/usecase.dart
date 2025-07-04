import '../errors/failures.dart';

/// Result wrapper for use case responses
class Result<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const Result._({
    this.data,
    this.failure,
    required this.isSuccess,
  });

  /// Create a successful result
  factory Result.success(T data) => Result._(
    data: data,
    isSuccess: true,
  );

  /// Create a failure result
  factory Result.failure(Failure failure) => Result._(
    failure: failure,
    isSuccess: false,
  );

  /// Get the data if successful, otherwise null
  T? get value => isSuccess ? data : null;

  /// Get the error if failed, otherwise null
  Failure? get error => isSuccess ? null : failure;
}

/// Base class for all use cases in the hospital system
/// 
/// Use cases represent the business logic of the application.
/// They orchestrate the flow of data to and from entities, and direct
/// those entities to use their business rules to achieve the goals of the use case.
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  /// 
  /// Returns a [Result] containing either success data or failure
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case with no parameters
  /// 
  /// Returns a [Result] containing either success data or failure
  Future<Result<Type>> call();
}

/// Use case that returns a stream
abstract class StreamUseCase<Type, Params> {
  /// Execute the use case with the given parameters
  /// 
  /// Returns a Stream of [Result] containing either success data or failure
  Stream<Result<Type>> call(Params params);
}

/// Use case that returns a stream with no parameters
abstract class NoParamsStreamUseCase<Type> {
  /// Execute the use case with no parameters
  /// 
  /// Returns a Stream of [Result] containing either success data or failure
  Stream<Result<Type>> call();
}

/// Synchronous use case
abstract class SyncUseCase<Type, Params> {
  /// Execute the use case synchronously with the given parameters
  /// 
  /// Returns a [Result] containing either success data or failure
  Result<Type> call(Params params);
}

/// Synchronous use case with no parameters
abstract class NoParamsSyncUseCase<Type> {
  /// Execute the use case synchronously with no parameters
  /// 
  /// Returns a [Result] containing either success data or failure
  Result<Type> call();
}

/// Special class to represent no parameters needed for a use case
class NoParams {
  const NoParams();
  
  @override
  bool operator ==(Object other) => other is NoParams;
  
  @override
  int get hashCode => 0;
} 