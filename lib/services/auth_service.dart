import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/api/api_client.dart';
import '../core/api/rest_client.dart';
import '../core/utils/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final RestClient _restClient;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  AuthService() : _restClient = RestClient(ApiClient().dio);

  // Sign in with email & password
  Future<UserModel> signInWithEmail(String email, String password) async {
    final response = await _restClient.login({
      'email': email,
      'password': password,
    });
    
    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    
    return response.user;
  }

  // Register with email & password
  Future<UserModel> registerWithEmail(String name, String email, String password, String role, String? phone, String? city) async {
    final response = await _restClient.register({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'city': city,
    });
    
    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    
    return response.user;
  }

  // Get current user details from API
  Future<UserModel?> getMe() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    
    try {
      return await _restClient.getMe();
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await TokenStorage.clearTokens();
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}
  }

  // Password reset (Not implemented in backend yet)
  Future<void> sendPasswordReset(String email) async {
    throw UnimplementedError('Password reset not implemented in custom API yet');
  }

  // Delete account (Needs backend endpoint, placeholder for now)
  Future<void> deleteAccount() async {
    await signOut();
    // Implementation for backend delete
  }
}
