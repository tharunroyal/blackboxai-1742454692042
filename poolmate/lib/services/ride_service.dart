import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ride.dart';

class RideService {
  static const String baseUrl = 'https://api.poolmate.com'; // Replace with your actual API endpoint

  Future<List<Ride>> listRides() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rides'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['rides'];
        return data.map((json) => Ride.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch rides');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<Ride> getRideDetail(String rideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rides/$rideId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Ride.fromJson(data['ride']);
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch ride details');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<Ride> createRide(Ride ride) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rides'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ride.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Ride.fromJson(data['ride']);
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create ride');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<void> joinRide(String rideId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rides/$rideId/join'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to join ride');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<void> cancelRide(String rideId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rides/$rideId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel ride');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<List<Ride>> getUserRides(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/rides'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['rides'];
        return data.map((json) => Ride.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch user rides');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }
}