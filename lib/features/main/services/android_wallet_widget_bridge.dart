import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class AndroidWalletWidgetBridge {
  AndroidWalletWidgetBridge._();

  static const MethodChannel _methodChannel = MethodChannel(
    'fn_tracker/android_widget/methods',
  );

  static Future<void> syncWallet({
    required WalletModel? wallet,
    required Currency currency,
    required ColorScheme colorScheme,
    required String title,
    required String emptyLabel,
  }) async {
    final formatted = wallet == null || wallet.hideAmount
        ? null
        : _formatAmount(wallet.balance ?? 0, currency);

    try {
      await _methodChannel.invokeMethod<void>('syncWalletWidgetData', {
        'has_wallet': wallet != null,
        'name': wallet?.name ?? '',
        'color':
            findShadeById(wallet?.colorId ?? '')?.color.toARGB32() ??
            0xFF9E9E9E,
        'icon_id': wallet?.iconId ?? '',
        'hide_amount': wallet?.hideAmount ?? false,
        'amount_prefix': formatted?.prefix ?? '',
        'amount_integer': wallet != null && wallet.hideAmount
            ? '••••'
            : (formatted?.integer ?? ''),
        'amount_suffix': formatted?.suffix ?? '',
        'title': title,
        'empty_label': emptyLabel,
        'theme_surface': colorScheme.surface.toARGB32(),
        'theme_secondary': colorScheme.secondary.toARGB32(),
        'theme_on_surface': colorScheme.onSurface.toARGB32(),
        'theme_on_secondary': colorScheme.onSecondary.toARGB32(),
        'theme_primary': colorScheme.primary.toARGB32(),
        'updated_at_ms': DateTime.now().millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      return;
    }
  }

  static Future<void> clear({
    required ColorScheme colorScheme,
    required String title,
    required String emptyLabel,
  }) async {
    try {
      await _methodChannel.invokeMethod<void>('clearWalletWidgetData', {
        'title': title,
        'empty_label': emptyLabel,
        'theme_surface': colorScheme.surface.toARGB32(),
        'theme_secondary': colorScheme.secondary.toARGB32(),
        'theme_on_surface': colorScheme.onSurface.toARGB32(),
        'theme_on_secondary': colorScheme.onSecondary.toARGB32(),
        'theme_primary': colorScheme.primary.toARGB32(),
      });
    } on MissingPluginException {
      return;
    }
  }

  static ({String prefix, String integer, String suffix}) _formatAmount(
    double amount,
    Currency currency,
  ) {
    final formatted = CurrencyFormatter(currency).formatWithParts(amount);
    final symbol = currency.symbol;
    final symbolBefore =
        currency.symbolPosition == SymbolPosition.left ||
        currency.symbolPosition == SymbolPosition.leftWithSpace;
    final spaceAfter = currency.symbolPosition == SymbolPosition.leftWithSpace;
    final spaceBefore =
        currency.symbolPosition == SymbolPosition.rightWithSpace;

    if (symbolBefore) {
      return (
        prefix: spaceAfter ? '$symbol ' : symbol,
        integer: formatted.integerPart,
        suffix: formatted.decimalPart,
      );
    }
    return (
      prefix: '',
      integer: formatted.integerPart,
      suffix: '${formatted.decimalPart}${spaceBefore ? ' ' : ''}$symbol',
    );
  }
}
