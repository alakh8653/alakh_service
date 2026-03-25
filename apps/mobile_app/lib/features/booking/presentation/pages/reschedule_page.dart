import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../bloc/bloc.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/time_slot_grid.dart';

/// Allows rescheduling of an existing booking.
///
/// Functionally similar to [BookingPage] but operates on an existing booking.
class ReschedulePage extends StatefulWidget {
  /// The identifier of the booking to reschedule.
  final String bookingId;

  /// Optional shop and service info to reload slots.
  final String? shopId;
  final String? serviceId;

  const ReschedulePage({
    super.key,
    required this.bookingId,
    this.shopId,
    this.serviceId,
  });

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  String? _reason;

  @override
  void initState() {
    super.initState();
    if (widget.shopId != null && widget.serviceId != null) {
      _fetchSlots();
    }
  }

  void _fetchSlots() {
    context.read<BookingBloc>().add(LoadSlots(
          shopId: widget.shopId!,
          serviceId: widget.serviceId!,
          date: _selectedDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reschedule Booking')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingRescheduled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Booking rescheduled successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Choose a new date and time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                    _selectedSlot = null;
                  });
                  if (widget.shopId != null && widget.serviceId != null) {
                    _fetchSlots();
                  }
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state is SlotsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is SlotsLoaded
                        ? TimeSlotGrid(
                            slots: state.slots,
                            selectedSlot: _selectedSlot,
                            onSlotSelected: (slot) =>
                                setState(() => _selectedSlot = slot),
                          )
                        : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Reason for rescheduling (optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _reason = v,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _canConfirm(state) ? _confirm : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: state is BookingCreating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirm Reschedule'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _canConfirm(BookingState state) =>
      _selectedSlot != null && state is! BookingCreating;

  void _confirm() {
    if (_selectedSlot == null) return;
    context.read<BookingBloc>().add(
          RescheduleBooking(
            RescheduleParams(
              bookingId: widget.bookingId,
              newTimeSlotId: _selectedSlot!.id,
              reason: _reason,
            ),
          ),
        );
  }
}
