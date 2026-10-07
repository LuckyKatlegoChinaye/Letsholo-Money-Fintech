abstract class Failure implements Exception {

  Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

class PaymentFailure extends Failure {
  PaymentFailure(super.message);
}

class KycFailure extends Failure {
  KycFailure(super.message);
}
