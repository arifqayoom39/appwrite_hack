import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthenticatedWidget;

  const AuthGuard({
    Key? key,
    required this.child,
    this.loadingWidget,
    this.unauthenticatedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    switch (authState) {
      case AuthState.loading:
        return loadingWidget ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
      case AuthState.authenticated:
        return child;
      case AuthState.unauthenticated:
        return unauthenticatedWidget ??
            const Scaffold(
              body: Center(
                child: Text('Please log in to access this page'),
              ),
            );
      default:
        return loadingWidget ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
    }
  }
}
