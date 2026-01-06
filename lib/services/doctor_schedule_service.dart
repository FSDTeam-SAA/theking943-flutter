import '../utils/api_config.dart';
import 'api_service.dart';

class DoctorScheduleService {
  /// Save doctor's weekly schedule
  Future<Map<String, dynamic>> saveWeeklySchedule({
    required List<Map<String, dynamic>> weeklySchedule,
    required Map<String, dynamic> fees,
  }) async {
    try {
      print('📤 Saving doctor schedule...');

      // Format data for backend
      final body = {
        'weeklySchedule': weeklySchedule.map((day) {
          return {
            'day': day['day'].toString().toLowerCase(), // "monday", "tuesday"
            'isActive': day['enabled'] ?? false,
            'slots': (day['slots'] as List).map((slot) {
              return {
                'start': _convert12To24Hour(slot['start']),
                'end': _convert12To24Hour(slot['end']),
              };
            }).toList(),
          };
        }).toList(),
        'fees': fees,
      };

      print('📦 Schedule data: ${body.toString()}');

      // ✅ Correct endpoint: PUT /api/v1/user/profile
      final response = await ApiService.put(
        '/api/v1/user/profile',
        body,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        print('✅ Schedule saved successfully');
      }

      return response;
    } catch (e) {
      print('❌ Save Schedule Error: $e');
      return {
        'success': false,
        'message': 'Failed to save schedule: $e',
      };
    }
  }

  /// Convert 12-hour format to 24-hour format
  /// "10:30 AM" → "10:30"
  /// "02:30 PM" → "14:30"
  String _convert12To24Hour(String time12) {
    try {
      final cleaned = time12.trim().toUpperCase();
      final parts = cleaned.split(' ');
      
      if (parts.length != 2) return time12;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return time12;

      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final period = parts[1];

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      print('⚠️ Time conversion error: $e');
      return time12;
    }
  }

  /// Get doctor's current schedule
  Future<Map<String, dynamic>> getMySchedule() async {
    try {
      // ✅ Correct endpoint: GET /api/v1/user/profile
      final response = await ApiService.get(
        '/api/v1/user/profile',
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      print('❌ Get Schedule Error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch schedule: $e',
      };
    }
  }
}