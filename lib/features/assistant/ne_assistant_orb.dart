import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NEAssistantOrb extends StatefulWidget {
  final Widget child;
  const NEAssistantOrb({super.key, required this.child});

  @override
  State<NEAssistantOrb> createState() => _NEAssistantOrbState();
}

class _NEAssistantOrbState extends State<NEAssistantOrb> {
  Offset position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: _buildOrb(isDragging: true),
            childWhenDragging: const SizedBox.shrink(),
            onDragEnd: (details) {
              setState(() {
                // Keep within screen bounds (rough estimate)
                final size = MediaQuery.of(context).size;
                position = Offset(
                  details.offset.dx.clamp(0.0, size.width - 60),
                  details.offset.dy.clamp(0.0, size.height - 120),
                );
              });
            },
            child: GestureDetector(
              onTap: () => _openAssistantSheet(context),
              child: _buildOrb(isDragging: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrb({required bool isDragging}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.moss.withValues(alpha: isDragging ? 0.7 : 0.9),
          boxShadow: [
            BoxShadow(
              color: AppTheme.earth.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: AppTheme.earth.withValues(alpha: 0.5), width: 2),
        ),
        child: const Center(
          child: Text('NE', style: TextStyle(color: AppTheme.forestDeep, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ),
    );
  }

  void _openAssistantSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppTheme.forestDeep,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   const Text('NE', style: TextStyle(color: AppTheme.moss, fontSize: 24, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 12),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('NE COACH', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.cloud, fontWeight: FontWeight.bold, letterSpacing: 1)),
                       const Text('DIRECT REVERSAL MODE', style: TextStyle(color: AppTheme.earth, fontSize: 8, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const Spacer(),
                   _buildLanguagePicker(),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildMessageBubble("Your sugar is high. Walk for 5 minutes now. This will reduce spike immediately.", isBot: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(String text, {required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBot ? AppTheme.forestMid : AppTheme.earth.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(0),
          ),
          border: Border.all(color: isBot ? AppTheme.glassBorder : AppTheme.earth.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: const TextStyle(color: AppTheme.cloud, fontSize: 13, height: 1.5)),
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.language, color: AppTheme.earth, size: 12),
          SizedBox(width: 4),
          Text('EN', style: TextStyle(color: AppTheme.cloud, fontSize: 10, fontWeight: FontWeight.bold)),
          Icon(Icons.arrow_drop_down, color: AppTheme.cloud, size: 14),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(color: AppTheme.cloud),
              decoration: InputDecoration(
                hintText: "Direct sync with body...",
                hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
           IconButton(
            icon: const Icon(Icons.mic, color: AppTheme.moss),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
