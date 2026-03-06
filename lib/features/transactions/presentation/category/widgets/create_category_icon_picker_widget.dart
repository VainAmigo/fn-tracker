import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class CreateCategoryIconPickerWidget extends StatefulWidget {
  const CreateCategoryIconPickerWidget({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
  });

  final CategoryIcon selectedIcon;
  final Color selectedColor;
  final void Function(CategoryIcon) onIconSelected;

  @override
  State<CreateCategoryIconPickerWidget> createState() =>
      _CreateCategoryIconPickerWidgetState();
}

class _CreateCategoryIconPickerWidgetState
    extends State<CreateCategoryIconPickerWidget> {
  late int _selectedGroupIndex;

  @override
  void initState() {
    super.initState();
    _selectedGroupIndex = _findGroupIndex(widget.selectedIcon.id);
  }

  int _findGroupIndex(String iconId) {
    for (int i = 0; i < categoryIconGroups.length; i++) {
      if (categoryIconGroups[i].icons.any((ic) => ic.id == iconId)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final group = categoryIconGroups[_selectedGroupIndex];

    return TitledSection(
      title: 'Icon',
      children: [
        _buildGroupSelector(),
        const SizedBox(height: AppSizing.spaceBtwElements),
        _buildIcons(group),
      ],
    );
  }

  Widget _buildGroupSelector() {
    final double size = AppSizing.heightM;
    final double iconSize = AppSizing.iconSizeM;

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoryIconGroups.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSizing.spaceBtwItemsExtra),
        itemBuilder: (context, index) {
          final group = categoryIconGroups[index];
          final isSelected = index == _selectedGroupIndex;
          final colorScheme = Theme.of(context).colorScheme;

          return SelectableCard(
            height: size,
            width: size,
            isSelected: isSelected,
            onTap: () {
              setState(() => _selectedGroupIndex = index);
              widget.onIconSelected(group.icons.first);
            },
            child: Icon(
              group.icon,
              size: iconSize,
              color: colorScheme.onSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcons(CategoryIconGroup group) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: AppSizing.spaceBtwItemsExtra,
        crossAxisSpacing: AppSizing.spaceBtwItemsExtra,
      ),
      itemCount: group.icons.length,
      itemBuilder: (context, index) {
        final icon = group.icons[index];
        final isSelected = icon.id == widget.selectedIcon.id;

        return SelectableCard(
          isSelected: isSelected,
          onTap: () => widget.onIconSelected(icon),
          child: Icon(
            icon.icon,
            color: isSelected ? widget.selectedColor : colorScheme.onSecondary,
            size: AppSizing.iconSizeM,
          ),
        );
      },
    );
  }
}
