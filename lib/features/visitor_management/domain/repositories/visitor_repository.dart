import '../entities/visitor.dart';

abstract class VisitorRepository {
  
  Future<List<Visitor>> getVisitors();

 
  Future<Visitor> getVisitorById(String id);

  
  Future<Visitor> registerVisitor(Visitor visitor);


  Future<Visitor> updateVisitor(Visitor visitor);

 
  Future<void> deleteVisitor(String id);

  
  Future<Visitor> checkInVisitor(String id);

 
  Future<Visitor> checkOutVisitor(String id);
}
