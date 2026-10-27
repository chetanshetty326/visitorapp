import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class RegisterVisitorUseCase {
  final VisitorRepository repository;

  RegisterVisitorUseCase(this.repository);

  Future<Visitor> call(Visitor visitor) async {
    // Validate required fields
    if (visitor.name.trim().isEmpty) {
      throw ValidationException('Visitor name is required');
    }
    if (visitor.mobile.trim().length != 10) {
      throw ValidationException('Mobile number must be exactly 10 digits');
    }
    if (visitor.purpose.trim().isEmpty) {
      throw ValidationException('Purpose of visit is required');
    }

    // Default status must be Registered as per requirements
    final visitorToSave = visitor.copyWith(
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    );

    return await repository.registerVisitor(visitorToSave);
  }
}
