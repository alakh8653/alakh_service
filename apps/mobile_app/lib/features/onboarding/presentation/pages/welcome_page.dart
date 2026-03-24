import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

/// A full-screen welcome / splash shown before the step-by-step onboarding
/// slides.  Tapping "Get Started" dispatches [LoadOnboardingSteps].
class WelcomePage extends StatelessWidget {
  /// Route name for named navigation.
  static const routeName = '/onboarding/welcome';

  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App logo / hero image
              Icon(
                Icons.handyman_rounded,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32),

              Text(
                'Welcome to Alakh',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Your trusted marketplace for home services.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              // Primary CTA
              FilledButton(
                onPressed: () =>
                    context.read<OnboardingBloc>().add(const LoadOnboardingSteps()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
