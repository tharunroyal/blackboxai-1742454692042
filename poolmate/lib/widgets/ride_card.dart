import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import 'custom_button.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;
  final bool showJoinButton;

  const RideCard({
    Key? key,
    required this.ride,
    required this.onTap,
    this.showJoinButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: ride.driver.imageUrl != null
                        ? NetworkImage(ride.driver.imageUrl!)
                        : null,
                    child: ride.driver.imageUrl == null
                        ? Text(ride.driver.name[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driver.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(ride.departureTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${ride.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLocationInfo(
                context,
                Icons.location_on_outlined,
                'From',
                ride.origin,
              ),
              const SizedBox(height: 8),
              _buildLocationInfo(
                context,
                Icons.location_on,
                'To',
                ride.destination,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_seat_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ride.remainingSeats} seats available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (showJoinButton && ride.hasAvailableSeats)
                    CustomButton(
                      text: 'Join Ride',
                      onPressed: onTap,
                      isOutlined: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    IconData icon,
    String label,
    String location,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                location,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}