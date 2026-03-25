import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/trust_score_gauge.dart';
import '../widgets/trust_component_bar.dart';

class TrustScorePage extends StatefulWidget {
  final String userId;
  const TrustScorePage({super.key, required this.userId});

  @override
  State<TrustScorePage> createState() => _TrustScorePageState();
}

class _TrustScorePageState extends State<TrustScorePage> {
  @override
  void initState() {
    super.initState();
    context.read<TrustBloc>().add(LoadTrustScoreEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Score')),
      body: BlocBuilder<TrustBloc, TrustState>(
        builder: (context, state) {
          if (state is TrustLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrustError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is TrustScoreLoaded) {
            final score = state.score;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TrustScoreGauge(score: score.overall, size: 200),
                  const SizedBox(height: 8),
                  Text(
                    'Trend: ${score.trend >= 0 ? '+' : ''}${score.trend.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: score.trend >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Score Breakdown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 8),
                  ...score.components.entries.map((e) =>
                      TrustComponentBar(label: e.key, value: e.value)),
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
