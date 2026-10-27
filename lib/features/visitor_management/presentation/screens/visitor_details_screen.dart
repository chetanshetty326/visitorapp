import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_chip.dart';
import 'visitor_form_screen.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final Visitor initialVisitor;

  const VisitorDetailsScreen({super.key, required this.initialVisitor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        // Fetch freshest version of the visitor from state if updated
        Visitor visitor = initialVisitor;
        bool isSubmitting = false;

        if (state is VisitorLoadedState) {
          isSubmitting = state.isSubmitting;
          final found = state.allVisitors.where((v) => v.id == initialVisitor.id);
          if (found.isNotEmpty) {
            visitor = found.first;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Visitor Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Visitor',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VisitorFormScreen(visitorToEdit: visitor),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                tooltip: 'Delete Visitor',
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Delete Visitor Record',
                    message:
                        'Are you sure you want to delete the record for ${visitor.name}? This action cannot be undone.',
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<VisitorBloc>().add(DeleteVisitorEvent(visitor.id));
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top QR Code Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: QrImageView(
                          data: visitor.id,
                          version: QrVersions.auto,
                          size: 180,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppTheme.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'Visitor ID: ${visitor.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StatusChip(status: visitor.status, fontSize: 13),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Visitor Information Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visitor Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.person_rounded,
                        label: 'Full Name',
                        value: visitor.name,
                      ),
                      _buildInfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Mobile',
                        value: visitor.mobile,
                      ),
                      if (visitor.email != null && visitor.email!.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: visitor.email!,
                        ),
                      _buildInfoRow(
                        icon: Icons.badge_rounded,
                        label: 'Visitor Type',
                        value: visitor.visitorType,
                      ),
                      _buildInfoRow(
                        icon: Icons.apartment_rounded,
                        label: 'Project Location',
                        value: visitor.project,
                      ),
                      _buildInfoRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Purpose of Visit',
                        value: visitor.purpose,
                      ),
                      _buildInfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Registered On',
                        value: DateFormatter.formatDateTime(visitor.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Timestamps Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visit Activity Timestamps',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimestampTile(
                              title: 'Check-in Time',
                              time: DateFormatter.formatDateTime(visitor.checkInTime),
                              isSet: visitor.checkInTime != null,
                              icon: Icons.login_rounded,
                              color: AppTheme.statusCheckedIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimestampTile(
                              title: 'Check-out Time',
                              time: DateFormatter.formatDateTime(visitor.checkOutTime),
                              isSet: visitor.checkOutTime != null,
                              icon: Icons.logout_rounded,
                              color: AppTheme.statusCheckedOut,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Check-in / Check-out Workflow Action Buttons
                _buildWorkflowActions(context, visitor, isSubmitting),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampTile({
    required String title,
    required String time,
    required bool isSet,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSet ? color.withValues(alpha: 0.08) : AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSet ? color.withValues(alpha: 0.25) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: isSet ? color : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSet ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSet ? AppTheme.textPrimary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowActions(BuildContext context, Visitor visitor, bool isSubmitting) {
    if (visitor.status == AppConstants.statusRegistered) {
      return CustomButton(
        label: 'Confirm Visitor Check-In',
        icon: Icons.login_rounded,
        isLoading: isSubmitting,
        backgroundColor: AppTheme.statusCheckedIn,
        onPressed: () {
          context.read<VisitorBloc>().add(CheckInVisitorEvent(visitor.id));
        },
      );
    } else if (visitor.status == AppConstants.statusCheckedIn) {
      return CustomButton(
        label: 'Confirm Visitor Check-Out',
        icon: Icons.logout_rounded,
        isLoading: isSubmitting,
        backgroundColor: AppTheme.statusCheckedOut,
        onPressed: () {
          context.read<VisitorBloc>().add(CheckOutVisitorEvent(visitor.id));
        },
      );
    } else {
      // Checked Out
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.statusCheckedOutBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.statusCheckedOut, size: 18),
            SizedBox(width: 8),
            Text(
              'Visit completed (Checked Out). Session closed.',
              style: TextStyle(
                color: AppTheme.statusCheckedOut,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
  }
}
