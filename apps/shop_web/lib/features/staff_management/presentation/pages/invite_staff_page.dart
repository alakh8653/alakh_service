/// Invite staff page containing a form to send a new staff invitation.
///
/// Collects email, name, role, and an optional message. Validates inputs
/// and dispatches [InviteStaff] to [StaffManagementBloc] on submission.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_bloc.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_event.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_state.dart';
import 'package:shop_web/shared/shared.dart';

/// A form page for inviting a new staff member via email.
class InviteStaffPage extends StatefulWidget {
  /// Creates the [InviteStaffPage].
  const InviteStaffPage({super.key});

  @override
  State<InviteStaffPage> createState() => _InviteStaffPageState();
}

class _InviteStaffPageState extends State<InviteStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    context.read<StaffManagementBloc>().add(const LoadStaff());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit(List<StaffRole> roles) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role.')),
      );
      return;
    }

    context.read<StaffManagementBloc>().add(
          InviteStaff(
            invite: StaffInvite(
              email: _emailController.text.trim(),
              name: _nameController.text.trim(),
              roleId: _selectedRoleId!,
              message: _messageController.text.trim().isEmpty
                  ? null
                  : _messageController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StaffManagementBloc, StaffManagementState>(
        listener: (context, state) {
          if (state is StaffActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is StaffManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final roles =
              state is StaffManagementLoaded ? state.roles : <StaffRole>[];
          final isBusy = state is StaffActionInProgress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Invite Staff Member',
                    subtitle: 'Send an email invitation to a new team member.',
                    actions: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Jane Smith',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'jane@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required.';
                                }
                                final emailRx = RegExp(
                                    r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$');
                                if (!emailRx.hasMatch(v.trim())) {
                                  return 'Enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedRoleId,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                              ),
                              items: roles
                                  .map((r) => DropdownMenuItem(
                                        value: r.id,
                                        child: Text(r.name),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedRoleId = v),
                              validator: (v) =>
                                  v == null ? 'Please select a role.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                labelText: 'Personal Message (optional)',
                                hintText:
                                    'Looking forward to working with you!',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 4,
                              maxLength: 500,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed:
                                  isBusy ? null : () => _submit(roles),
                              icon: isBusy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(
                                  isBusy ? 'Sending…' : 'Send Invitation'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
