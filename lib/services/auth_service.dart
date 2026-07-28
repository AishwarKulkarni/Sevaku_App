import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
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
    await TokenStorage.saveUser(response.user);
    
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
    await TokenStorage.saveUser(response.user);
    
    return response.user;
  }

  // Get current user details from API
  Future<UserModel?> getMe() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    
    try {
      final user = await _restClient.getMe();
      await TokenStorage.saveUser(user);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await signOut();
        return null;
      }
      return await TokenStorage.getUser();
    } catch (e) {
      return await TokenStorage.getUser();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await TokenStorage.clearTokens();
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}
  }

  // Password reset
  Future<String?> sendPasswordReset(String email) async {
    final response = await _restClient.forgotPassword({'email': email});
    // For dev purposes we might get the OTP back in the response
    return response['dev_otp'] as String?;
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await _restClient.resetPassword({
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  // Delete account
  Future<void> deleteAccount() async {
    await _restClient.deleteAccount();
    await signOut();
  }
}
