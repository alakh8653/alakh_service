import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// The main onboarding container page.
///
/// It listens to [OnboardingBloc] and renders:
/// * a [PageView] of [OnboardingStepWidget]s,
/// * a [StepIndicator] showing current progress,
/// * "Skip" (top-right) and "Next / Get Started" (bottom) action buttons.
class OnboardingPage extends StatefulWidget {
  /// Route name for named navigation.
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<OnboardingBloc>().add(const LoadOnboardingSteps());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingInProgress) {
          _animateTo(state.currentIndex);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: switch (state) {
              OnboardingLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              OnboardingError(:final message) => _ErrorView(message: message),
              OnboardingInProgress() => _StepsView(
                  state: state,
                  pageController: _pageController,
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _StepsView extends StatelessWidget {
  final OnboardingInProgress state;
  final PageController pageController;

  const _StepsView({required this.state, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return Column(
      children: [
        // Skip button
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => bloc.add(const SkipOnboarding()),
            child: const Text('Skip'),
          ),
        ),

        // Slides
        Expanded(
          child: PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.steps.length,
            itemBuilder: (context, index) => OnboardingStepWidget(
              key: ValueKey(state.steps[index].id),
              step: state.steps[index],
            ),
          ),
        ),

        // Dot indicators
        StepIndicator(
          stepCount: state.steps.length,
          currentIndex: state.currentIndex,
        ),
        const SizedBox(height: 32),

        // Navigation button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FilledButton(
            onPressed: () => bloc.add(const NextStep()),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(state.isLastStep ? 'Get Started' : 'Next'),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context
                  .read<OnboardingBloc>()
                  .add(const LoadOnboardingSteps()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
