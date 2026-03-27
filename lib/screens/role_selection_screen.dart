import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'home_screen.dart';
import 'voice_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
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
              const Gap(32),

              // Title
              const Text(
                'SignBridge',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(6),
              const Text(
                'How will you be using the app?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF888888),
                ),
              ),

              const Gap(40),

              // Sign language user
              _RoleButton(
                code: '🤟',
                title: 'Sign Language User',
                subtitle: 'I communicate using sign language',
                onTap: () => _go(context, const HomeScreen()),
              ),

              const Gap(12),

              // Non-signer / voice user
              _RoleButton(
                code: '🎙️',
                title: 'Voice User',
                subtitle: 'I want to speak to a signer',
                onTap: () => _go(context, const VoiceScreen()),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  'You can come back and switch roles anytime',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleButton({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDDDDD)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(code, style: const TextStyle(fontSize: 22)),
              ),
            ),

            const Gap(16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF888888),
            ),
          ],
        ),
      ),
    );
  }
}