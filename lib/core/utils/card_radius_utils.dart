import 'package:flutter/material.dart';

import 'package:fn_tracker/theme/app_sizing/app_sizing.dart';

/// Позиция карточки в списке для определения скругления углов.
enum CardRadius {
  first,
  last,
  middle,
  single,
}

/// Возвращает [CardRadius] для элемента списка по индексу.
CardRadius radiusForIndex(int index, int total) {
  if (total == 1) return CardRadius.single;
  if (index == 0) return CardRadius.first;
  if (index == total - 1) return CardRadius.last;
  return CardRadius.middle;
}

/// Возвращает [BorderRadius] для заданного [CardRadius].
///
/// [mainRadius] — радиус для основных углов (first/last/single).
/// [cornerRadius] — радиус для промежуточных углов (middle).
BorderRadius borderRadiusFor(
  CardRadius r, {
  double mainRadius = AppSizing.borderRadius12,
  double cornerRadius = AppSizing.borderRadius4,
}) {
  return switch (r) {
    CardRadius.first => BorderRadius.only(
        topLeft: Radius.circular(mainRadius),
        topRight: Radius.circular(mainRadius),
        bottomLeft: Radius.circular(cornerRadius),
        bottomRight: Radius.circular(cornerRadius),
      ),
    CardRadius.last => BorderRadius.only(
        topLeft: Radius.circular(cornerRadius),
        topRight: Radius.circular(cornerRadius),
        bottomLeft: Radius.circular(mainRadius),
        bottomRight: Radius.circular(mainRadius),
      ),
    CardRadius.middle => BorderRadius.circular(cornerRadius),
    CardRadius.single => BorderRadius.circular(mainRadius),
  };
}
