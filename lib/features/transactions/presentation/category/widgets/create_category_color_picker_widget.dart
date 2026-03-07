import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class CreateCategoryColorPickerWidget extends StatefulWidget {
  const CreateCategoryColorPickerWidget({
    super.key,
    required this.selectedShade,
    required this.onShadeSelected,
    this.usedColorIds = const {},
  });

  final CategoryShade selectedShade;
  final void Function(CategoryShade) onShadeSelected;
  final Set<String> usedColorIds;

  @override
  State<CreateCategoryColorPickerWidget> createState() =>
      _CreateCategoryColorPickerWidgetState();
}

class _CreateCategoryColorPickerWidgetState
    extends State<CreateCategoryColorPickerWidget> {
  late int _selectedPaletteIndex;

  @override
  void initState() {
    super.initState();
    _selectedPaletteIndex = _findPaletteIndex(widget.selectedShade.id);
  }

  int _findPaletteIndex(String shadeId) {
    for (int i = 0; i < categoryColorPalettes.length; i++) {
      if (categoryColorPalettes[i].shades.any((s) => s.id == shadeId)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final palette = categoryColorPalettes[_selectedPaletteIndex];

    return TitledSection(
      title: 'Color',
      children: [
        _buildBaseColors(),
        const SizedBox(height: AppSizing.spaceBtwElements),
        _buildShades(palette),
      ],
    );
  }

  Widget _buildBaseColors() {
    final int crossAxisCount = categoryColorPalettes.length;
    return GridView.builder(
      shrinkWrap: true,
      itemCount: categoryColorPalettes.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSizing.spaceBtwItemsExtra,
        crossAxisSpacing: AppSizing.spaceBtwItemsExtra,
      ),
      itemBuilder: (context, index) {
        final palette = categoryColorPalettes[index];
        final isSelected = index == _selectedPaletteIndex;

        return SelectableCard(
          isSelected: isSelected,
          backgroundColor: palette.base,
          selectedBackgroundColor: palette.base,
          onTap: () {
            setState(() => _selectedPaletteIndex = index);
            widget.onShadeSelected(palette.shades.first);
          },
        );
      },
    );
  }

  Widget _buildShades(CategoryColorPalette palette) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: AppSizing.spaceBtwItemsExtra,
        crossAxisSpacing: AppSizing.spaceBtwItemsExtra,
      ),
      itemCount: palette.shades.length,
      itemBuilder: (context, index) {
        final shade = palette.shades[index];
        final isSelected = shade.id == widget.selectedShade.id;
        final isUsed = widget.usedColorIds.contains(shade.id);

        return SelectableCard(
          isUsed: isUsed,
          isSelected: isSelected,
          backgroundColor: shade.color,
          selectedBackgroundColor: shade.color,
          onTap: () => widget.onShadeSelected(shade),
        );
      },
    );
  }
}
