import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class CheckOutVisitorUseCase {
  final VisitorRepository repository;

  CheckOutVisitorUseCase(this.repository);

  Future<Visitor> call(String id) async {
    
    final visitor = await repository.getVisitorById(id);

    if (visitor.status == AppConstants.statusRegistered) {
      throw ValidationException('Visitors cannot check out before checking in.');
    }

    if (visitor.status == AppConstants.statusCheckedOut) {
      throw ValidationException('Visitor has already checked out.');
    }

    if (visitor.status != AppConstants.statusCheckedIn) {
      throw ValidationException(
          'Check-out is only allowed for Checked In visitors. Current status: ${visitor.status}');
    }

    return await repository.checkOutVisitor(id);
  }
}
