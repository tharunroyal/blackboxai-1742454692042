import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user.dart';

class Ride {
  final String id;
  final User driver;
  final String origin;
  final String destination;
  final LatLng originCoords;
  final LatLng destinationCoords;
  final DateTime departureTime;
  final int availableSeats;
  final double price;
  final List<String> additionalStops;
  final String description;
  final List<String> joinedUserIds;

  Ride({
    required this.id,
    required this.driver,
    required this.origin,
    required this.destination,
    required this.originCoords,
    required this.destinationCoords,
    required this.departureTime,
    required this.availableSeats,
    required this.price,
    this.additionalStops = const [],
    this.description = '',
    this.joinedUserIds = const [],
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      driver: User.fromJson(json['driver'] as Map<String, dynamic>),
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      originCoords: LatLng(
        json['originCoords']['latitude'] as double,
        json['originCoords']['longitude'] as double,
      ),
      destinationCoords: LatLng(
        json['destinationCoords']['latitude'] as double,
        json['destinationCoords']['longitude'] as double,
      ),
      departureTime: DateTime.parse(json['departureTime'] as String),
      availableSeats: json['availableSeats'] as int,
      price: (json['price'] as num).toDouble(),
      additionalStops: List<String>.from(json['additionalStops'] ?? []),
      description: json['description'] as String? ?? '',
      joinedUserIds: List<String>.from(json['joinedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver.toJson(),
      'origin': origin,
      'destination': destination,
      'originCoords': {
        'latitude': originCoords.latitude,
        'longitude': originCoords.longitude,
      },
      'destinationCoords': {
        'latitude': destinationCoords.latitude,
        'longitude': destinationCoords.longitude,
      },
      'departureTime': departureTime.toIso8601String(),
      'availableSeats': availableSeats,
      'price': price,
      'additionalStops': additionalStops,
      'description': description,
      'joinedUserIds': joinedUserIds,
    };
  }

  bool get hasAvailableSeats => availableSeats > joinedUserIds.length;
  
  int get remainingSeats => availableSeats - joinedUserIds.length;

  Ride copyWith({
    String? id,
    User? driver,
    String? origin,
    String? destination,
    LatLng? originCoords,
    LatLng? destinationCoords,
    DateTime? departureTime,
    int? availableSeats,
    double? price,
    List<String>? additionalStops,
    String? description,
    List<String>? joinedUserIds,
  }) {
    return Ride(
      id: id ?? this.id,
      driver: driver ?? this.driver,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originCoords: originCoords ?? this.originCoords,
      destinationCoords: destinationCoords ?? this.destinationCoords,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      additionalStops: additionalStops ?? this.additionalStops,
      description: description ?? this.description,
      joinedUserIds: joinedUserIds ?? this.joinedUserIds,
    );
  }
}