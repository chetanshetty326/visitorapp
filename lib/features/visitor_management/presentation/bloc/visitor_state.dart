import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/visitor.dart';

abstract class VisitorState extends Equatable {
  const VisitorState();

  @override
  List<Object?> get props => [];
}

class VisitorInitialState extends VisitorState {}

class VisitorLoadingState extends VisitorState {}

class VisitorLoadedState extends VisitorState {
  final List<Visitor> allVisitors;
  final List<Visitor> filteredVisitors;
  final DashboardStats dashboardStats;
  final String searchQuery;
  final String? selectedProject;
  final String? selectedStatus;
  final bool isSubmitting;
  final String? userFeedback;
  final bool isErrorFeedback;
  final Visitor? lastRegisteredVisitor;

  const VisitorLoadedState({
    required this.allVisitors,
    required this.filteredVisitors,
    required this.dashboardStats,
    this.searchQuery = '',
    this.selectedProject,
    this.selectedStatus,
    this.isSubmitting = false,
    this.userFeedback,
    this.isErrorFeedback = false,
    this.lastRegisteredVisitor,
  });

  VisitorLoadedState copyWith({
    List<Visitor>? allVisitors,
    List<Visitor>? filteredVisitors,
    DashboardStats? dashboardStats,
    String? searchQuery,
    String? selectedProject,
    String? selectedStatus,
    bool clearProjectFilter = false,
    bool clearStatusFilter = false,
    bool? isSubmitting,
    String? userFeedback,
    bool? isErrorFeedback,
    Visitor? lastRegisteredVisitor,
    bool clearLastRegistered = false,
  }) {
    return VisitorLoadedState(
      allVisitors: allVisitors ?? this.allVisitors,
      filteredVisitors: filteredVisitors ?? this.filteredVisitors,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProject:
          clearProjectFilter ? null : (selectedProject ?? this.selectedProject),
      selectedStatus:
          clearStatusFilter ? null : (selectedStatus ?? this.selectedStatus),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      userFeedback: userFeedback,
      isErrorFeedback: isErrorFeedback ?? false,
      lastRegisteredVisitor: clearLastRegistered
          ? null
          : (lastRegisteredVisitor ?? this.lastRegisteredVisitor),
    );
  }

  @override
  List<Object?> get props => [
        allVisitors,
        filteredVisitors,
        dashboardStats,
        searchQuery,
        selectedProject,
        selectedStatus,
        isSubmitting,
        userFeedback,
        isErrorFeedback,
        lastRegisteredVisitor,
      ];
}

class VisitorErrorState extends VisitorState {
  final String message;
  const VisitorErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
