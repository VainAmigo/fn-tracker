import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.style = CategoryCardStyle.filled,
    this.radius = CardRadius.middle,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final CategoryCardStyle style;
  final CardRadius radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwElements,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        height: AppSizing.heightM,
        decoration: BoxDecoration(
          color: style == CategoryCardStyle.filled
              ? colorScheme.secondary
              : Colors.transparent,
          border: style == CategoryCardStyle.outlined
              ? Border.all(color: colorScheme.onSecondary, width: 1)
              : null,
          borderRadius: borderRadiusFor(radius),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSizing.spaceBtwItems),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.listTileSubtitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    title,
                    style: AppTextStyles.listTileTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

enum CategoryCardStyle { filled, outlined }
