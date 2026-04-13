import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AiLogicDraftTile extends StatefulWidget {
  const AiLogicDraftTile({
    super.key,
    required this.draft,
    required this.category,
    required this.wallet,
    required this.goal,
    required this.onDraftChanged,
    required this.onAccountTap,
    required this.onCategoryTap,
    required this.onDateTap,
  });

  final AiTransactionDraft draft;
  final CategoryModel? category;
  final WalletModel? wallet;
  final GoalModel? goal;
  final ValueChanged<AiTransactionDraft> onDraftChanged;
  final VoidCallback onAccountTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onDateTap;

  static const _typeSegments = [
    SegmentItem<TransactionType>(
      value: TransactionType.expense,
      label: 'Expense',
      icon: Icons.arrow_downward,
    ),
    SegmentItem<TransactionType>(
      value: TransactionType.income,
      label: 'Income',
      icon: Icons.arrow_upward,
    ),
  ];

  @override
  State<AiLogicDraftTile> createState() => _AiLogicDraftTileState();
}

class _AiLogicDraftTileState extends State<AiLogicDraftTile> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _amountText(widget.draft.amount),
    );
    _noteController = TextEditingController(text: widget.draft.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheme = colorScheme;
    final isExpense = widget.draft.transactionType == TransactionType.expense;
    final account = _accountPresentation(scheme);
    final shade = findShadeById(widget.category?.colorId ?? '');
    final icon = findIconById(widget.category?.iconId ?? '');

    return Material(
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSizing.spaceBtwElements),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedControl<TransactionType>(
              segments: AiLogicDraftTile._typeSegments,
              height: AppSizing.heightS,
              selectedValue: widget.draft.transactionType,
              onChanged: (value) {
                widget.onDraftChanged(
                  widget.draft.copyWith(
                    transactionType: value,
                    clearCategory: value == TransactionType.income,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizing.spaceBtwSections),
            Row(
              children: [
                Expanded(
                  child: _buildAccountCard(
                    context,
                    title: account.name,
                    subtitle: widget.goal != null
                        ? 'Goal'
                        : isExpense
                        ? 'Take from'
                        : 'Add to',
                    color: account.color,
                    icon: account.icon,
                    onTap: widget.onAccountTap,
                  ),
                ),
                if (isExpense) ...[
                  const SizedBox(width: AppSizing.spaceBtwItems),
                  Expanded(
                    child: CategoryCard(
                      radius: CardRadius.single,
                      title: widget.category?.name ?? 'Category',
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.onSurface,
                        size: AppSizing.iconSizeM,
                      ),
                      leading: Container(
                        height: AppSizing.heightS,
                        decoration: BoxDecoration(
                          color:
                              shade?.color.withValues(alpha: 0.15) ??
                              Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppSizing.borderRadius8,
                          ),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Icon(
                            icon?.icon ?? Icons.category,
                            size: AppSizing.iconSizeM,
                            color: shade?.color ?? Colors.grey,
                          ),
                        ),
                      ),
                      onTap: widget.onCategoryTap,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSizing.spaceBtwElements),
            _buildDateTile(context),
            const SizedBox(height: AppSizing.spaceBtwElements),
            CustomTextFormField(
              controller: _amountController,
              label: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              hintText: '—',
              onChanged: (_) {
                final parsed = double.tryParse(
                  _amountController.text.replaceAll(',', '.'),
                );
                widget.onDraftChanged(
                  widget.draft.copyWith(
                    amount: parsed,
                    clearAmount: parsed == null || parsed <= 0,
                  ),
                );
              },
            ),
            CustomTextFormField(
              controller: _noteController,
              label: 'Note',
              hintText: 'Up to 5 words',
              onChanged: (v) {
                widget.onDraftChanged(widget.draft.copyWith(note: v));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AiLogicDraftTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.amount != widget.draft.amount) {
      _amountController.text = _amountText(widget.draft.amount);
    }
    if (oldWidget.draft.note != widget.draft.note) {
      _noteController.text = widget.draft.note;
    }
  }

  String _amountText(double? v) {
    if (v == null) return '';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  ({String name, Color color, IconData icon}) _accountPresentation(
    ColorScheme colorScheme,
  ) {
    if (widget.goal != null) {
      final g = widget.goal!;
      final shade = findShadeById(g.colorId);
      final icon = findIconById(g.iconId);
      return (
        name: g.name,
        color: shade?.color ?? colorScheme.primary,
        icon: icon?.icon ?? Icons.flag_rounded,
      );
    }
    if (widget.wallet != null) {
      final w = widget.wallet!;
      final shade = findShadeById(w.colorId);
      final icon = findIconById(w.iconId);
      return (
        name: w.name,
        color: shade?.color ?? Colors.grey,
        icon: icon?.icon ?? Icons.account_balance_wallet,
      );
    }
    return (
      name: 'Wallet',
      color: Colors.grey,
      icon: Icons.account_balance_wallet,
    );
  }

  String _dateTitle(DateTime d) {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(d);
    final yesterday = now.subtract(const Duration(days: 1));
    if (selected == now) return 'Today';
    if (selected == yesterday) return 'Yesterday';
    return selected.formatDotDate;
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CategoryCard(
      radius: CardRadius.single,
      title: title,
      subtitle: subtitle,
      leading: Container(
        height: AppSizing.heightS,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Icon(icon, size: AppSizing.iconSizeM, color: color),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).colorScheme.onSurface,
        size: AppSizing.iconSizeM,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDateTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onDateTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwItems,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: colorScheme.onSecondary,
              size: AppSizing.iconSizeM,
            ),
            const SizedBox(width: AppSizing.spaceBtwItems),
            Text(
              _dateTitle(widget.draft.date),
              style: AppTextStyles.listTileTitle(
                context,
              ).copyWith(color: colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
