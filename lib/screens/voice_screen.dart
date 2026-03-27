import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gap/gap.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String _lastSpoken = '';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(
        () => mounted ? setState(() => _isSpeaking = false) : null);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_speechAvailable) return;
    setState(() {
      _isListening    = true;
      _recognizedText = '';
    });
    await _speech.listen(
      onResult: (r) {
        if (mounted) setState(() => _recognizedText = r.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  Future<void> _speakText() async {
    final text = _recognizedText.trim();
    if (text.isEmpty) return;
    setState(() { _isSpeaking = true; _lastSpoken = text; });
    await _tts.speak(text);
  }

  Future<void> _repeatLast() async {
    if (_lastSpoken.isEmpty || _isSpeaking) return;
    setState(() => _isSpeaking = true);
    await _tts.speak(_lastSpoken);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),

              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),

              const Gap(24),

              // Title
              const Text(
                'Voice User',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(6),
              const Text(
                'Speak and send your message to a signer',
                style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
              ),

              const Gap(40),

              // Mic button centered
              Center(
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: _isListening
                      ? AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, child) =>
                              Transform.scale(scale: _pulse.value, child: child),
                          child: _MicButton(listening: true),
                        )
                      : const _MicButton(listening: false),
                ),
              ),

              const Gap(8),
              Center(
                child: Text(
                  _isListening ? 'Listening… tap to stop' : 'Tap to speak',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFFAAAAAA)),
                ),
              ),

              const Gap(32),

              // Text box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recognized Text',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF888888),
                    ),
                  ),
                  if (_recognizedText.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _recognizedText = ''),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                      ),
                    ),
                ],
              ),
              const Gap(10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _recognizedText.isEmpty
                      ? const Center(
                          child: Text(
                            'Your speech will appear here',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFFCCCCCC)),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _recognizedText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                              height: 1.5,
                            ),
                          ),
                        ),
                ),
              ),

              const Gap(16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _ActionButton(
                      label: _isSpeaking ? 'Speaking…' : 'Speak Aloud',
                      icon: _isSpeaking
                          ? Icons.volume_up_rounded
                          : Icons.play_arrow_rounded,
                      enabled: _recognizedText.isNotEmpty && !_isSpeaking,
                      filled: true,
                      onTap: _speakText,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 2,
                    child: _ActionButton(
                      label: 'Repeat',
                      icon: Icons.replay_rounded,
                      enabled: _lastSpoken.isNotEmpty && !_isSpeaking,
                      filled: false,
                      onTap: _repeatLast,
                    ),
                  ),
                ],
              ),

              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mic button ────────────────────────────────────────────────────────────────
class _MicButton extends StatelessWidget {
  final bool listening;
  const _MicButton({required this.listening});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: listening ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border.all(
          color: listening
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFDDDDDD),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(listening ? 0.15 : 0.06),
            blurRadius: listening ? 20 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        listening ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: listening ? Colors.white : const Color(0xFF1A1A1A),
        size: 40,
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled
              ? (enabled ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : const Color(0xFFDDDDDD),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled
                  ? (enabled ? Colors.white : const Color(0xFFBBBBBB))
                  : (enabled
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFCCCCCC)),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filled
                    ? (enabled ? Colors.white : const Color(0xFFBBBBBB))
                    : (enabled
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFCCCCCC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}