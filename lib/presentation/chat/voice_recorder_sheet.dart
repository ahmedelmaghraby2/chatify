import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class VoiceRecordingResult {
  final String path;
  final Duration duration;

  const VoiceRecordingResult({required this.path, required this.duration});
}

/// Hold-to-record bottom sheet. Returns [VoiceRecordingResult] on stop,
/// or `null` if cancelled.
Future<VoiceRecordingResult?> showVoiceRecorderSheet(
  BuildContext context,
) {
  return showModalBottomSheet<VoiceRecordingResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _VoiceRecorderSheet(),
  );
}

class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet();

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _startTime;
  Timer? _tickTimer;
  Duration _elapsed = Duration.zero;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _disposed = true;
    _tickTimer?.cancel();
    _recorder.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.somethingWentWrong,
          ),
        ),
      );
      Navigator.of(context).pop(null);
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.start(
      const RecordConfig(),
      path: path,
    );

    if (_disposed || !mounted) return;
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
    });

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || !mounted) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _tickTimer?.cancel();
    if (!mounted || path == null || path.isEmpty) return;
    Navigator.of(context).pop(
      VoiceRecordingResult(path: path, duration: _elapsed),
    );
  }

  Future<void> _cancelRecording() async {
    await _recorder.cancel();
    _tickTimer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pop(null);
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours}:$mm:$ss'
        : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete_outline),
            tooltip: loc.cancel,
            color: scheme.error,
          ),
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRecording ? 72 : 56,
              height: _isRecording ? 72 : 56,
              decoration: BoxDecoration(
                color: scheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: scheme.onError,
                size: _isRecording ? 32 : 28,
              ),
            ),
          ),
          if (_isRecording)
            Text(
              _formatDuration(_elapsed),
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }
}
