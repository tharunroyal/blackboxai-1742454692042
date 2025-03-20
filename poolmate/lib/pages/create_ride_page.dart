import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import '../models/user.dart';
import '../services/ride_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../widgets/error_dialog.dart';

class CreateRidePage extends StatefulWidget {
  const CreateRidePage({Key? key}) : super(key: key);

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rideService = RideService();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  
  // Mock coordinates - in a real app, these would come from a location picker
  final LatLng _originCoords = const LatLng(37.7749, -122.4194);
  final LatLng _destinationCoords = const LatLng(37.3382, -121.8863);

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createRide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create a DateTime combining the selected date and time
      final DateTime departureTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Mock user data - in a real app, this would come from authentication
      final User mockDriver = User(
        id: 'mock_id',
        name: 'John Doe',
        email: 'john@example.com',
      );

      final ride = Ride(
        id: 'temp_id', // The backend will assign a real ID
        driver: mockDriver,
        origin: _originController.text,
        destination: _destinationController.text,
        originCoords: _originCoords,
        destinationCoords: _destinationCoords,
        departureTime: departureTime,
        availableSeats: int.parse(_seatsController.text),
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
      );

      await _rideService.createRide(ride);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Location Inputs
            InputField(
              label: 'Pick-up Location',
              controller: _originController,
              prefixIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pick-up location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Drop-off Location',
              controller: _destinationController,
              prefixIcon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter drop-off location';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date and Time Selection
            Text(
              'Departure Date & Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: dateFormat.format(_selectedDate),
                    onPressed: _selectDate,
                    icon: Icons.calendar_today,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: _selectedTime.format(context),
                    onPressed: _selectTime,
                    icon: Icons.access_time,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Price and Seats
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'Price per Seat',
                    controller: _priceController,
                    prefixIcon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    label: 'Available Seats',
                    controller: _seatsController,
                    prefixIcon: Icons.event_seat,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter seats';
                      }
                      final seats = int.tryParse(value);
                      if (seats == null || seats <= 0) {
                        return 'Invalid seats';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Information
            InputField(
              label: 'Additional Information (Optional)',
              controller: _descriptionController,
              maxLines: 3,
              hint: 'Add any important details about the ride...',
            ),
            const SizedBox(height: 32),

            // Create Button
            CustomButton(
              text: 'Create Ride',
              onPressed: _createRide,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}