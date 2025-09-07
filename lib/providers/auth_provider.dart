import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as appwrite;
import '../models/user_model.dart';
import '../services/appwrite_service.dart';

// Auth state enum
enum AuthState { initial, loading, authenticated, unauthenticated }

// Auth state class
class AuthStateData {
  final AuthState state;
  final UserModel? user;
  final String? error;

  AuthStateData({
    required this.state,
    this.user,
    this.error,
  });

  AuthStateData copyWith({
    AuthState? state,
    UserModel? user,
    String? error,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthStateData> {
  AuthNotifier() : super(AuthStateData(state: AuthState.initial)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final appwriteUser = await AppwriteService.getCurrentUser();
      if (appwriteUser != null) {
        final userData = await AppwriteService.getUserData(appwriteUser.$id);

        // Create user model even if collection data doesn't exist
        var user = UserModel(
          id: appwriteUser.$id,
          email: appwriteUser.email,
          name: appwriteUser.name,
          createdAt: DateTime.now(),
          isSeller: true,
        );

        // If we have collection data, update the user model
        if (userData != null) {
          user = UserModel.fromJson({
            ...userData,
            '\$id': appwriteUser.$id,
            'email': appwriteUser.email,
            'name': appwriteUser.name,
          });
        }

        state = AuthStateData(state: AuthState.authenticated, user: user);
      } else {
        state = AuthStateData(state: AuthState.unauthenticated);
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final appwriteUser = await AppwriteService.signUp(email, password, name);
      final userData = await AppwriteService.getUserData(appwriteUser.$id);

      // Create user model even if collection data doesn't exist
      var user = UserModel(
        id: appwriteUser.$id,
        email: appwriteUser.email,
        name: appwriteUser.name,
        createdAt: DateTime.now(),
        isSeller: true,
      );

      // If we have collection data, update the user model
      if (userData != null) {
        user = UserModel.fromJson({
          ...userData,
          '\$id': appwriteUser.$id,
          'email': appwriteUser.email,
          'name': appwriteUser.name,
        });
      }

      state = AuthStateData(state: AuthState.authenticated, user: user);
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final session = await AppwriteService.signIn(email, password);
      final appwriteUser = await AppwriteService.getCurrentUser();
      final userData = await AppwriteService.getUserData(session.userId);

      if (appwriteUser != null) {
        // Create user model even if collection data doesn't exist
        var user = UserModel(
          id: appwriteUser.$id,
          email: appwriteUser.email,
          name: appwriteUser.name,
          createdAt: DateTime.now(),
          isSeller: true,
        );

        // If we have collection data, update the user model
        if (userData != null) {
          user = UserModel.fromJson({
            ...userData,
            '\$id': appwriteUser.$id,
            'email': appwriteUser.email,
            'name': appwriteUser.name,
          });
        }

        state = AuthStateData(state: AuthState.authenticated, user: user);
      } else {
        throw Exception('Failed to get current user after login');
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(state: AuthState.loading);

    try {
      await AppwriteService.signOut();
      state = AuthStateData(state: AuthState.unauthenticated);
    } catch (e) {
      state = AuthStateData(
        state: AuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    if (state.user == null) return;

    try {
      await AppwriteService.updateUserData(state.user!.id, {
        'name': updatedUser.name,
        'email': updatedUser.email,
        'phone': updatedUser.phone,
        'avatarUrl': updatedUser.avatarUrl,
      });

      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  return AuthNotifier();
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider).state;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

// Auth guard provider for protected routes
final authGuardProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.authenticated;
});
