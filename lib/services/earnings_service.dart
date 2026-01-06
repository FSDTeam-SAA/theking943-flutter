import '../utils/api_config.dart';
import 'api_service.dart';

class EarningService {
  /// Get earnings overview
  /// view: "daily", "weekly", "monthly"
  Future<Map<String, dynamic>> getEarningsOverview({
    String view = 'weekly',
  }) async {
    try {
      print('📤 Fetching earnings overview: $view');

      final response = await ApiService.get(
        '/api/v1/appointment/earnings/overview?view=$view',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        print('✅ Earnings fetched successfully');
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
}