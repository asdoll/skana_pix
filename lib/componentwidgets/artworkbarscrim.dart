import 'package:flutter/material.dart';

/// Translucent grey pill placed behind bars that float over artwork (the image
/// viewer's bottom bar, the artwork page's app bar).
///
/// It only stands a few pixels taller than [child], so the white icons stay
/// readable on light artwork without covering the whole screen edge, and it is
/// meant to sit inside a `SafeArea`/below the status-bar spacer so it never
/// covers the system insets.
class ArtworkBarScrim extends StatelessWidget {
  const ArtworkBarScrim({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// Content of the bar.
  final Widget child;

  /// Padding around [child] - keep it small vertically (4-6px) so the scrim
  /// hugs the buttons instead of becoming a full-height bar.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        // 35% black over a white image reads as a neutral grey, which keeps the
        // white icons and text legible.
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
