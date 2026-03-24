import 'package:flutter/material.dart';

import '../../domain/entities/queue_entry.dart';
import '../../domain/usecases/get_queue_history_usecase.dart';
import '../widgets/queue_status_badge.dart';

/// Page displaying the authenticated user's historical queue entries.
///
/// Calls [GetQueueHistoryUseCase] directly; it is intentionally decoupled from
/// [QueueBloc] because history is read-only and does not affect active-queue
/// state managed by the BLoC.
class QueueHistoryPage extends StatefulWidget {
  /// Use case injected from the DI container.
  final GetQueueHistoryUseCase getQueueHistoryUseCase;

  /// Creates a [QueueHistoryPage].
  const QueueHistoryPage({
    super.key,
    required this.getQueueHistoryUseCase,
  });

  /// Named route for this page.
  static const routeName = '/queue/history';

  @override
  State<QueueHistoryPage> createState() => _QueueHistoryPageState();
}

class _QueueHistoryPageState extends State<QueueHistoryPage> {
  List<QueueEntry>? _history;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.getQueueHistoryUseCase(
      const GetQueueHistoryParams(),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (entries) => setState(() {
        _history = entries;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final history = _history ?? [];

    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No queue history yet.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _QueueHistoryTile(entry: history[index]),
    );
  }
}

/// A single list tile representing one historical queue entry.
class _QueueHistoryTile extends StatelessWidget {
  final QueueEntry entry;

  const _QueueHistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '#${entry.position}',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        'Queue ${entry.queueId}',
        style: theme.textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDateTime(entry.joinedAt),
        style: theme.textTheme.bodySmall,
      ),
      trailing: QueueStatusBadge(status: entry.status),
    );
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date  $time';
  }
}
