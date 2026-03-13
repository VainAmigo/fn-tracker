import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class FormCardWidget extends StatelessWidget {
  const FormCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.height,
    this.onTap,
    this.expandLabel = true,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final void Function()? onTap;
  final double? height;

  /// Если false, карточка занимает только ширину контента (для размещения в Row с другой карточкой на оставшееся место).
  final bool expandLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? AppSizing.heightM,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.defaultPadding,
          vertical: AppSizing.defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.secondary,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSizing.borderRadius4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSizing.spaceBtwItems),
            ],
            _buildLabel(context),
            if (trailing != null) ...[
              const SizedBox(width: AppSizing.spaceBtwItems),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTextStyles.text12w400(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Text(
          title,
          style: AppTextStyles.text14w400(context).copyWith(
            color:
                foregroundColor ?? Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    return expandLabel ? Expanded(child: column) : column;
  }
}
