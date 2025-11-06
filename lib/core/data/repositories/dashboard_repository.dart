import '../models/dashboard_novice_response.dart';
import '../services/dashboard_api_service.dart';

class DashboardRepository {
  DashboardRepository({DashboardApiService? api}) : _api = api ?? DashboardApiService();
  final DashboardApiService _api;

  Future<DashboardNoviceResponse> getNoviceDashboard() async {
    final map = await _api.getNoviceDashboard();
    return DashboardNoviceResponse.fromJson(map);
  }
}
