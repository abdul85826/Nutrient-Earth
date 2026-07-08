/// Core Failures Hierarchy for Nutrient Earth BIOS.
library;

abstract class Failure implements Exception {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
  @override String toString() => '$runtimeType: $message';
}

// Auth
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}
class ProfileNotFoundFailure extends Failure {
  const ProfileNotFoundFailure(super.message, {super.code});
}
class ProfileLoadFailure extends Failure {
  const ProfileLoadFailure(super.message, {super.code});
}
class OnboardingFailure extends Failure {
  const OnboardingFailure(super.message, {super.code});
}

// Network
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}
class NetworkTimeout extends Failure {
  const NetworkTimeout(super.message, {super.code});
}
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

// Engine
class EngineFailure extends Failure {
  const EngineFailure(super.message, {super.code});
}
class EngineTimeoutFailure extends Failure {
  const EngineTimeoutFailure(super.message, {super.code});
}
class SafetyViolationFailure extends Failure {
  const SafetyViolationFailure(super.message, {super.code});
}

// Data
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
class DataCorruptionFailure extends Failure {
  const DataCorruptionFailure(super.message, {super.code});
}

// Security
class SecurityFailure extends Failure {
  const SecurityFailure(super.message, {super.code});
}
class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message, {super.code});
}

// AI / ML
class InferenceFailure extends Failure {
  const InferenceFailure(super.message, {super.code});
}
class RetrievalFailure extends Failure {
  const RetrievalFailure(super.message, {super.code});
}
