import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dispute_bloc.dart';
import '../bloc/dispute_event.dart';
import '../bloc/dispute_state.dart';
import '../widgets/dispute_type_selector.dart';
import '../../domain/entities/dispute_type.dart';

class CreateDisputePage extends StatefulWidget {
  const CreateDisputePage({super.key});

  @override
  State<CreateDisputePage> createState() => _CreateDisputePageState();
}

class _CreateDisputePageState extends State<CreateDisputePage> {
  final _pageController = PageController();
  final _bookingIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  DisputeType? _selectedType;
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _bookingIdController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _submit() {
    if (_bookingIdController.text.isEmpty ||
        _selectedType == null ||
        _reasonController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    context.read<DisputeBloc>().add(CreateDisputeEvent(
          bookingId: _bookingIdController.text,
          type: _selectedType!,
          reason: _reasonController.text,
          description: _descriptionController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Dispute'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is DisputeCreated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispute created successfully')));
          } else if (state is DisputeError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              LinearProgressIndicator(value: (_currentStep + 1) / 4),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StepBooking(controller: _bookingIdController),
                    _StepType(
                        selectedType: _selectedType,
                        onSelected: (t) => setState(() => _selectedType = t)),
                    _StepDescription(
                        reasonController: _reasonController,
                        descriptionController: _descriptionController),
                    _StepReview(
                        bookingId: _bookingIdController.text,
                        type: _selectedType,
                        reason: _reasonController.text,
                        description: _descriptionController.text),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is DisputeLoading
                        ? null
                        : (_currentStep < 3 ? _nextStep : _submit),
                    child: state is DisputeLoading
                        ? const CircularProgressIndicator()
                        : Text(_currentStep < 3 ? 'Next' : 'Submit Dispute'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepBooking extends StatelessWidget {
  final TextEditingController controller;
  const _StepBooking({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Booking ID',
              hintText: 'Enter booking reference',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepType extends StatelessWidget {
  final DisputeType? selectedType;
  final ValueChanged<DisputeType> onSelected;

  const _StepType({this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dispute Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: DisputeTypeSelector(
                selectedType: selectedType, onSelected: onSelected),
          ),
        ],
      ),
    );
  }
}

class _StepDescription extends StatelessWidget {
  final TextEditingController reasonController;
  final TextEditingController descriptionController;

  const _StepDescription({
    required this.reasonController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Describe the Issue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason (brief)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: descriptionController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                labelText: 'Detailed Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepReview extends StatelessWidget {
  final String bookingId;
  final DisputeType? type;
  final String reason;
  final String description;

  const _StepReview({
    required this.bookingId,
    required this.type,
    required this.reason,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review & Submit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _ReviewRow('Booking ID', bookingId),
          _ReviewRow('Type', type?.displayName ?? '-'),
          _ReviewRow('Reason', reason),
          _ReviewRow('Description', description),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
