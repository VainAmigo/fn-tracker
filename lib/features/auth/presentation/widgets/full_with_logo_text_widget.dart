import 'package:flutter/material.dart';

class FullWithLogoTextWidget extends StatelessWidget {
  const FullWithLogoTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const refFontSize = 70.0;
        final widthBudget = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;

        final measureSpan = TextSpan(
          children: [
            TextSpan(
              text: 'IN',
              style: TextStyle(
                fontSize: refFontSize,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            TextSpan(
              text: 'FINANCE',
              style: TextStyle(
                fontSize: refFontSize,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSecondary,
              ),
            ),
          ],
        );
        final painter = TextPainter(
          text: measureSpan,
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();
        final intrinsicW = painter.width;
        if (intrinsicW <= 0) {
          return const SizedBox.shrink();
        }
        final fontSize = refFontSize * (widthBudget / intrinsicW);

        return RichText(
          maxLines: 1,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'IN',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              TextSpan(
                text: 'FINANCE',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
