import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../di/injection.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';

class ApiSettingsDialog extends StatefulWidget {
  const ApiSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ApiSettingsDialog(),
    );
  }

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool _isTestSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConstants.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final candidateUrl = _urlController.text.trim();
    if (candidateUrl.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = sl<Dio>();
      final response = await dio.get(
        '$candidateUrl${ApiConstants.visitorsEndpoint}',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      setState(() {
        _isTesting = false;
        _isTestSuccess = true;
        _testResult = 'Connection successful! (Status: ${response.statusCode})';
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _isTestSuccess = false;
        _testResult = 'Endpoint unreachable or returned error: $e';
      });
    }
  }

  Future<void> _saveUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) return;

    await ApiConstants.setBaseUrl(newUrl);
    // Update active dio baseUrl
    sl<Dio>().options.baseUrl = newUrl;

    if (mounted) {
      // Refresh visitors with the new API URL
      context.read<VisitorBloc>().add(const LoadVisitorsEvent(isRefresh: true));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Base URL updated to: $newUrl'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resetDefault() async {
    await ApiConstants.resetToDefault();
    sl<Dio>().options.baseUrl = ApiConstants.baseUrl;
    _urlController.text = ApiConstants.baseUrl;

    if (mounted) {
      context.read<VisitorBloc>().add(const LoadVisitorsEvent(isRefresh: true));
      setState(() {
        _testResult = 'Reset to default built-in mock endpoint.';
        _isTestSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.cloud_sync_rounded, color: AppTheme.primary, size: 24),
          SizedBox(width: 10),
          Text(
            'REST API Configuration',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your MockAPI.io base URL or REST server endpoint (e.g. from MockAPI, Beeceptor, or your backend).',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://<id>.mockapi.io/api/v1',
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _urlController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering_rounded, size: 16),
                  label: const Text('Test Connection', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetDefault,
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isTestSuccess ? AppTheme.statusCheckedInBg : AppTheme.errorBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isTestSuccess
                        ? AppTheme.statusCheckedIn.withValues(alpha: 0.3)
                        : AppTheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isTestSuccess ? AppTheme.statusCheckedIn : AppTheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveUrl,
          child: const Text('Save & Sync'),
        ),
      ],
    );
  }
}
