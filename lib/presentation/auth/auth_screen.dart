import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/errors/failures.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/status_views.dart';
import 'auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go(AppRoutes.home);
            }
            final error = state.error;
            if (error != null) {
              final message = _errorMessage(context, error);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          },
          builder: (context, state) {
            if (state.status == AuthStatus.loading) {
              return const AppLoadingView();
            }
            return _buildForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.forum_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            loc.appName,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: loc.signIn),
              Tab(text: loc.createAccount),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    final isRegister = _tabController.index == 1;
                    return Column(
                      children: [
                        if (isRegister) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: loc.displayName,
                              hintText: loc.displayNameHint,
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: isRegister
                                ? (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? loc.enterName
                                        : null
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: InputDecoration(
                              labelText: loc.username,
                              hintText: loc.usernameHint,
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: loc.email,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return loc.enterEmail;
                            }
                            if (!v.contains('@')) return loc.invalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: loc.password,
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return loc.enterPassword;
                            }
                            if (isRegister && v.length < 6) {
                              return loc.minPasswordLength;
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) return;
                    final bloc = context.read<AuthBloc>();
                    if (_tabController.index == 1) {
                      bloc.add(SignUpRequested(
                        email: _emailCtrl.text.trim(),
                        password: _passwordCtrl.text,
                        displayName: _nameCtrl.text.trim(),
                        username: _usernameCtrl.text.trim(),
                      ));
                    } else {
                      bloc.add(SignInRequested(
                        email: _emailCtrl.text.trim(),
                        password: _passwordCtrl.text,
                      ));
                    }
                  },
                  child: Text(
                    _tabController.index == 1 ? loc.createAccount : loc.signIn,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => _showForgotPassword(context),
                  child: Text(loc.forgotPassword),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.resetPassword),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: loc.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              final email = controller.text.trim();
              Navigator.of(dialogContext).pop();
              if (email.isEmpty) return;
              context.read<AuthBloc>().add(
                    PasswordResetRequested(email: email),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.resetPasswordSent)),
              );
            },
            child: Text(loc.send),
          ),
        ],
      ),
    );
  }

  String _errorMessage(BuildContext context, Failure failure) {
    final loc = AppLocalizations.of(context)!;
    if (failure is AuthFailure) {
      final m = failure.message.toLowerCase();
      if (m.contains('invalid login credentials')) return loc.wrongPassword;
      if (m.contains('already registered')) return loc.emailAlreadyInUse;
      if (m.contains('password')) return loc.weakPassword;
      if (m.contains('email')) return loc.invalidEmail;
      return failure.message;
    }
    if (failure is NetworkFailure) return loc.noInternet;
    return loc.somethingWentWrong;
  }
}