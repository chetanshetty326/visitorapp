import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/usecases/check_in_visitor_usecase.dart';
import '../../domain/usecases/check_out_visitor_usecase.dart';
import '../../domain/usecases/delete_visitor_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_visitors_usecase.dart';
import '../../domain/usecases/register_visitor_usecase.dart';
import '../../domain/usecases/update_visitor_usecase.dart';
import 'visitor_event.dart';
import 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final GetVisitorsUseCase getVisitorsUseCase;
  final RegisterVisitorUseCase registerVisitorUseCase;
  final UpdateVisitorUseCase updateVisitorUseCase;
  final DeleteVisitorUseCase deleteVisitorUseCase;
  final CheckInVisitorUseCase checkInVisitorUseCase;
  final CheckOutVisitorUseCase checkOutVisitorUseCase;
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  VisitorBloc({
    required this.getVisitorsUseCase,
    required this.registerVisitorUseCase,
    required this.updateVisitorUseCase,
    required this.deleteVisitorUseCase,
    required this.checkInVisitorUseCase,
    required this.checkOutVisitorUseCase,
    required this.getDashboardStatsUseCase,
  }) : super(VisitorInitialState()) {
    on<LoadVisitorsEvent>(_onLoadVisitors);
    on<SearchVisitorsEvent>(_onSearchVisitors);
    on<FilterVisitorsEvent>(_onFilterVisitors);
    on<RegisterVisitorEvent>(_onRegisterVisitor);
    on<UpdateVisitorEvent>(_onUpdateVisitor);
    on<DeleteVisitorEvent>(_onDeleteVisitor);
    on<CheckInVisitorEvent>(_onCheckInVisitor);
    on<CheckOutVisitorEvent>(_onCheckOutVisitor);
  }

  Future<void> _onLoadVisitors(
    LoadVisitorsEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(VisitorLoadingState());
    }
    try {
      final visitors = await getVisitorsUseCase();
      final stats = getDashboardStatsUseCase(visitors);

      // Retain existing filters if already in LoadedState
      String searchQuery = '';
      String? selectedProject;
      String? selectedStatus;

      if (state is VisitorLoadedState) {
        final current = state as VisitorLoadedState;
        searchQuery = current.searchQuery;
        selectedProject = current.selectedProject;
        selectedStatus = current.selectedStatus;
      }

      final filtered = _applyFilters(
        visitors: visitors,
        query: searchQuery,
        project: selectedProject,
        status: selectedStatus,
      );

      emit(VisitorLoadedState(
        allVisitors: visitors,
        filteredVisitors: filtered,
        dashboardStats: stats,
        searchQuery: searchQuery,
        selectedProject: selectedProject,
        selectedStatus: selectedStatus,
      ));
    } catch (e) {
      emit(VisitorErrorState(e.toString()));
    }
  }

  void _onSearchVisitors(
    SearchVisitorsEvent event,
    Emitter<VisitorState> emit,
  ) {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      final filtered = _applyFilters(
        visitors: current.allVisitors,
        query: event.query,
        project: current.selectedProject,
        status: current.selectedStatus,
      );
      emit(current.copyWith(
        searchQuery: event.query,
        filteredVisitors: filtered,
      ));
    }
  }

  void _onFilterVisitors(
    FilterVisitorsEvent event,
    Emitter<VisitorState> emit,
  ) {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      final filtered = _applyFilters(
        visitors: current.allVisitors,
        query: current.searchQuery,
        project: event.project,
        status: event.status,
      );
      emit(current.copyWith(
        selectedProject: event.project,
        selectedStatus: event.status,
        clearProjectFilter: event.project == null,
        clearStatusFilter: event.status == null,
        filteredVisitors: filtered,
      ));
    }
  }

  Future<void> _onRegisterVisitor(
    RegisterVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      emit(current.copyWith(isSubmitting: true));
      try {
        final registered = await registerVisitorUseCase(event.visitor);
        // Reload all visitors to update list and dashboard stats immediately
        final updatedList = await getVisitorsUseCase();
        final stats = getDashboardStatsUseCase(updatedList);
        final filtered = _applyFilters(
          visitors: updatedList,
          query: current.searchQuery,
          project: current.selectedProject,
          status: current.selectedStatus,
        );

        emit(VisitorLoadedState(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          dashboardStats: stats,
          searchQuery: current.searchQuery,
          selectedProject: current.selectedProject,
          selectedStatus: current.selectedStatus,
          isSubmitting: false,
          userFeedback: 'Visitor registered successfully! QR pass generated.',
          isErrorFeedback: false,
          lastRegisteredVisitor: registered,
        ));
      } catch (e) {
        emit(current.copyWith(
          isSubmitting: false,
          userFeedback: _extractErrorMessage(e),
          isErrorFeedback: true,
        ));
      }
    }
  }

  Future<void> _onUpdateVisitor(
    UpdateVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      emit(current.copyWith(isSubmitting: true));
      try {
        await updateVisitorUseCase(event.visitor);
        final updatedList = await getVisitorsUseCase();
        final stats = getDashboardStatsUseCase(updatedList);
        final filtered = _applyFilters(
          visitors: updatedList,
          query: current.searchQuery,
          project: current.selectedProject,
          status: current.selectedStatus,
        );

        emit(VisitorLoadedState(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          dashboardStats: stats,
          searchQuery: current.searchQuery,
          selectedProject: current.selectedProject,
          selectedStatus: current.selectedStatus,
          isSubmitting: false,
          userFeedback: 'Visitor information updated!',
          isErrorFeedback: false,
        ));
      } catch (e) {
        emit(current.copyWith(
          isSubmitting: false,
          userFeedback: _extractErrorMessage(e),
          isErrorFeedback: true,
        ));
      }
    }
  }

  Future<void> _onDeleteVisitor(
    DeleteVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      emit(current.copyWith(isSubmitting: true));
      try {
        await deleteVisitorUseCase(event.id);
        final updatedList = await getVisitorsUseCase();
        final stats = getDashboardStatsUseCase(updatedList);
        final filtered = _applyFilters(
          visitors: updatedList,
          query: current.searchQuery,
          project: current.selectedProject,
          status: current.selectedStatus,
        );

        emit(VisitorLoadedState(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          dashboardStats: stats,
          searchQuery: current.searchQuery,
          selectedProject: current.selectedProject,
          selectedStatus: current.selectedStatus,
          isSubmitting: false,
          userFeedback: 'Visitor record deleted.',
          isErrorFeedback: false,
        ));
      } catch (e) {
        emit(current.copyWith(
          isSubmitting: false,
          userFeedback: _extractErrorMessage(e),
          isErrorFeedback: true,
        ));
      }
    }
  }

  Future<void> _onCheckInVisitor(
    CheckInVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      emit(current.copyWith(isSubmitting: true));
      try {
        final updatedVisitor = await checkInVisitorUseCase(event.id);
        final updatedList = await getVisitorsUseCase();
        final stats = getDashboardStatsUseCase(updatedList);
        final filtered = _applyFilters(
          visitors: updatedList,
          query: current.searchQuery,
          project: current.selectedProject,
          status: current.selectedStatus,
        );

        emit(VisitorLoadedState(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          dashboardStats: stats,
          searchQuery: current.searchQuery,
          selectedProject: current.selectedProject,
          selectedStatus: current.selectedStatus,
          isSubmitting: false,
          userFeedback: '${updatedVisitor.name} has been Checked In!',
          isErrorFeedback: false,
        ));
      } catch (e) {
        emit(current.copyWith(
          isSubmitting: false,
          userFeedback: _extractErrorMessage(e),
          isErrorFeedback: true,
        ));
      }
    }
  }

  Future<void> _onCheckOutVisitor(
    CheckOutVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoadedState) {
      final current = state as VisitorLoadedState;
      emit(current.copyWith(isSubmitting: true));
      try {
        final updatedVisitor = await checkOutVisitorUseCase(event.id);
        final updatedList = await getVisitorsUseCase();
        final stats = getDashboardStatsUseCase(updatedList);
        final filtered = _applyFilters(
          visitors: updatedList,
          query: current.searchQuery,
          project: current.selectedProject,
          status: current.selectedStatus,
        );

        emit(VisitorLoadedState(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          dashboardStats: stats,
          searchQuery: current.searchQuery,
          selectedProject: current.selectedProject,
          selectedStatus: current.selectedStatus,
          isSubmitting: false,
          userFeedback: '${updatedVisitor.name} has been Checked Out!',
          isErrorFeedback: false,
        ));
      } catch (e) {
        emit(current.copyWith(
          isSubmitting: false,
          userFeedback: _extractErrorMessage(e),
          isErrorFeedback: true,
        ));
      }
    }
  }

  List<Visitor> _applyFilters({
    required List<Visitor> visitors,
    required String query,
    String? project,
    String? status,
  }) {
    return visitors.where((v) {
      final matchesQuery = query.isEmpty ||
          v.name.toLowerCase().contains(query.toLowerCase()) ||
          v.mobile.contains(query.trim());

      final matchesProject = project == null || v.project == project;
      final matchesStatus = status == null || v.status == status;

      return matchesQuery && matchesProject && matchesStatus;
    }).toList();
  }

  String _extractErrorMessage(dynamic error) {
    if (error is ValidationException) return error.message;
    if (error is NotFoundException) return error.message;
    if (error is NetworkException) return error.message;
    if (error is ServerException) return error.message;
    return error.toString().replaceAll('Exception:', '').trim();
  }
}
