import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Универсальный sheet для отображения скрытых карточек (кошельков или целей).
class HiddenCardsSheet<T> extends StatelessWidget {
  const HiddenCardsSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.onItemTap,
    this.onChangePin,
  });

  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final void Function(T item) onItemTap;
  final VoidCallback? onChangePin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.text20w600(context)),
          const SizedBox(height: AppSizing.spaceBtwElements),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItems),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onItemTap(item);
                },
                child: itemBuilder(item),
              ),
            ),
          ),
                    if (onChangePin != null) ...[
            TextButton.icon(
              onPressed: onChangePin,
              icon: const Icon(Icons.lock_reset),
              label: Text(context.l10n.changePin),
            ),
          ],
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}
