import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/constants/app_constants.dart';
import 'package:workzy/models/user_model.dart';
import 'package:workzy/services/auth_service.dart';
import 'package:workzy/services/api_service.dart';
import 'package:workzy/services/storage_service.dart';

// Auth state
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final ApiService _apiService;

  AuthNotifier(this._authService, this._apiService)
      : super(const AuthState(status: AuthStatus.initial)) {
    _init();
  }

  /// Initialize auth state from local token
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final user = await _authService.getMe();
    
    if (user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // ─── Sign In ─────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithEmail(email, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Incorrect email or password.',
      );
    }
  }

  // ─── Register ────────────────────────────────────────────────

  Future<void> register(
      String name, String email, String phone, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.registerWithEmail(name, email, password, role, phone, '');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Email might already be in use.',
      );
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Not implemented on backend yet
      throw UnimplementedError('Google sign in is not supported yet');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed. Please try again.',
      );
    }
  }

  // ─── Role ────────────────────────────────────────────────────

  Future<void> setRole(String role) async {
    // Requires backend endpoint for updating role. Not doing it yet.
  }

  // ─── Sign Out ────────────────────────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ─── Password Reset ─────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
    } catch (e) {
      state = state.copyWith(error: 'Password reset is not supported yet.');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  /// Re-fetches the user profile from API and refreshes local state.
  Future<void> refreshUser() async {
    final updated = await _authService.getMe();
    if (updated != null) {
      state = state.copyWith(user: updated);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ─── Providers ───────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
// Temporary alias for migration
final firestoreServiceProvider = apiServiceProvider;
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(apiServiceProvider),
  );
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isCustomerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user?.role == AppConstants.roleCustomer;
});
