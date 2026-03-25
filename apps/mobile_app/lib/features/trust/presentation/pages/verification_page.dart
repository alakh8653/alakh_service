import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/verification_status_tile.dart';
import 'verification_flow_page.dart';
import '../../domain/entities/verification_type.dart';

class VerificationPage extends StatefulWidget {
  final String userId;
  const VerificationPage({super.key, required this.userId});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TrustBloc>()
        .add(LoadVerificationsEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifications')),
      body: BlocBuilder<TrustBloc, TrustState>(
        builder: (context, state) {
          if (state is TrustLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrustError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is VerificationsLoaded) {
            final verifications = state.verifications;
            final verifiedTypes = verifications.map((v) => v.type).toSet();
            final remainingTypes = VerificationType.values
                .where((t) => !verifiedTypes.contains(t))
                .toList();

            return ListView(
              children: [
                if (verifications.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Your Verifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ...verifications.map(
                    (v) => VerificationStatusTile(verification: v),
                  ),
                ],
                if (remainingTypes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Start a Verification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ...remainingTypes.map(
                    (type) => ListTile(
                      leading: Text(type.icon,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(type.displayName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerificationFlowPage(
                            userId: widget.userId,
                            verificationType: type,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
