import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class GetVisitorByIdUseCase {
  final VisitorRepository repository;

  GetVisitorByIdUseCase(this.repository);

  Future<Visitor> call(String id) async {
    return await repository.getVisitorById(id);
  }
}
