import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested visitor was not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
