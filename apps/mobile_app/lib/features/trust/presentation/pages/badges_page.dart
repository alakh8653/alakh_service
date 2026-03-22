import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trust_bloc.dart';
import '../bloc/trust_event.dart';
import '../bloc/trust_state.dart';
import '../widgets/badge_card.dart';

class BadgesPage extends StatefulWidget {
  final String userId;
  const BadgesPage({super.key, required this.userId});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrustBloc>().add(LoadBadgesEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: BlocBuilder<TrustBloc, TrustState>(
        builder: (context, state) {
          if (state is TrustLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrustError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BadgesLoaded) {
            if (state.badges.isEmpty) {
              return const Center(child: Text('No badges earned yet'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.badges.length,
              itemBuilder: (context, index) =>
                  BadgeCard(badge: state.badges[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
