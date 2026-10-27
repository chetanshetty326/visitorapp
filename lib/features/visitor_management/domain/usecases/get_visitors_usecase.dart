import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

class GetVisitorsUseCase {
  final VisitorRepository repository;

  GetVisitorsUseCase(this.repository);

  Future<List<Visitor>> call() async {
    return await repository.getVisitors();
  }
}
