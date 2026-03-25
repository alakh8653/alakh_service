import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dispute_bloc.dart';
import '../bloc/dispute_event.dart';
import '../bloc/dispute_state.dart';
import '../widgets/evidence_upload_widget.dart';
import '../../domain/entities/dispute_evidence.dart';

class SubmitEvidencePage extends StatefulWidget {
  final String disputeId;
  const SubmitEvidencePage({super.key, required this.disputeId});

  @override
  State<SubmitEvidencePage> createState() => _SubmitEvidencePageState();
}

class _SubmitEvidencePageState extends State<SubmitEvidencePage> {
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  EvidenceType _selectedType = EvidenceType.photo;

  @override
  void dispose() {
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<DisputeBloc>().add(SubmitEvidenceEvent(
          disputeId: widget.disputeId,
          evidenceType: _selectedType,
          url: _urlController.text,
          description: _descriptionController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Evidence')),
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is EvidenceSubmitted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Evidence submitted')));
          } else if (state is DisputeError) {
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
                const Text('Upload Evidence',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                EvidenceUploadWidget(
                  onUpload: (type, source) {
                    setState(() => _selectedType = type);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'File URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is DisputeLoading ? null : _submit,
                    child: state is DisputeLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Evidence'),
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
