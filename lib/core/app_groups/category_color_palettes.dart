import 'package:flutter/material.dart';

class CategoryShade {
  const CategoryShade(this.id, this.color);

  final String id;
  final Color color;
}

class CategoryColorPalette {
  const CategoryColorPalette({required this.base, required this.shades});

  final Color base;
  final List<CategoryShade> shades;
}

CategoryShade? findShadeById(String id) {
  for (final palette in categoryColorPalettes) {
    for (final shade in palette.shades) {
      if (shade.id == id) return shade;
    }
  }
  return null;
}

CategoryShade firstUnusedShade(Set<String> usedIds) {
  for (final palette in categoryColorPalettes) {
    for (final shade in palette.shades) {
      if (!usedIds.contains(shade.id)) return shade;
    }
  }
  return categoryColorPalettes[0].shades.first;
}

const categoryColorPalettes = [
  /// RED
  CategoryColorPalette(
    base: Color(0xFFE53935),
    shades: [
      CategoryShade('red_100', Color(0xFFFFCDD2)),
      CategoryShade('red_200', Color(0xFFEF9A9A)),
      CategoryShade('red_300', Color(0xFFE57373)),
      CategoryShade('red_400', Color(0xFFEF5350)),
      CategoryShade('red_500', Color(0xFFE53935)),
      CategoryShade('red_600', Color(0xFFD32F2F)),
      CategoryShade('red_700', Color(0xFFC62828)),
      CategoryShade('red_800', Color(0xFFB71C1C)),
    ],
  ),

  /// ORANGE
  CategoryColorPalette(
    base: Color(0xFFFB8C00),
    shades: [
      CategoryShade('orange_100', Color(0xFFFFCC80)),
      CategoryShade('orange_200', Color(0xFFFFB74D)),
      CategoryShade('orange_300', Color(0xFFFFA726)),
      CategoryShade('orange_400', Color(0xFFFF9800)),
      CategoryShade('orange_500', Color(0xFFFB8C00)),
      CategoryShade('orange_600', Color(0xFFF57C00)),
      CategoryShade('orange_700', Color(0xFFEF6C00)),
      CategoryShade('orange_800', Color(0xFFE65100)),
    ],
  ),

  /// YELLOW
  CategoryColorPalette(
    base: Color(0xFFFDD835),
    shades: [
      CategoryShade('yellow_100', Color(0xFFFFF176)),
      CategoryShade('yellow_200', Color(0xFFFFEE58)),
      CategoryShade('yellow_300', Color(0xFFFFEB3B)),
      CategoryShade('yellow_400', Color(0xFFFDD835)),
      CategoryShade('yellow_500', Color(0xFFFBC02D)),
      CategoryShade('yellow_600', Color(0xFFF9A825)),
      CategoryShade('yellow_700', Color(0xFFF57F17)),
      CategoryShade('yellow_800', Color(0xFFE6AC00)),
    ],
  ),

  /// GREEN
  CategoryColorPalette(
    base: Color(0xFF43A047),
    shades: [
      CategoryShade('green_100', Color(0xFFA5D6A7)),
      CategoryShade('green_200', Color(0xFF81C784)),
      CategoryShade('green_300', Color(0xFF66BB6A)),
      CategoryShade('green_400', Color(0xFF4CAF50)),
      CategoryShade('green_500', Color(0xFF43A047)),
      CategoryShade('green_600', Color(0xFF388E3C)),
      CategoryShade('green_700', Color(0xFF2E7D32)),
      CategoryShade('green_800', Color(0xFF1B5E20)),
    ],
  ),

  /// BLUE
  CategoryColorPalette(
    base: Color(0xFF1E88E5),
    shades: [
      CategoryShade('blue_100', Color(0xFF90CAF9)),
      CategoryShade('blue_200', Color(0xFF64B5F6)),
      CategoryShade('blue_300', Color(0xFF42A5F5)),
      CategoryShade('blue_400', Color(0xFF2196F3)),
      CategoryShade('blue_500', Color(0xFF1E88E5)),
      CategoryShade('blue_600', Color(0xFF1976D2)),
      CategoryShade('blue_700', Color(0xFF1565C0)),
      CategoryShade('blue_800', Color(0xFF0D47A1)),
    ],
  ),

  /// INDIGO
  CategoryColorPalette(
    base: Color(0xFF3949AB),
    shades: [
      CategoryShade('indigo_100', Color(0xFF9FA8DA)),
      CategoryShade('indigo_200', Color(0xFF7986CB)),
      CategoryShade('indigo_300', Color(0xFF5C6BC0)),
      CategoryShade('indigo_400', Color(0xFF3F51B5)),
      CategoryShade('indigo_500', Color(0xFF3949AB)),
      CategoryShade('indigo_600', Color(0xFF303F9F)),
      CategoryShade('indigo_700', Color(0xFF283593)),
      CategoryShade('indigo_800', Color(0xFF1A237E)),
    ],
  ),

  /// VIOLET
  CategoryColorPalette(
    base: Color(0xFF8E24AA),
    shades: [
      CategoryShade('violet_100', Color(0xFFCE93D8)),
      CategoryShade('violet_200', Color(0xFFBA68C8)),
      CategoryShade('violet_300', Color(0xFFAB47BC)),
      CategoryShade('violet_400', Color(0xFF9C27B0)),
      CategoryShade('violet_500', Color(0xFF8E24AA)),
      CategoryShade('violet_600', Color(0xFF7B1FA2)),
      CategoryShade('violet_700', Color(0xFF6A1B9A)),
      CategoryShade('violet_800', Color(0xFF4A148C)),
    ],
  ),
];
