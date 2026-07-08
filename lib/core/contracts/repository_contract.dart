/// Universal Repository Contract for Nutrient Earth BIOS.
///
/// Purpose: Define the base interface that all data repositories must implement,
/// enforcing Clean Architecture data access patterns.
///
/// Responsibilities:
/// - Provide generic CRUD interface for all data domains
/// - Enforce consistent error handling patterns
/// - Support pagination and filtering
/// - Enable provider-swappable repository implementations
///
/// Dependencies: core/errors/failures.dart
///
/// Future expansion:
/// - Offline-first sync contract
/// - Conflict resolution hooks
/// - Optimistic update support
/// - Stream-based reactive queries
library;

import '../errors/failures.dart';

/// Base result type wrapping success or failure.
class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(Failure failure) => Result._(failure: failure);

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess) return onSuccess(data as T);
    return onFailure(failure!);
  }
}

/// Abstract pagination descriptor for large dataset queries.
class PaginationParams {
  final int page;
  final int pageSize;
  final String? cursor;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
  });

  int get offset => (page - 1) * pageSize;
}

/// Abstract paginated response container.
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final bool hasNextPage;
  final String? nextCursor;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.hasNextPage,
    this.nextCursor,
  });
}

/// Master repository contract all data access implementations must follow.
abstract class BaseRepository<TEntity, TId> {
  /// Retrieve a single entity by its unique identifier.
  Future<Result<TEntity>> findById(TId id);

  /// Retrieve all entities, optionally paginated.
  Future<Result<PaginatedResult<TEntity>>> findAll({PaginationParams? pagination});

  /// Persist a new entity.
  Future<Result<TEntity>> create(TEntity entity);

  /// Update an existing entity.
  Future<Result<TEntity>> update(TEntity entity);

  /// Soft-delete an entity by ID (preserves audit trail).
  Future<Result<void>> delete(TId id);

  /// Check existence without full fetch.
  Future<Result<bool>> exists(TId id);
}

/// Repository contract for user-scoped entities (per-user data isolation).
abstract class UserScopedRepository<TEntity, TId> extends BaseRepository<TEntity, TId> {
  /// Retrieve all entities belonging to a specific user.
  Future<Result<List<TEntity>>> findByUserId(String userId);

  /// Delete all user data (GDPR compliance).
  Future<Result<void>> deleteAllForUser(String userId);
}
