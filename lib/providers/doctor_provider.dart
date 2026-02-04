import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();

  List<Doctor> _nearbyDoctors = [];
  bool _isLoading = false;
  String? _error;

  List<Doctor> get nearbyDoctors => _nearbyDoctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> fetchNearbyDoctors({double? lat, double? lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📡 Fetching doctors from API...');
      final response = await _doctorService.getNearbyDoctors(
        lat: lat,
        lng: lng,
      );

      debugPrint('📥 API Response:');
      debugPrint('   - Success: ${response['success']}');
      debugPrint(
        '   - Data count: ${(response['data'] as List?)?.length ?? 0}',
      );

      if (response['success'] == true) {
        List<dynamic> data = [];

        // Fix: Handle both List and Map (paginated) responses
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['data'] is Map<String, dynamic>) {
          // Try common pagination keys
          final mapData = response['data'] as Map<String, dynamic>;
          if (mapData.containsKey('docs')) {
            data = mapData['docs'];
          } else if (mapData.containsKey('items')) {
            data = mapData['items'];
          } else if (mapData.containsKey('doctors')) {
            data = mapData['doctors'];
          } else {
            // If no known key, maybe the map itself is a single object?
            // But for 'nearby' we expect a list.
            // It's safer to leave it empty or log a warning if structure is unknown.
            debugPrint('⚠️ Unknown data structure: $mapData');
          }
        }

        debugPrint('✅ Fetched ${data.length} doctors raw data');

        // Parse to Doctor objects
        _nearbyDoctors = data.map((json) => Doctor.fromJson(json)).toList();

        debugPrint('✅ Successfully parsed ${_nearbyDoctors.length} doctors');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to fetch doctors';
        debugPrint('❌ API Error: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Error: $e';
      debugPrint('❌ Exception in fetchNearbyDoctors:');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearDoctors() {
    debugPrint('🗑️ Clearing doctors list');
    _nearbyDoctors = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
