import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitors Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Register Visitor',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Visitor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state is VisitorLoadedState && state.userFeedback != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.userFeedback!),
                backgroundColor:
                    state.isErrorFeedback ? AppTheme.error : AppTheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VisitorLoadingState) {
            return const LoadingView(message: 'Loading visitors records...');
          }

          if (state is VisitorErrorState) {
            return EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: 'Failed to Load Records',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context.read<VisitorBloc>().add(const LoadVisitorsEvent());
              },
            );
          }

          if (state is VisitorLoadedState) {
            return Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<VisitorBloc>().add(SearchVisitorsEvent(query));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by visitor name or mobile...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<VisitorBloc>()
                                    .add(const SearchVisitorsEvent(''));
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Bonus Feature: Filter Chips for Projects & Status
                _buildFilterChips(context, state),

                if (state.isSubmitting)
                  const LinearProgressIndicator(
                    minHeight: 2.5,
                    color: AppTheme.primary,
                    backgroundColor: Colors.transparent,
                  ),

                // Visitor List / Empty State
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<VisitorBloc>()
                          .add(const LoadVisitorsEvent(isRefresh: true));
                    },
                    child: state.filteredVisitors.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.45,
                                child: EmptyStateView(
                                  icon: Icons.people_outline_rounded,
                                  title: state.searchQuery.isNotEmpty ||
                                          state.selectedProject != null ||
                                          state.selectedStatus != null
                                      ? 'No matching visitors'
                                      : 'No visitors registered yet',
                                  message: state.searchQuery.isNotEmpty
                                      ? 'No records match "${state.searchQuery}". Try a different keyword or reset filters.'
                                      : 'Register a new visitor to generate their pass and QR code.',
                                  actionLabel: state.searchQuery.isEmpty &&
                                          state.selectedProject == null &&
                                          state.selectedStatus == null
                                      ? 'Register First Visitor'
                                      : null,
                                  onAction: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const VisitorFormScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: state.filteredVisitors.length,
                            itemBuilder: (context, index) {
                              final visitor = state.filteredVisitors[index];
                              return VisitorCard(
                                visitor: visitor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VisitorDetailsScreen(
                                        initialVisitor: visitor,
                                      ),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VisitorFormScreen(
                                        visitorToEdit: visitor,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final confirmed = await ConfirmDialog.show(
                                    context,
                                    title: 'Delete Record',
                                    message:
                                        'Are you sure you want to delete ${visitor.name}? This will remove all associated visitor data.',
                                  );
                                  if (confirmed == true && context.mounted) {
                                    context
                                        .read<VisitorBloc>()
                                        .add(DeleteVisitorEvent(visitor.id));
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, VisitorLoadedState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // All chip
          FilterChip(
            label: const Text('All'),
            selected: state.selectedProject == null && state.selectedStatus == null,
            onSelected: (_) {
              context.read<VisitorBloc>().add(
                    const FilterVisitorsEvent(project: null, status: null),
                  );
            },
          ),
          const SizedBox(width: 8),

          // Status Filter Chips
          ...AppConstants.visitorStatuses.map((status) {
            final isSelected = state.selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: AppTheme.getStatusColor(status).withValues(alpha: 0.15),
                checkmarkColor: AppTheme.getStatusColor(status),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.getStatusColor(status) : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  context.read<VisitorBloc>().add(
                        FilterVisitorsEvent(
                          project: state.selectedProject,
                          status: selected ? status : null,
                        ),
                      );
                },
              ),
            );
          }),

          // Project Filter Chips
          ...AppConstants.projects.map((proj) {
            final isSelected = state.selectedProject == proj;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(proj),
                selected: isSelected,
                selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  context.read<VisitorBloc>().add(
                        FilterVisitorsEvent(
                          project: selected ? proj : null,
                          status: state.selectedStatus,
                        ),
                      );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
