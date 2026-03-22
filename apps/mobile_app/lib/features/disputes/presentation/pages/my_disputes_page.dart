import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dispute_bloc.dart';
import '../bloc/dispute_event.dart';
import '../bloc/dispute_state.dart';
import '../widgets/dispute_card.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/dispute_status.dart';
import 'dispute_details_page.dart';
import 'create_dispute_page.dart';

class MyDisputesPage extends StatefulWidget {
  const MyDisputesPage({super.key});

  @override
  State<MyDisputesPage> createState() => _MyDisputesPageState();
}

class _MyDisputesPageState extends State<MyDisputesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DisputeBloc>().add(const LoadDisputesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Disputes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Resolved'),
            Tab(text: 'All'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateDisputePage())),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<DisputeBloc, DisputeState>(
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DisputeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is DisputesLoaded) {
            final disputes = state.disputes;
            final active = disputes.where((d) =>
                d.status != DisputeStatus.resolved &&
                d.status != DisputeStatus.closed).toList();
            final resolved = disputes.where((d) =>
                d.status == DisputeStatus.resolved ||
                d.status == DisputeStatus.closed).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _DisputeList(disputes: active),
                _DisputeList(disputes: resolved),
                _DisputeList(disputes: disputes),
              ],
            );
          }
          return const Center(child: Text('No disputes found.'));
        },
      ),
    );
  }
}

class _DisputeList extends StatelessWidget {
  final List<Dispute> disputes;
  const _DisputeList({required this.disputes});

  @override
  Widget build(BuildContext context) {
    if (disputes.isEmpty) {
      return const Center(child: Text('No disputes in this category.'));
    }
    return ListView.builder(
      itemCount: disputes.length,
      itemBuilder: (context, index) {
        final dispute = disputes[index];
        return DisputeCard(
          dispute: dispute,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DisputeDetailsPage(disputeId: dispute.id),
            ),
          ),
        );
      },
    );
  }
}
