import '../entities/visitor.dart';

abstract class VisitorRepository {
  /// Fetch all visitor records from the API
  Future<List<Visitor>> getVisitors();

  /// Retrieve single visitor details by ID
  Future<Visitor> getVisitorById(String id);

  /// Register a new visitor
  Future<Visitor> registerVisitor(Visitor visitor);

  /// Update existing visitor details
  Future<Visitor> updateVisitor(Visitor visitor);

  /// Delete a visitor record
  Future<void> deleteVisitor(String id);

  /// Update visitor status to 'Checked In' and record check_in_time
  Future<Visitor> checkInVisitor(String id);

  /// Update visitor status to 'Checked Out' and record check_out_time
  Future<Visitor> checkOutVisitor(String id);
}
