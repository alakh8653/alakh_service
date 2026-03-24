import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/identity_upload_widget.dart';
import '../../domain/entities/verification_type.dart';

class VerificationFlowPage extends StatefulWidget {
  final String userId;
  final VerificationType verificationType;

  const VerificationFlowPage({
    super.key,
    required this.userId,
    required this.verificationType,
  });

  @override
  State<VerificationFlowPage> createState() => _VerificationFlowPageState();
}

class _VerificationFlowPageState extends State<VerificationFlowPage> {
  final List<String> _uploadedUrls = [];
  String? _frontUrl;
  String? _backUrl;

  void _upload(String side) {
    final url = 'https://placeholder.url/$side/${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      if (side == 'front') _frontUrl = url;
      if (side == 'back') _backUrl = url;
      _uploadedUrls.clear();
      if (_frontUrl != null) _uploadedUrls.add(_frontUrl!);
      if (_backUrl != null) _uploadedUrls.add(_backUrl!);
    });
  }

  void _submit() {
    context.read<TrustBloc>().add(StartVerificationEvent(
          userId: widget.userId,
          type: widget.verificationType,
          documentUrls: _uploadedUrls,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Verify ${widget.verificationType.displayName}')),
      body: BlocConsumer<TrustBloc, TrustState>(
        listener: (context, state) {
          if (state is VerificationStarted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Verification submitted for review')));
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
                Text(
                  'Upload your ${widget.verificationType.displayName} document',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: IdentityUploadWidget(
                        label: 'Front',
                        uploadedUrl: _frontUrl,
                        onUpload: () => _upload('front'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IdentityUploadWidget(
                        label: 'Back',
                        uploadedUrl: _backUrl,
                        onUpload: () => _upload('back'),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _uploadedUrls.isEmpty || state is TrustLoading
                        ? null
                        : _submit,
                    child: state is TrustLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit for Review'),
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
