import '../utils/api_config.dart';
import 'api_service.dart';

class EarningService {
  /// Get earnings overview
  /// view: "daily", "weekly", "monthly"
  Future<Map<String, dynamic>> getEarningsOverview({
    String view = 'monthly',
  }) async {
    try {
      print('📤 Fetching earnings overview: $view');

      // ✅ FIXED: Correct endpoint path
      final response = await ApiService.get(
        '${ApiConfig.appointments}/earnings/overview?view=$view',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        print('✅ Earnings fetched successfully');
        print('💰 Total Earnings: ${response['data']?['totalEarnings'] ?? 0}');
        print('📊 Total Appointments: ${response['data']?['totalAppointments'] ?? 0}');
      } else {
        print('❌ Failed to fetch earnings: ${response['message']}');
      }

      return response;
    } catch (e) {
      print('❌ Get Earnings Error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch earnings: $e',
      };
    }
  }

  /// Get detailed earnings breakdown by type
  Future<Map<String, dynamic>> getEarningsBreakdown({
    String view = 'monthly',
  }) async {
    try {
      final response = await getEarningsOverview(view: view);
      
      if (response['success'] == true) {
        final data = response['data'];
        return {
          'success': true,
          'totalEarnings': data['totalEarnings'] ?? 0,
          'totalAppointments': data['totalAppointments'] ?? 0,
          'physicalEarnings': data['physical']?['earnings'] ?? 0,
          'physicalCount': data['physical']?['count'] ?? 0,
          'videoEarnings': data['video']?['earnings'] ?? 0,
          'videoCount': data['video']?['count'] ?? 0,
          'weeklyData': data['weeklyByWeekday'],
        };
      }
      
      return response;
    } catch (e) {
      print('❌ Get Earnings Breakdown Error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch earnings breakdown: $e',
      };
    }
  }
}