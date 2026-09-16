import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/call_service.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/call_repository.dart';
import '../../l10n/app_localizations.dart';
import '../shared/time_formatter.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({super.key, required this.callId});

  final String callId;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  final _manager = sl.get<WebRtcCallManager>();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _connected = false;
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = true;
  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;
  StreamSubscription? _callSub;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _setupCall();
  }

  Future<void> _setupCall() async {
    final config = CallSignalingConfig.fromAppConfig();
    await _manager.initPeer(
      iceServers: config.iceServers,
      video: true,
    );

    if (_manager.localStream != null) {
      _localRenderer.srcObject = _manager.localStream;
    }

    _manager.onRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      if (mounted) setState(() => _connected = true);
    };

    _manager.onStateChanged = () {
      if (mounted) setState(() {});
      if (_manager.localStream != null && _localRenderer.srcObject == null) {
        _localRenderer.srcObject = _manager.localStream;
      }
    };

    _manager.onIceCandidate = (candidate) async {
      final callRepo = sl.get<CallRepository>();
      await callRepo.addIceCandidate(widget.callId, candidate.toMap());
    };

    _manager.onOfferCreated = (sdp) async {
      final callRepo = sl.get<CallRepository>();
      await callRepo.updateSignaling(widget.callId, {
        'type': 'offer',
        'sdp': sdp.toMap(),
      });
    };

    _manager.onAnswerCreated = (sdp) async {
      final callRepo = sl.get<CallRepository>();
      await callRepo.updateSignaling(widget.callId, {
        'type': 'answer',
        'sdp': sdp.toMap(),
      });
    };

    try {
      final offer = await _manager.createOffer();
      final callRepo = sl.get<CallRepository>();
      await callRepo.updateSignaling(widget.callId, {
        'type': 'offer',
        'sdp': offer.toMap(),
      });
    } catch (_) {}

    _callSub = sl
        .get<CallRepository>()
        .watchActiveCall(widget.callId)
        .listen((call) {
      if (call == null || call.isEnded) {
        _endCall();
      }
    });

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _endCall() async {
    _durationTimer?.cancel();
    await _callSub?.cancel();
    try {
      await sl.get<CallRepository>().endCall(widget.callId);
    } catch (_) {}
    await _manager.dispose();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _callSub?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_connected)
                    RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: AppSpacing.md),
Text(
                            loc.connecting,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            TimeFormatter.callDuration(_callDuration),
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_connected)
                    Positioned(
                      right: AppSpacing.base,
                      bottom: AppSpacing.base,
                      width: 120,
                      height: 160,
                      child: ClipRRect(
                        borderRadius: AppRadius.mediumAll,
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? loc.unmute : loc.mute,
                    onTap: () async {
                      await _manager.toggleMute();
                      setState(() => _muted = !_muted);
                    },
                  ),
                  _ControlButton(
                    icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                    label: _cameraOff ? loc.cameraOn : loc.cameraOff,
                    onTap: () async {
                      await _manager.toggleCamera();
                      setState(() => _cameraOff = !_cameraOff);
                    },
                  ),
                  _ControlButton(
                    icon: Icons.cameraswitch,
                    label: loc.flipCamera,
                    onTap: () => _manager.switchCamera(),
                  ),
                  _ControlButton(
                    icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                    label: _speakerOn ? loc.speaker : loc.earpiece,
                    onTap: () => setState(() => _speakerOn = !_speakerOn),
                    enabled: false,
                  ),
                  _ControlButton(
                    icon: Icons.call_end,
                    label: loc.endCall,
                    backgroundColor: AppColors.errorColor,
                    onTap: _endCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.white24,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
