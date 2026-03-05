import 'package:flutter/material.dart';
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
    this.radius = CategoryCardRadius.middle,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final CategoryCardStyle style;
  final CategoryCardRadius radius;

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
          borderRadius: switch (radius) {
            CategoryCardRadius.first => BorderRadius.only(
              topLeft: Radius.circular(AppSizing.borderRadius12),
              topRight: Radius.circular(AppSizing.borderRadius12),
              bottomLeft: Radius.circular(AppSizing.borderRadius4),
              bottomRight: Radius.circular(AppSizing.borderRadius4),
            ),
            CategoryCardRadius.last => BorderRadius.only(
              topLeft: Radius.circular(AppSizing.borderRadius4),
              topRight: Radius.circular(AppSizing.borderRadius4),
              bottomLeft: Radius.circular(AppSizing.borderRadius12),
              bottomRight: Radius.circular(AppSizing.borderRadius12),
            ),
            CategoryCardRadius.middle => BorderRadius.circular(
              AppSizing.borderRadius4,
            ),
            CategoryCardRadius.single => BorderRadius.circular(
              AppSizing.borderRadius12,
            ),
          },
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

enum CategoryCardRadius { first, last, middle, single }

enum CategoryCardStyle { filled, outlined }
