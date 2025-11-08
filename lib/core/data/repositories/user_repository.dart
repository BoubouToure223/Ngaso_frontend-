import '../models/user_me_response.dart';
import '../services/user_api_service.dart';

class UserRepository {
  UserRepository({UserApiService? api}) : _api = api ?? UserApiService();
  final UserApiService _api;

  Future<UserMeResponse> getMe() async {
    final map = await _api.getMe();
    return UserMeResponse.fromJson(map);
  }
}
