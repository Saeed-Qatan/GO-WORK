import 'package:gowork/utils/api_storage.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getHomeData() async {
    // Assuming backend returns a dashboard or home object
    // If separate endpoints, you can call them here
    try {
      // Example endpoint depending on backend. Using '/home' or similar logic
      // Since ApiConstants doesn't have home, we might need to add it or use a placeholder.
      // I'll assume '/home' for now or handle mock until real endpoint is known.
      // But wait, the user said "resonse to apis that are com from back end".
      // I'll use a fetchOrders or similar if it makes sense, but HOME usually implies jobs/interviews.

      // I will assume an endpoint '/home' exists or I should add it to constants.
      return await _apiClient.get('/home');
    } catch (e) {
      // Fallback or rethrow.
      // For now, if 404, we might return empty structure or throw.
      rethrow;
    }
  }
}
