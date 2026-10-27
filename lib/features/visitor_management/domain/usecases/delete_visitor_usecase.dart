import '../repositories/visitor_repository.dart';

class DeleteVisitorUseCase {
  final VisitorRepository repository;

  DeleteVisitorUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteVisitor(id);
  }
}
