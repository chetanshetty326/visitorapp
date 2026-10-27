import '../../../../core/error/exceptions.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class UpdateVisitorUseCase {
  final VisitorRepository repository;

  UpdateVisitorUseCase(this.repository);

  Future<Visitor> call(Visitor visitor) async {
    if (visitor.name.trim().isEmpty) {
      throw ValidationException('Visitor name is required');
    }
    if (visitor.mobile.trim().length != 10) {
      throw ValidationException('Mobile number must be exactly 10 digits');
    }
    if (visitor.purpose.trim().isEmpty) {
      throw ValidationException('Purpose of visit is required');
    }

    return await repository.updateVisitor(visitor);
  }
}
