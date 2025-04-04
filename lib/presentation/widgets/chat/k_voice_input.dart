// lib/presentation/widgets/chat/k_voice_input.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KVoiceInput extends StatefulWidget {
  final Function(String) onTranscription;

  const KVoiceInput({
    super.key,
    required this.onTranscription,
  });

  @override
  State<KVoiceInput> createState() => _KVoiceInputState();
}

class _KVoiceInputState extends State<KVoiceInput>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;

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
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Start recording - in a real app, this would access the speech recognition API
      _startVoiceRecording();
    } else {
      // Stop recording and process voice input
      _stopVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    // This is a placeholder - would implement real voice recording
    debugPrint('Started voice recording');
  }

  void _stopVoiceRecording() {
    // This is a placeholder - would implement real voice recording
    debugPrint('Stopped voice recording');

    // Simulate transcription after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // For demo purposes, return a hardcoded transcription
      final transcription =
          "I've been feeling anxious lately and would like some advice on managing stress.";
      widget.onTranscription(transcription);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRecording) ...[
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
                  'Listening...',
                  style: AppTheme.subtitleM.copyWith(
                    color: AppTheme.electricViolet,
                  ),
                ),
                const SizedBox(height: 16),

                // Voice waveform visualization
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
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 10 + (30 * sinValue),
                            decoration: BoxDecoration(
                              color: AppTheme.heliotropeLight,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusXS),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Tap the microphone icon again to stop',
                  style: AppTheme.bodyS.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Microphone button
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
                colors: [
                  _isRecording ? AppTheme.error : AppTheme.electricViolet,
                  _isRecording ? AppTheme.errorLight : AppTheme.heliotropeLight,
                ],
              ),
              boxShadow: AppTheme.getShadow(
                elevation:
                    _isRecording ? AppTheme.elevationM : AppTheme.elevationS,
                shadowColor:
                    _isRecording ? AppTheme.error : AppTheme.electricViolet,
              ),
            ),
            child: Icon(
              _isRecording ? AppIcons.close : AppIcons.microphone,
              color: AppTheme.snowWhite,
              size: _isRecording ? 28 : 24,
            ),
          ),
        ),
      ],
    );
  }
}
