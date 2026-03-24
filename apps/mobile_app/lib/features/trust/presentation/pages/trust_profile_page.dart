import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/trust_score_gauge.dart';
import '../widgets/trust_component_bar.dart';
import '../widgets/verification_status_tile.dart';
import '../widgets/badge_card.dart';
import '../widgets/trust_shield_icon.dart';

class TrustProfilePage extends StatefulWidget {
  final String userId;
  const TrustProfilePage({super.key, required this.userId});

  @override
  State<TrustProfilePage> createState() => _TrustProfilePageState();
}

class _TrustProfilePageState extends State<TrustProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<TrustBloc>().add(LoadTrustProfileEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Profile')),
      body: BlocBuilder<TrustBloc, TrustState>(
        builder: (context, state) {
          if (state is TrustLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrustError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is TrustProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TrustScoreGauge(score: profile.score.overall),
                      const SizedBox(width: 24),
                      TrustShieldIcon(score: profile.score.overall),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Score Components',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ...profile.score.components.entries.map((e) =>
                      TrustComponentBar(label: e.key, value: e.value)),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Verifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ...profile.verifications.map(
                    (v) => VerificationStatusTile(verification: v),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Badges',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: profile.badges.map((b) => BadgeCard(badge: b)).toList(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
