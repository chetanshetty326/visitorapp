import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class CheckInVisitorUseCase {
  final VisitorRepository repository;

  CheckInVisitorUseCase(this.repository);

  Future<Visitor> call(String id) async {
    
    final visitor = await repository.getVisitorById(id);

    if (visitor.status == AppConstants.statusCheckedIn) {
      throw ValidationException('Visitor is already checked in.');
    }

    if (visitor.status == AppConstants.statusCheckedOut) {
      throw ValidationException(
          'Completed visits cannot be checked in again. Please register a new visit.');
    }

    if (visitor.status != AppConstants.statusRegistered) {
      throw ValidationException(
          'Check-in is only allowed for Registered visitors. Current status: ${visitor.status}');
    }

    return await repository.checkInVisitor(id);
  }
}
