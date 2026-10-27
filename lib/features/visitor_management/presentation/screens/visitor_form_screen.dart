import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';

class VisitorFormScreen extends StatefulWidget {
  final Visitor? visitorToEdit;

  const VisitorFormScreen({super.key, this.visitorToEdit});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  late String _selectedVisitorType;
  late String _selectedProject;

  bool get _isEditing => widget.visitorToEdit != null;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitorToEdit;
    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');

    _selectedVisitorType = visitor?.visitorType ?? AppConstants.typeCustomer;
    _selectedProject = visitor?.project ?? AppConstants.projectA;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final purpose = _purposeController.text.trim();

    if (_isEditing) {
      final updated = widget.visitorToEdit!.copyWith(
        name: name,
        mobile: mobile,
        email: email,
        visitorType: _selectedVisitorType,
        project: _selectedProject,
        purpose: purpose,
      );
      context.read<VisitorBloc>().add(UpdateVisitorEvent(updated));
    } else {
      final newVisitor = Visitor(
        id: '', // Will be assigned by API/data source
        name: name,
        mobile: mobile,
        email: email,
        visitorType: _selectedVisitorType,
        project: _selectedProject,
        purpose: purpose,
        status: AppConstants.statusRegistered,
        createdAt: DateTime.now(),
      );
      context.read<VisitorBloc>().add(RegisterVisitorEvent(newVisitor));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Visitor' : 'Register New Visitor'),
      ),
      body: SafeArea(
        child: BlocBuilder<VisitorBloc, VisitorState>(
          builder: (context, state) {
            final isSubmitting =
                state is VisitorLoadedState ? state.isSubmitting : false;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing
                                ? Icons.edit_note_rounded
                                : Icons.person_add_alt_1_rounded,
                            color: AppTheme.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isEditing
                                  ? 'Update visitor credentials and visit details below.'
                                  : 'Fill in visitor details. A unique QR code will be generated upon registration.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Visitor Full Name *',
                      hint: 'e.g. Rahul Sharma',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) => Validators.validateRequired(val, 'Visitor name'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _mobileController,
                      label: 'Mobile Number (10 digits) *',
                      hint: 'e.g. 9876543210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validateMobile,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address (Optional)',
                      hint: 'e.g. rahul@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown<String>(
                      label: 'Visitor Type *',
                      value: _selectedVisitorType,
                      items: AppConstants.visitorTypes,
                      prefixIcon: Icons.badge_outlined,
                      itemLabel: (item) => item,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedVisitorType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown<String>(
                      label: 'Project *',
                      value: _selectedProject,
                      items: AppConstants.projects,
                      prefixIcon: Icons.apartment_outlined,
                      itemLabel: (item) => item,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedProject = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _purposeController,
                      label: 'Purpose of Visit *',
                      hint: 'e.g. Site Visit / Material Delivery / Meeting',
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                      maxLines: 2,
                      validator: (val) => Validators.validateRequired(val, 'Purpose of visit'),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            label: _isEditing ? 'Save Changes' : 'Register Visitor',
                            isLoading: isSubmitting,
                            icon: _isEditing ? Icons.check_circle_outline : Icons.qr_code,
                            onPressed: _onSave,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
