import 'package:shadcn_flutter/shadcn_flutter.dart';

class NullHero extends StatelessWidget {
  final String? tag;
  final Widget child;

  const NullHero({super.key, this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return tag == null
        ? child
        : Hero(
            tag: tag!,
            child: child,
          );
  }
}