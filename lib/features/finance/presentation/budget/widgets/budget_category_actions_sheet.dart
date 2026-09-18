import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

/// Модалка категории на вкладке бюджета: история + задание лимита.
class BudgetCategoryActionsSheet extends StatelessWidget {
  const BudgetCategoryActionsSheet({
    super.key,
    required this.spending,
    required this.budgetAmount,
    required this.allCategories,
    required this.onSetLimit,
  });

  final CategorySpending spending;
  final double budgetAmount;
  final List<CategoryModel> allCategories;
  final VoidCallback onSetLimit;

  static Future<void> show(
    BuildContext context, {
    required CategorySpending spending,
    required double budgetAmount,
    required List<CategoryModel> allCategories,
    required VoidCallback onSetLimit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetCategoryActionsSheet(
        spending: spending,
        budgetAmount: budgetAmount,
        allCategories: allCategories,
        onSetLimit: onSetLimit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = context.watch<CurrencyProvider>().currency;
    final category = spending.category;
    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;
    final limitLabel = BudgetDisplayUtils.formatCategoryLimit(
      category,
      currencySymbol: currency.symbol,
      formatAmount: (a) => AmountFormatter.format(a),
    );

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(title: category.name),
          const SizedBox(height: AppSizing.spaceBtwElements),
          CategoryCard(
            title: category.name,
            subtitle: limitLabel != null
                ? AmountFormatter.formatWithDots(context.l10n.limit, limitLabel)
                : context.l10n.noLimit,
            leading: Container(
              height: AppSizing.heightS,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  icon?.icon ?? Icons.category,
                  size: AppSizing.iconSizeM,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: context.l10n.history,
            icon: Icons.history,
            size: PrimaryButtonSize.xSmall,
            rounded: true,
            backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
            foregroundColor: colorScheme.tertiary,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                AppRouter.transactionsById,
                arguments: {
                  'idType': TransactionIdType.category,
                  'id': category.categoryId,
                },
              );
            },
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: context.l10n.setLimit,
            icon: Icons.data_usage_rounded,
            size: PrimaryButtonSize.medium,
            rounded: true,
            onPressed: () {
              Navigator.of(context).pop();
              onSetLimit();
            },
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}

/// Sheet задания лимита категории (fix / percent).
class BudgetCategoryLimitSheet extends StatefulWidget {
  const BudgetCategoryLimitSheet({
    super.key,
    required this.category,
    required this.budgetAmount,
    required this.allCategories,
    required this.onSave,
  });

  final CategoryModel category;
  final double budgetAmount;
  final List<CategoryModel> allCategories;
  final void Function({
    required CategoryLimitType limitType,
    required double? limitValue,
  }) onSave;

  static Future<void> show(
    BuildContext context, {
    required CategoryModel category,
    required double budgetAmount,
    required List<CategoryModel> allCategories,
    required void Function({
      required CategoryLimitType limitType,
      required double? limitValue,
    }) onSave,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetCategoryLimitSheet(
        category: category,
        budgetAmount: budgetAmount,
        allCategories: allCategories,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BudgetCategoryLimitSheet> createState() =>
      _BudgetCategoryLimitSheetState();
}

class _BudgetCategoryLimitSheetState extends State<BudgetCategoryLimitSheet> {
  late CategoryLimitType _limitType;
  late String _valueText;
  String? _error;

  @override
  void initState() {
    super.initState();
    _limitType = widget.category.hasLimit
        ? widget.category.limitType
        : CategoryLimitType.fixed;
    _valueText = widget.category.hasLimit
        ? AmountFormUtils.formatAmountForInput(widget.category.limitValue!)
        : '';
  }

  double get _remainingWithoutThis => BudgetCalculator.remainingExcluding(
        widget.budgetAmount,
        widget.allCategories,
        widget.category.categoryId,
      );

  double? get _previewAbsolute {
    final parsed = AmountFormUtils.parseAmount(_valueText);
    if (parsed == null || parsed <= 0) return null;
    final draft = widget.category.copyWith(
      limitType: _limitType,
      limitValue: parsed,
    );
    return BudgetCalculator.absoluteLimit(draft, widget.budgetAmount);
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>().currency;
    final remainingAfter = _previewAbsolute != null
        ? _remainingWithoutThis - _previewAbsolute!
        : _remainingWithoutThis;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalSheetTitleWidget(
            title: context.l10n.setLimit,
            subtitle: widget.category.name,
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          SegmentedControl<CategoryLimitType>(
            segments: [
              SegmentItem(
                value: CategoryLimitType.fixed,
                label: context.l10n.fixedLimit,
              ),
              SegmentItem(
                value: CategoryLimitType.percent,
                label: context.l10n.percentLimit,
              ),
            ],
            selectedValue: _limitType == CategoryLimitType.none
                ? CategoryLimitType.fixed
                : _limitType,
            onChanged: (t) => setState(() {
              _limitType = t;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          AmountInputWidget(
            enableCalculator: true,
            initialAmount: _valueText,
            currency: _limitType == CategoryLimitType.percent
                ? const Currency(
                    code: 'PCT',
                    symbol: '%',
                    symbolPosition: SymbolPosition.rightWithSpace,
                    decimalSeparator: DecimalSeparator.point,
                    thousandsSeparator: ThousandsSeparator.none,
                    decimalPlaces: 1,
                    name: 'Percent',
                  )
                : currency,
            onAmountChanged: (v) => setState(() {
              _valueText = v;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            '${context.l10n.remainingBudget}: '
            '${AmountFormatter.format(remainingAfter)} ${currency.symbol}',
            style: AppTextStyles.text14w400(context).copyWith(
              color: remainingAfter < 0
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            Text(
              _error!,
              style: AppTextStyles.text12w400(context).copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: context.l10n.save,
            onPressed: () {
              final parsed = AmountFormUtils.parseAmount(_valueText);
              if (parsed == null || parsed <= 0) return;
              if (_limitType == CategoryLimitType.percent && parsed > 100) {
                setState(() => _error = context.l10n.limitExceedsRemaining);
                return;
              }
              final exceeds = BudgetCalculator.wouldExceedRemaining(
                budgetAmount: widget.budgetAmount,
                categories: widget.allCategories,
                categoryId: widget.category.categoryId,
                limitType: _limitType,
                limitValue: parsed,
              );
              if (exceeds) {
                setState(() => _error = context.l10n.limitExceedsRemaining);
                return;
              }
              widget.onSave(limitType: _limitType, limitValue: parsed);
              if (context.mounted) Navigator.of(context).pop();
            },
            size: PrimaryButtonSize.medium,
          ),
          if (widget.category.hasLimit) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            PrimaryButton(
              text: context.l10n.clearLimit,
              size: PrimaryButtonSize.small,
              rounded: true,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.error,
              onPressed: () {
                widget.onSave(
                  limitType: CategoryLimitType.none,
                  limitValue: null,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
