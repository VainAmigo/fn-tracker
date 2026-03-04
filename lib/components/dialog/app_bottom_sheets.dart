import 'package:flutter/material.dart';

abstract class AppBottomSheet {
  static Future<T?> showScrollableModalBottomSheet<T>(
    BuildContext context, {
    double initialChildSize = 0.5,
    double maxChildSize = 1.0,
    double minChildSize = 0.25,
    required Widget Function(BuildContext, ScrollController) builder,
    Color? backgroundColor,
    Key? scrollKey,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          maxChildSize: maxChildSize,
          minChildSize: minChildSize,
          expand: false,
          builder: builder,
        );
      },
    );
  }

  /// Показывает модальное окно, которое автоматически подстраивается под размер контента
  static Future<T?> showFittedModalBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    Color? backgroundColor,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.viewInsets.bottom,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
