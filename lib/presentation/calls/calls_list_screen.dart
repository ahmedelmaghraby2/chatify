import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/call.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/call_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/status_views.dart';
import '../shared/time_formatter.dart';
import 'calls_cubit.dart';

class CallsListScreen extends StatelessWidget {
  const CallsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CallsCubit(callRepository: sl.get<CallRepository>()),
      child: const _CallsListView(),
    );
  }
}

class _CallsListView extends StatelessWidget {
  const _CallsListView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.calls)),
      body: BlocBuilder<CallsCubit, CallsState>(
        builder: (context, state) {
          if (state.loading && state.calls.isEmpty) {
            return const AppLoadingView();
          }
          if (!state.hasLoaded && state.error != null) {
            return AppErrorView(
              message: state.error!.message,
              onRetry: () => context.read<CallsCubit>(),
            );
          }
          if (state.calls.isEmpty) {
            return AppEmptyView(
              icon: Icons.call_outlined,
              title: loc.noCalls,
              subtitle: loc.callHistoryEmpty,
            );
          }
          return ListView.separated(
            itemCount: state.calls.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final call = state.calls[index];
              return _CallTile(call: call);
            },
          );
        },
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  const _CallTile({required this.call});

  final Call call;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isMe = call.initiatorId == sl.get<AuthRepository>().currentUser?.id;
    final icon = call.isVideo ? Icons.videocam : Icons.call;
    final iconColor = switch (call.status) {
      CallStatus.missed => AppColors.errorColor,
      CallStatus.rejected => AppColors.warningColor,
      _ => AppColors.successColor,
    };
    final statusText = switch (call.status) {
      CallStatus.ringing => loc.outgoingCall,
      CallStatus.active => loc.accepted,
      CallStatus.ended => isMe ? loc.outgoingCall : loc.incomingCall,
      CallStatus.rejected => loc.callRejected,
      CallStatus.missed => loc.callMissed,
      CallStatus.cancelled => loc.callCancelled,
      CallStatus.busy => loc.busy,
    };
    final duration = call.isEnded ? call.duration : Duration.zero;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(call.conversationId),
      subtitle: Text(statusText),
      trailing: Text(
        TimeFormatter.callDuration(duration),
        style: AppTypography.bodySmall,
      ),
      onTap: () {
        if (call.isActive || call.isRinging) {
          context.push('${AppRoutes.activeCall}/${call.id}');
        }
      },
    );
  }
}