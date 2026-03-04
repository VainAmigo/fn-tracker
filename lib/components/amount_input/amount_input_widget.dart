import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';

/// Блок ввода суммы с кастомной клавиатурой.
///
/// Переиспользуемый компонент. Объединяет [AmountDisplay] и [AmountKeyboard].
class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.currency,
    this.initialAmount = '',
    this.onAmountChanged,
    this.label = 'ENTER AMOUNT',
  });

  /// Валюта для отображения символа и форматирования.
  final Currency currency;

  /// Начальное значение суммы.
  final String initialAmount;

  /// Вызывается при изменении суммы (сырая строка, например "12586.50").
  final void Function(String amount)? onAmountChanged;

  /// Подпись над полем.
  final String label;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late String _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
  }

  @override
  void didUpdateWidget(AmountInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAmount != widget.initialAmount) {
      _amount = widget.initialAmount;
    }
  }

  void _onKeyPressed(String key) {
    if (key == 'backspace') {
      if (_amount.isNotEmpty) {
        setState(() {
          _amount = _amount.substring(0, _amount.length - 1);
        });
        widget.onAmountChanged?.call(_amount);
      }
      return;
    }

    if (key == '.') {
      if (_amount.contains('.') || _amount.contains(',')) return;
      final decimalSep = widget.currency.decimalSeparator ==
              DecimalSeparator.comma
          ? ','
          : '.';
      setState(() {
        _amount = _amount.isEmpty ? '0$decimalSep' : '$_amount$decimalSep';
      });
      widget.onAmountChanged?.call(_amount);
      return;
    }

    // Digit 0-9
    if (_amount.contains('.') || _amount.contains(',')) {
      final parts = _amount.split(RegExp(r'[.,]'));
      if (parts.length == 2 && parts[1].length >= widget.currency.decimalPlaces) {
        return;
      }
    } else {
      if (_amount.length >= 12) return;
    }

    setState(() {
      if (_amount.isEmpty || _amount == '0') {
        _amount = key == '0' ? '0' : key;
      } else {
        _amount = '$_amount$key';
      }
    });
    widget.onAmountChanged?.call(_amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AmountDisplay(
          amount: _amount,
          currency: widget.currency,
          label: widget.label,
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        AmountKeyboard(onKeyPressed: _onKeyPressed),
      ],
    );
  }
}
