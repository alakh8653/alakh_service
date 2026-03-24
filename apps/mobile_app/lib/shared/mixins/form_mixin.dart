/// Mixin for [StatefulWidget] states that manage a [GlobalKey<FormState>].
library;

import 'package:flutter/widgets.dart';

/// Provides form key management, validation, dirty-checking, and submission
/// helpers to any [State] class.
///
/// ### Usage:
/// ```dart
/// class _LoginFormState extends State<LoginForm> with FormMixin {
///   @override
///   Widget build(BuildContext context) {
///     return Form(
///       key: formKey,
///       child: Column(children: [
///         // fields ...
///         ElevatedButton(onPressed: submitForm, child: const Text('Login')),
///       ]),
///     );
///   }
/// }
/// ```
mixin FormMixin<T extends StatefulWidget> on State<T> {
  /// The [GlobalKey] that must be passed to the [Form] widget.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isDirty = false;
  bool _isSubmitting = false;

  /// Returns `true` when the user has modified at least one field.
  bool get isDirty => _isDirty;

  /// Returns `true` while an async form submission is in progress.
  bool get isSubmitting => _isSubmitting;

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Validates the form and returns `true` when all fields pass.
  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Saves the form state (calls [FormField.onSaved] on each field).
  void saveForm() => formKey.currentState?.save();

  /// Resets the form to its initial values and clears dirty flag.
  void resetForm() {
    formKey.currentState?.reset();
    setStateIfMounted(() => _isDirty = false);
  }

  // ---------------------------------------------------------------------------
  // Dirty tracking
  // ---------------------------------------------------------------------------

  /// Call from any field's `onChanged` callback to mark the form as dirty.
  void markDirty() {
    if (!_isDirty) setStateIfMounted(() => _isDirty = true);
  }

  // ---------------------------------------------------------------------------
  // Submission
  // ---------------------------------------------------------------------------

  /// Validates, saves, and then calls [onSubmit] if validation passes.
  ///
  /// Sets [isSubmitting] during the async operation and clears it afterwards.
  Future<void> submitForm(Future<void> Function() onSubmit) async {
    if (_isSubmitting) return;
    if (!validateForm()) return;
    saveForm();

    setStateIfMounted(() => _isSubmitting = true);
    try {
      await onSubmit();
    } finally {
      setStateIfMounted(() => _isSubmitting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// Calls [setState] only when the widget is still mounted.
  @protected
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
