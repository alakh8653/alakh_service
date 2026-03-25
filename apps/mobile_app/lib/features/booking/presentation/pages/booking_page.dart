import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import 'booking_confirmation_page.dart';

/// A two-step booking flow: date/time/staff selection → confirmation.
class BookingPage extends StatefulWidget {
  /// The shop being booked.
  final String shopId;

  /// The shop display name.
  final String shopName;

  /// The service being booked.
  final String serviceId;

  /// The service display name.
  final String serviceName;

  /// Duration of the service in minutes.
  final int durationMinutes;

  /// Price of the service.
  final double price;

  /// The currently authenticated user's identifier.
  final String userId;

  const BookingPage({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.serviceId,
    required this.serviceName,
    required this.durationMinutes,
    required this.price,
    required this.userId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _currentStep = 0;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  StaffItem? _selectedStaff;
  String? _notes;

  // Mock staff list – replace with real data injection.
  final List<StaffItem> _staffList = const [
    StaffItem(id: 'any', name: 'Any'),
    StaffItem(id: 's1', name: 'Alice'),
    StaffItem(id: 's2', name: 'Bob'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  void _fetchSlots() {
    context.read<BookingBloc>().add(LoadSlots(
          shopId: widget.shopId,
          serviceId: widget.serviceId,
          date: _selectedDate,
          staffId: _selectedStaff?.id == 'any' ? null : _selectedStaff?.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BookingConfirmationPage(booking: state.booking),
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            controlsBuilder: _buildStepControls,
            steps: [
              _buildSelectionStep(state),
              _buildConfirmationStep(),
            ],
          );
        },
      ),
    );
  }

  Step _buildSelectionStep(BookingState state) {
    return Step(
      title: const Text('Select Date & Time'),
      isActive: _currentStep >= 0,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
              });
              _fetchSlots();
            },
          ),
          const SizedBox(height: 16),
          if (state is SlotsLoading)
            const Center(child: CircularProgressIndicator())
          else if (state is SlotsLoaded)
            TimeSlotGrid(
              slots: state.slots,
              selectedSlot: _selectedSlot,
              onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 16),
          StaffSelector(
            staffList: _staffList,
            selectedStaffId: _selectedStaff?.id,
            onStaffSelected: (staff) {
              setState(() => _selectedStaff = staff);
              _fetchSlots();
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (v) => _notes = v,
            ),
          ),
        ],
      ),
    );
  }

  Step _buildConfirmationStep() {
    return Step(
      title: const Text('Confirm Booking'),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          ServiceSummaryWidget(
            serviceName: widget.serviceName,
            durationMinutes: widget.durationMinutes,
            price: widget.price,
          ),
          const SizedBox(height: 16),
          if (_selectedSlot != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule_rounded),
                title: Text('Selected Slot'),
                subtitle: Text(
                  _selectedSlot!.startTime.toString(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 1;
    final state = context.watch<BookingBloc>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: isLastStep ? _confirmBooking : details.onStepContinue,
            child: state is BookingCreating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(isLastStep ? 'Confirm Booking' : 'Next'),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0 && _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _confirmBooking() {
    if (_selectedSlot == null) return;
    context.read<BookingBloc>().add(
          CreateBooking(
            CreateBookingParams(
              userId: widget.userId,
              shopId: widget.shopId,
              serviceId: widget.serviceId,
              timeSlotId: _selectedSlot!.id,
              staffId:
                  _selectedStaff?.id == 'any' ? null : _selectedStaff?.id,
              notes: _notes,
            ),
          ),
        );
  }
}
