import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Thin abstraction over a single WebRTC peer connection.
///
/// Keeps flutter_webrtc details out of the rest of the application. Callers
/// interact with SDP descriptions, ICE candidates and media streams only.
@immutable
class CallSignalingConfig {
  final List<Map<String, dynamic>> iceServers;

  const CallSignalingConfig({required this.iceServers});

  factory CallSignalingConfig.fromAppConfig() {
    final servers = <String, dynamic>{
      'urls': [AppConfig.stunUrl],
    };
    final iceServers = <Map<String, dynamic>>[servers];

    if (AppConfig.turnUrl.isNotEmpty) {
      final turn = <String, dynamic>{'urls': [AppConfig.turnUrl]};
      if (AppConfig.turnUsername.isNotEmpty) {
        turn['username'] = AppConfig.turnUsername;
        turn['credential'] = AppConfig.turnCredential;
      }
      iceServers.add(turn);
    }

    return CallSignalingConfig(iceServers: iceServers);
  }
}

class WebRtcCallManager {
  RTCPeerConnection? peer;
  MediaStream? localStream;
  MediaStream? remoteStream;
  bool _muted = false;
  bool _cameraEnabled = true;

  final _pendingCandidates = <RTCIceCandidate>[];

  bool get muted => _muted;
  bool get cameraEnabled => _cameraEnabled;
  bool get hasRemoteStream => remoteStream != null;

  void Function(RTCSessionDescription sdp)? onOfferCreated;
  void Function(RTCSessionDescription sdp)? onAnswerCreated;
  void Function(RTCIceCandidate candidate)? onIceCandidate;
  void Function(MediaStream stream)? onRemoteStream;
  void Function()? onStateChanged;

  Future<void> initPeer({
    required List<Map<String, dynamic>> iceServers,
    bool video = true,
  }) async {
    await dispose();

    peer = await createPeerConnection(<String, dynamic>{
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
    });

    peer!.onIceCandidate = (candidate) {
      _pendingCandidates.add(candidate);
      onIceCandidate?.call(candidate);
    };

    peer!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams.first;
        onRemoteStream?.call(remoteStream!);
      }
    };

    peer!.onConnectionState = (_) => onStateChanged?.call();

    if (video) {
      await _setupLocalStream();
    }
  }

  Future<void> _setupLocalStream() async {
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      for (final track in localStream!.getTracks()) {
        await peer?.addTrack(track, localStream!);
      }
      onStateChanged?.call();
    } catch (e) {
      // Camera/mic permission denied. The call continues without local media;
      // the UI surfaces the connection state directly.
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    final sdp = await peer!.createOffer();
    await peer!.setLocalDescription(sdp);
    return sdp;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final sdp = await peer!.createAnswer();
    await peer!.setLocalDescription(sdp);
    return sdp;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await peer!.setRemoteDescription(description);
  }

  Future<void> setAnswer(RTCSessionDescription answer) async {
    await peer!.setRemoteDescription(answer);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (candidate.candidate == null || candidate.candidate!.isEmpty) return;
    await peer?.addCandidate(candidate);
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    localStream
        ?.getTracks()
        .where((t) => t.kind == 'audio')
        .forEach((t) => t.enabled = !_muted);
    onStateChanged?.call();
  }

  Future<void> toggleCamera() async {
    _cameraEnabled = !_cameraEnabled;
    localStream
        ?.getTracks()
        .where((t) => t.kind == 'video')
        .forEach((t) => t.enabled = _cameraEnabled);
    onStateChanged?.call();
  }

  Future<void> switchCamera() async {
    final tracks = localStream?.getTracks().where((t) => t.kind == 'video');
    if (tracks == null || tracks.isEmpty) return;
    try {
      await Helper.switchCamera(tracks.first);
    } catch (_) {}
  }

  List<RTCIceCandidate> get pendingIceCandidates => _pendingCandidates;

  Future<void> dispose() async {
    await peer?.close();
    peer = null;
    await localStream?.dispose();
    localStream = null;
    await remoteStream?.dispose();
    remoteStream = null;
    _pendingCandidates.clear();
    _muted = false;
    _cameraEnabled = true;
  }
}