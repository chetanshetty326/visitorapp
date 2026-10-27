import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_data_source.dart';
import '../models/visitor_model.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource remoteDataSource;

  VisitorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Visitor>> getVisitors() async {
    final models = await remoteDataSource.getVisitors();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Visitor> getVisitorById(String id) async {
    final model = await remoteDataSource.getVisitorById(id);
    return model.toEntity();
  }

  @override
  Future<Visitor> registerVisitor(Visitor visitor) async {
    final model = VisitorModel.fromEntity(visitor);
    final createdModel = await remoteDataSource.registerVisitor(model);
    return createdModel.toEntity();
  }

  @override
  Future<Visitor> updateVisitor(Visitor visitor) async {
    final model = VisitorModel.fromEntity(visitor);
    final updatedModel = await remoteDataSource.updateVisitor(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteVisitor(String id) async {
    await remoteDataSource.deleteVisitor(id);
  }

  @override
  Future<Visitor> checkInVisitor(String id) async {
    final updatedModel = await remoteDataSource.updateVisitorStatus(
      id: id,
      status: AppConstants.statusCheckedIn,
      checkInTime: DateTime.now(),
    );
    return updatedModel.toEntity();
  }

  @override
  Future<Visitor> checkOutVisitor(String id) async {
    final updatedModel = await remoteDataSource.updateVisitorStatus(
      id: id,
      status: AppConstants.statusCheckedOut,
      checkOutTime: DateTime.now(),
    );
    return updatedModel.toEntity();
  }
}
