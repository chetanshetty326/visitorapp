import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';
import '../widgets/api_settings_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/visitor_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToVisitors;
  final VoidCallback onNavigateToScanner;

  const DashboardScreen({
    super.key,
    required this.onNavigateToVisitors,
    required this.onNavigateToScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sumadhura Estates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            Text(
              'Visitor Management Portal',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded),
            tooltip: 'API Configuration',
            onPressed: () {
              ApiSettingsDialog.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Data',
            onPressed: () {
              context.read<VisitorBloc>().add(const LoadVisitorsEvent(isRefresh: true));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            tooltip: 'Log Out',
            onPressed: () async {
              final confirm = await ConfirmDialog.show(
                context,
                title: 'Sign Out',
                message: 'Do you want to sign out of the Security & Front Desk portal?',
                confirmLabel: 'Sign Out',
                confirmColor: AppTheme.error,
              );
              if (confirm == true && context.mounted) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
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
            return const LoadingView(message: 'Calculating metrics and fetching records...');
          }

          if (state is VisitorErrorState) {
            return EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load dashboard',
              message: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context.read<VisitorBloc>().add(const LoadVisitorsEvent());
              },
            );
          }

          if (state is VisitorLoadedState) {
            final stats = state.dashboardStats;
            final todayFormatted = DateFormatter.formatDate(DateTime.now());

            return RefreshIndicator(
              onRefresh: () async {
                context.read<VisitorBloc>().add(const LoadVisitorsEvent(isRefresh: true));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isSubmitting) ...[
                      const LinearProgressIndicator(
                        minHeight: 2.5,
                        color: AppTheme.primary,
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Date banner
                    Row(
                      children: [
                        const Icon(Icons.today_rounded, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Today, $todayFormatted',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Three Required Dashboard Metric Cards
                    Row(
                      children: [
                        DashboardStatCard(
                          title: 'Total Visitors Today',
                          count: stats.totalVisitorsToday,
                          icon: Icons.people_alt_rounded,
                          accentColor: AppTheme.primary,
                          onTap: onNavigateToVisitors,
                        ),
                        const SizedBox(width: 10),
                        DashboardStatCard(
                          title: 'Currently Checked In',
                          count: stats.currentlyCheckedIn,
                          icon: Icons.login_rounded,
                          accentColor: AppTheme.statusCheckedIn,
                          onTap: onNavigateToVisitors,
                        ),
                        const SizedBox(width: 10),
                        DashboardStatCard(
                          title: 'Checked Out Today',
                          count: stats.checkedOutToday,
                          icon: Icons.logout_rounded,
                          accentColor: AppTheme.statusCheckedOut,
                          onTap: onNavigateToVisitors,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Shortcuts
                    const Text(
                      'Quick Shortcuts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Register Visitor',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VisitorFormScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: 'Scan QR Pass',
                            icon: Icons.qr_code_scanner_rounded,
                            backgroundColor: AppTheme.secondary,
                            onPressed: onNavigateToScanner,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Visitors Preview Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Visitors',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: onNavigateToVisitors,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (state.allVisitors.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Center(
                          child: Text(
                            'No visitors recorded today. Tap "Register Visitor" to begin.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...state.allVisitors.take(4).map(
                            (v) => VisitorCard(
                              visitor: v,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VisitorDetailsScreen(initialVisitor: v),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VisitorFormScreen(visitorToEdit: v),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirmed = await ConfirmDialog.show(
                                  context,
                                  title: 'Delete Record',
                                  message: 'Delete ${v.name} from records?',
                                );
                                if (confirmed == true && context.mounted) {
                                  context.read<VisitorBloc>().add(DeleteVisitorEvent(v.id));
                                }
                              },
                            ),
                          ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
