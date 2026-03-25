import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/safety_report_card.dart';

class SafetyReportPage extends StatefulWidget {
  final String userId;
  final String? reportedUserId;

  const SafetyReportPage({
    super.key,
    required this.userId,
    this.reportedUserId,
  });

  @override
  State<SafetyReportPage> createState() => _SafetyReportPageState();
}

class _SafetyReportPageState extends State<SafetyReportPage> {
  final _reportedUserController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.reportedUserId != null) {
      _reportedUserController.text = widget.reportedUserId!;
    }
  }

  @override
  void dispose() {
    _reportedUserController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<TrustBloc>().add(SubmitSafetyReportEvent(
          reportedUserId: _reportedUserController.text,
          type: _typeController.text,
          description: _descriptionController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Report')),
      body: BlocConsumer<TrustBloc, TrustState>(
        listener: (context, state) {
          if (state is SafetyReportSubmitted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safety report submitted')));
          } else if (state is TrustError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Report a Safety Concern',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _reportedUserController,
                  decoration: const InputDecoration(
                    labelText: 'Reported User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is TrustLoading ? null : _submit,
                    child: state is TrustLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
