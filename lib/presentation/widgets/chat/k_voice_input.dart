// lib/presentation/widgets/chat/k_voice_input.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'dart:async';

class KVoiceInput extends StatefulWidget {
  final Function(String) onTranscription;
  final VoidCallback? onClose;
  final bool isAIResponding;

  const KVoiceInput({
    super.key,
    required this.onTranscription,
    this.onClose,
    this.isAIResponding = false,
  });

  @override
  State<KVoiceInput> createState() => _KVoiceInputState();
}

class _KVoiceInputState extends State<KVoiceInput>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcribedText = '';
  Timer? _autoStopTimer;
  late AnimationController _animationController;
  final int _autoStopDuration = 10; // Auto-stop after 10 seconds of silence

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    // Don't allow toggling while processing or when AI is responding
    if (_isProcessing || widget.isAIResponding) return;

    setState(() {
      _isRecording = !_isRecording;
      _transcribedText = '';
    });

    if (_isRecording) {
      // Start recording - in a real app, this would access the speech recognition API
      _startVoiceRecording();

      // Set auto-stop timer
      _autoStopTimer = Timer(Duration(seconds: _autoStopDuration), () {
        if (_isRecording) {
          _stopVoiceRecording();
        }
      });
    } else {
      // Stop recording and process voice input
      _stopVoiceRecording();
    }
  }

  void _closeVoiceInput() {
    if (_isRecording) {
      _stopVoiceRecording(sendTranscription: false);
    }

    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  void _startVoiceRecording() {
    // This is a placeholder - would implement real voice recording
    debugPrint('Started voice recording');

    // In a real implementation, you would:
    // 1. Request microphone permissions if not already granted
    // 2. Initialize the speech recognition API
    // 3. Start listening for voice input
    // 4. Show real-time transcription as the user speaks

    // Simulate real-time transcription updates
    _simulateRealtimeTranscription();
  }

  void _simulateRealtimeTranscription() {
    // This simulates receiving partial transcription results
    // In a real app, this would come from the speech recognition API

    final phrases = [
      "I've been feeling ",
      "I've been feeling anxious ",
      "I've been feeling anxious lately ",
      "I've been feeling anxious lately and would like ",
      "I've been feeling anxious lately and would like some advice ",
      "I've been feeling anxious lately and would like some advice on managing stress.",
    ];

    // Cancel any existing timer
    _autoStopTimer?.cancel();

    // Simulate receiving transcription updates
    for (int i = 0; i < phrases.length; i++) {
      Future.delayed(Duration(milliseconds: 500 * (i + 1)), () {
        if (_isRecording && mounted) {
          setState(() {
            _transcribedText = phrases[i];
          });

          // Reset auto-stop timer on each update
          _autoStopTimer?.cancel();
          _autoStopTimer = Timer(Duration(seconds: _autoStopDuration), () {
            if (_isRecording) {
              _stopVoiceRecording();
            }
          });
        }
      });
    }
  }

  void _stopVoiceRecording({bool sendTranscription = true}) {
    // Cancel auto-stop timer
    _autoStopTimer?.cancel();

    // This is a placeholder - would implement real voice recording
    debugPrint('Stopped voice recording');

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    // Simulate transcription processing
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isProcessing = false;
      });

      // For demo purposes, use the current transcribed text or a fallback
      final transcription = _transcribedText.isNotEmpty
          ? _transcribedText
          : "I've been feeling anxious lately and would like some advice on managing stress.";

      if (sendTranscription) {
        widget.onTranscription(transcription);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRecording || _isProcessing) ...[
          // Recording indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(
              backgroundColor: AppTheme.snowWhite,
              borderRadius: AppTheme.radiusXL,
              elevation: AppTheme.elevationS,
            ),
            child: Column(
              children: [
                Text(
                  _isProcessing ? 'Processing...' : 'Listening...',
                  style: AppTheme.subtitleM.copyWith(
                    color: _isProcessing
                        ? AppTheme.robinsGreen
                        : AppTheme.electricViolet,
                  ),
                ),
                const SizedBox(height: 16),

                // Voice waveform visualization or processing indicator
                if (_isProcessing)
                  const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.robinsGreen),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Waveform visualization
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return SizedBox(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(20, (index) {
                                // Create waveform bars with varying heights
                                final sinValue = (index % 2 == 0 ? 0.7 : 0.5) +
                                    0.5 *
                                        (index % 3 == 0
                                            ? _animationController.value
                                            : 1 - _animationController.value);

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  width: 4,
                                  height: 10 + (30 * sinValue),
                                  decoration: BoxDecoration(
                                    color: AppTheme.heliotropeLight,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusXS),
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),

                      // Real-time transcription
                      if (_transcribedText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.heliotropeLight.withValues(alpha: 0.3),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            _transcribedText,
                            style: AppTheme.bodyM,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Close button
                    IconButton(
                      icon: Icon(AppIcons.close, color: AppTheme.secondaryText),
                      onPressed: _closeVoiceInput,
                    ),

                    // Instructions
                    Expanded(
                      child: Text(
                        _isProcessing
                            ? 'Processing your voice input...'
                            : 'Tap the microphone icon again to stop',
                        style: AppTheme.bodyS.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Spacer to balance the close button
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Microphone button (only show if not in processing state)
        if (!_isProcessing)
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isRecording ? 64 : 48,
              height: _isRecording ? 64 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isAIResponding
                      ? [
                          AppTheme.secondaryText.withValues(alpha: 0.5),
                          AppTheme.secondaryText.withValues(alpha: 0.3),
                        ]
                      : [
                          _isRecording
                              ? AppTheme.error
                              : AppTheme.electricViolet,
                          _isRecording
                              ? AppTheme.error.withValues(alpha: 0.7)
                              : AppTheme.heliotropeLight,
                        ],
                ),
                boxShadow: widget.isAIResponding
                    ? []
                    : AppTheme.getShadow(
                        elevation: _isRecording
                            ? AppTheme.elevationM
                            : AppTheme.elevationS,
                        shadowColor: _isRecording
                            ? AppTheme.error
                            : AppTheme.electricViolet,
                      ),
              ),
              child: Icon(
                _isRecording ? AppIcons.stop : AppIcons.microphone,
                color: widget.isAIResponding
                    ? AppTheme.divider
                    : AppTheme.snowWhite,
                size: _isRecording ? 28 : 24,
              ),
            ),
          ),
      ],
    );
  }
}
