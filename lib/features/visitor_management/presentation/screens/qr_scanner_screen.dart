import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../di/injection.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/usecases/get_visitor_by_id_usecase.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_state.dart';
import 'visitor_details_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _scannerController;
  bool _isProcessingCode = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessingCode) return; // Prevent duplicate scanner callbacks

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) {
      _showFeedbackSnackBar('Invalid QR code format.', isError: true);
      return;
    }

    await _processVisitorId(rawValue.trim());
  }

  Future<void> _processVisitorId(String scannedId) async {
    setState(() {
      _isProcessingCode = true;
    });

    // 1. First check in current loaded visitors in BLoC state
    final state = context.read<VisitorBloc>().state;
    Visitor? foundVisitor;

    if (state is VisitorLoadedState) {
      final matches = state.allVisitors.where(
        (v) => v.id.toLowerCase() == scannedId.toLowerCase(),
      );
      if (matches.isNotEmpty) {
        foundVisitor = matches.first;
      }
    }

    // 2. If not found in local memory, retrieve visitor details from REST API
    if (foundVisitor == null) {
      try {
        foundVisitor = await sl<GetVisitorByIdUseCase>()(scannedId);
      } catch (_) {
        foundVisitor = null;
      }
    }

    if (!mounted) return;

    if (foundVisitor != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VisitorDetailsScreen(initialVisitor: foundVisitor!),
        ),
      );
    } else {
      _showFeedbackSnackBar(
        'Visitor with ID "$scannedId" does not exist in API records.',
        isError: true,
      );
    }

    // Cooldown before allowing next scan
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isProcessingCode = false;
      });
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.keyboard_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Enter Visitor ID', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test scanner lookup without a physical camera by entering any visitor ID (e.g. VIS001, 1, 4):',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. VIS001 or 4',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = controller.text.trim();
              Navigator.of(ctx).pop();
              if (id.isNotEmpty) {
                _processVisitorId(id);
              }
            },
            child: const Text('Lookup Visitor'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Visitor QR Code', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_alt_outlined),
            color: Colors.white,
            tooltip: 'Enter ID Manually (Test Mode)',
            onPressed: _showManualEntryDialog,
          ),
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            color: Colors.white,
            tooltip: 'Toggle Flashlight',
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_rounded),
            color: Colors.white,
            tooltip: 'Switch Camera',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Access Needed',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please allow camera permissions in system settings to scan visitor QR codes.\nDetails: ${error.errorCode}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Custom Viewfinder Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessingCode ? AppTheme.statusCheckedIn : Colors.white,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Instruction and Status Banner
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(
                    _isProcessingCode ? Icons.hourglass_top_rounded : Icons.qr_code_scanner_rounded,
                    color: _isProcessingCode ? AppTheme.primaryLight : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isProcessingCode
                          ? 'Looking up visitor record...'
                          : 'Align visitor QR code inside the viewfinder to scan.',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
