import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/referral_list_item.dart';

/// Displays the user's full referral history with per-entry status tracking.
///
/// Supports pull-to-refresh and empty/error states.
///
/// Expects a [ReferralBloc] available via [BlocProvider].
class ReferralHistoryPage extends StatefulWidget {
  /// Creates a [ReferralHistoryPage].
  const ReferralHistoryPage({super.key});

  /// Named route for navigation.
  static const routeName = '/referrals/history';

  @override
  State<ReferralHistoryPage> createState() => _ReferralHistoryPageState();
}

class _ReferralHistoryPageState extends State<ReferralHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralBloc>().add(const LoadReferrals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral History'),
      ),
      body: BlocBuilder<ReferralBloc, ReferralState>(
        builder: (context, state) {
          if (state is ReferralLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReferralError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ReferralBloc>().add(const LoadReferrals()),
            );
          }
          if (state is ReferralsLoaded) {
            final referrals = state.referrals;
            if (referrals.isEmpty) {
              return const _EmptyHistory();
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ReferralBloc>().add(const LoadReferrals()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: referrals.length,
                itemBuilder: (_, i) => ReferralListItem(
                  referral: referrals[i],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'No referral history yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your referrals will appear here once you start sharing.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
