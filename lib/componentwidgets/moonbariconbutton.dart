import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

/// Borderless, Moon-styled icon button for app bars and the reader bars.
///
/// Every button built from this widget has the exact same footprint
/// ([iconSize] + 8px padding => 36x36 by default), so a row of actions can
/// never look ragged. Pass a `MoonIcons.*_24_light` glyph to stay in the
/// design system.
class MoonBarIconButton extends StatelessWidget {
  const MoonBarIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
    this.onLongPress,
    this.iconSize = 20,
  });

  /// Glyph to display.
  final IconData icon;

  /// Colour of the glyph.
  final Color color;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Size of the glyph; the touch target is this plus 16px of padding.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return MoonButton.icon(
      onTap: onTap ?? () {},
      onLongPress: onLongPress,
      buttonSize: MoonButtonSize.sm,
      showBorder: false,
      backgroundColor: Colors.transparent,
      iconColor: color,
      padding: const EdgeInsets.all(8),
      icon: Icon(icon, size: iconSize, color: color),
    );
  }
}
