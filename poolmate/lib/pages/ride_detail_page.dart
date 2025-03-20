import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import '../services/ride_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_dialog.dart';

class RideDetailPage extends StatefulWidget {
  const RideDetailPage({Key? key}) : super(key: key);

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  final RideService _rideService = RideService();
  bool _isJoining = false;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _addMarkersAndPolyline();
  }

  void _addMarkersAndPolyline() {
    final ride = ModalRoute.of(context)!.settings.arguments as Ride;

    // Add origin marker
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: ride.originCoords,
        infoWindow: InfoWindow(title: 'Start: ${ride.origin}'),
      ),
    );

    // Add destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: ride.destinationCoords,
        infoWindow: InfoWindow(title: 'End: ${ride.destination}'),
      ),
    );

    // Add polyline between origin and destination
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [ride.originCoords, ride.destinationCoords],
        color: Theme.of(context).primaryColor,
        width: 3,
      ),
    );

    // Adjust camera to show both markers
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            ride.originCoords.latitude < ride.destinationCoords.latitude
                ? ride.originCoords.latitude
                : ride.destinationCoords.latitude,
            ride.originCoords.longitude < ride.destinationCoords.longitude
                ? ride.originCoords.longitude
                : ride.destinationCoords.longitude,
          ),
          northeast: LatLng(
            ride.originCoords.latitude > ride.destinationCoords.latitude
                ? ride.originCoords.latitude
                : ride.destinationCoords.latitude,
            ride.originCoords.longitude > ride.destinationCoords.longitude
                ? ride.originCoords.longitude
                : ride.destinationCoords.longitude,
          ),
        ),
        100, // padding
      ),
    );
  }

  Future<void> _joinRide(String rideId) async {
    setState(() => _isJoining = true);

    try {
      await _rideService.joinRide(rideId, 'current_user_id'); // Replace with actual user ID
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate successful join
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
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = ModalRoute.of(context)!.settings.arguments as Ride;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, y • h:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: ride.originCoords,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: ride.driver.imageUrl != null
                            ? NetworkImage(ride.driver.imageUrl!)
                            : null,
                        child: ride.driver.imageUrl == null
                            ? Text(
                                ride.driver.name[0].toUpperCase(),
                                style: theme.textTheme.headlineMedium,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driver.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Driver',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Ride Details
                  Text(
                    'Ride Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    Icons.calendar_today,
                    'Date & Time',
                    dateFormat.format(ride.departureTime),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    Icons.location_on_outlined,
                    'Pick-up Location',
                    ride.origin,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    Icons.location_on,
                    'Drop-off Location',
                    ride.destination,
                  ),
                  if (ride.additionalStops.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      theme,
                      Icons.more_horiz,
                      'Stops',
                      ride.additionalStops.join(', '),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    Icons.event_seat_outlined,
                    'Available Seats',
                    '${ride.remainingSeats} out of ${ride.availableSeats}',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    Icons.attach_money,
                    'Price per Seat',
                    '\$${ride.price.toStringAsFixed(2)}',
                  ),
                  if (ride.description.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(
                      'Additional Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ride.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ride.hasAvailableSeats
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Join Ride • \$${ride.price.toStringAsFixed(2)}',
                onPressed: () => _joinRide(ride.id),
                isLoading: _isJoining,
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(
                'This ride is full',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}