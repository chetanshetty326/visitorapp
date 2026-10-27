import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();

  @override
  List<Object?> get props => [];
}

class LoadVisitorsEvent extends VisitorEvent {
  final bool isRefresh;
  const LoadVisitorsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchVisitorsEvent extends VisitorEvent {
  final String query;
  const SearchVisitorsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterVisitorsEvent extends VisitorEvent {
  final String? project;
  final String? status;
  const FilterVisitorsEvent({this.project, this.status});

  @override
  List<Object?> get props => [project, status];
}

class RegisterVisitorEvent extends VisitorEvent {
  final Visitor visitor;
  const RegisterVisitorEvent(this.visitor);

  @override
  List<Object?> get props => [visitor];
}

class UpdateVisitorEvent extends VisitorEvent {
  final Visitor visitor;
  const UpdateVisitorEvent(this.visitor);

  @override
  List<Object?> get props => [visitor];
}

class DeleteVisitorEvent extends VisitorEvent {
  final String id;
  const DeleteVisitorEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CheckInVisitorEvent extends VisitorEvent {
  final String id;
  const CheckInVisitorEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CheckOutVisitorEvent extends VisitorEvent {
  final String id;
  const CheckOutVisitorEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearScanResultEvent extends VisitorEvent {
  const ClearScanResultEvent();
}
