import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable wrapper that adds a tactile scale-press micro-interaction
/// and haptic feedback to any child widget.
///
/// ## Design rationale
/// Uses [Listener] (raw pointer events) instead of [GestureDetector] to
/// guarantee it **never competes** with inner widgets (e.g., [ElevatedButton],
/// [InkWell]) in Flutter's gesture arena. This means:
/// - The child button keeps full control of its own tap / onPressed.
/// - [PressableButton] purely owns the visual scale feedback + haptic.
///
/// ## Usage
/// Wrap any pressable widget and let the child's own `onPressed` / `onTap`
/// handle the action. [PressableButton] only adds the visual + haptic layer.
///
/// ```dart
/// PressableButton(
///   child: ElevatedButton(
///     onPressed: () => doSomething(),
///     child: Text('قدم الآن'),
///   ),
/// )
/// ```
class PressableButton extends StatefulWidget {
  final Widget child;

  /// How much the widget scales down when pressed. Defaults to 0.95.
  final double pressedScale;

  /// Duration of the scale animation. Defaults to 120ms.
  final Duration duration;

  /// Haptic intensity to fire on pointer-down.
  final HapticFeedbackType hapticType;

  const PressableButton({
    super.key,
    required this.child,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.hapticType = HapticFeedbackType.light,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    // [Listener] receives raw pointer events regardless of gesture arena,
    // so it never interferes with child button tap handling.
    return Listener(
      onPointerDown: (_) {
        _triggerHaptic();
        setState(() => _isPressed = true);
      },
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// Defines the haptic intensity for [PressableButton].
enum HapticFeedbackType { light, medium, selection }
