import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionActionWidget extends StatefulWidget {
  const AddTransactionActionWidget({
    required this.selectedType,
    required this.selectedWallet,
    required this.selectedGoal,
    required this.onAccountSelected,
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.note,
    required this.onNoteChanged,
    super.key,
  });

  final TransactionType selectedType;
  final WalletModel? selectedWallet;
  final GoalModel? selectedGoal;
  final ValueChanged<Object> onAccountSelected;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel> onCategoryChanged;
  final String note;
  final ValueChanged<String> onNoteChanged;

  @override
  State<AddTransactionActionWidget> createState() =>
      _AddTransactionActionWidgetState();
}

class _AddTransactionActionWidgetState
    extends State<AddTransactionActionWidget> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(widget.selectedDate);
    final yesterday = now.subtract(const Duration(days: 1));
    final shade = findShadeById(widget.selectedCategory?.colorId ?? '');
    final icon = findIconById(widget.selectedCategory?.iconId ?? '');
    final hasGoal = widget.selectedGoal != null;
    final accountName = hasGoal
        ? widget.selectedGoal!.name
        : widget.selectedWallet?.name ?? 'Wallet';
    final walletShade = findShadeById(widget.selectedWallet?.colorId ?? '');
    final walletIcon = findIconById(widget.selectedWallet?.iconId ?? '');
    final goalShade = findShadeById(widget.selectedGoal?.colorId ?? '');
    final goalIcon = findIconById(widget.selectedGoal?.iconId ?? '');
    final accountColor = hasGoal
        ? (goalShade?.color ?? colorScheme.primary)
        : (walletShade?.color ?? Colors.grey);
    final accountIcon = hasGoal
        ? (goalIcon?.icon ?? Icons.flag_rounded)
        : (walletIcon?.icon ?? Icons.account_balance_wallet);

    String dateTitle;
    if (selected == now) {
      dateTitle = 'Today';
    } else if (selected == yesterday) {
      dateTitle = 'Yesterday';
    } else {
      dateTitle =
          '${selected.day.toString().padLeft(2, '0')}.${selected.month.toString().padLeft(2, '0')}.${selected.year}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: CategoryCard(
                radius: CategoryCardRadius.single,
                title: accountName,
                subtitle: hasGoal
                    ? 'Goal'
                    : widget.selectedType == TransactionType.expense
                    ? 'Take from'
                    : 'Add to',
                leading: Container(
                  height: AppSizing.heightS,
                  decoration: BoxDecoration(
                    color: accountColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      AppSizing.borderRadius8,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Icon(
                      accountIcon,
                      size: AppSizing.iconSizeM,
                      color: accountColor,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: AppSizing.iconSizeM,
                ),
                onTap: () => _showAccountsPicker(context),
              ),
            ),
            if (widget.selectedType == TransactionType.expense) ...[
              const SizedBox(width: AppSizing.spaceBtwItems),
              Expanded(
                child: CategoryCard(
                  radius: CategoryCardRadius.single,
                  title: widget.selectedCategory?.name ?? 'Category',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurface,
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
                  onTap: () => _showCategoryPicker(context),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        Row(
          children: [
            _buildTileWidget(
              context,
              dateTitle,
              Icon(
                Icons.calendar_month,
                color: colorScheme.onSecondary,
                size: AppSizing.iconSizeM,
              ),
              () => _showDatePicker(context),
            ),
            Container(
              height: AppSizing.heightXS,
              alignment: Alignment.center,
              child: VerticalDivider(
                color: colorScheme.onSecondary,
                width: AppSizing.spaceBtwSections,
                thickness: 1,
              ),
            ),
            Expanded(
              child: _buildTileWidget(
                context,
                widget.note.trim().isEmpty ? 'Add note' : widget.note,
                Icon(
                  Icons.edit,
                  color: colorScheme.onSecondary,
                  size: AppSizing.iconSizeM,
                ),
                () => _showNotePicker(context),
                expandText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTileWidget(
    BuildContext context,
    String title,
    Widget leading,
    Function()? onTap, {
    bool expandText = false,
  }) {
    final text = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.listTileTitle(
        context,
      ).copyWith(color: Theme.of(context).colorScheme.onSecondary),
    );

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwItems,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        child: Row(
          mainAxisSize: expandText ? MainAxisSize.max : MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: AppSizing.spaceBtwItems),
            if (expandText) Expanded(child: text) else text,
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountsPicker(BuildContext context) async {
    final selected = await AppBottomSheet.showFittedModalBottomSheet<Object>(
      context,
      child: AddTransactionAccountsSheetWidget(),
    );
    if (!mounted) return;
    if (selected != null) {
      widget.onAccountSelected(selected);
    }
  }

  Future<void> _showCategoryPicker(BuildContext context) async {
    final selected =
        await AppBottomSheet.showFittedModalBottomSheet<CategoryModel>(
          context,
          child: AddTransactionCategorySheetWidget(),
        );
    if (!mounted) return;
    if (selected != null) {
      widget.onCategoryChanged(selected);
    }
  }

  void _showDatePicker(BuildContext context) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: AddTransactionDateSheetWidget(
        initialDate: widget.selectedDate,
        onDateSelected: (date) {
          widget.onDateChanged(date);
        },
      ),
    );
  }

  Future<void> _showNotePicker(BuildContext context) async {
    _noteController.text = widget.note;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalSheetTitleWidget(
                title: 'Add Note',
                action: PrimaryButton(
                  text: 'save',
                  size: PrimaryButtonSize.xSmall,
                  fullWidth: false,
                  onPressed: () {
                    final value = _noteController.text.trim();
                    widget.onNoteChanged(value);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              CustomTextFormField(
                autofocus: true,
                hintText: 'Enter your note',
                controller: _noteController,
              ),
            ],
          ),
        );
      },
    );
  }
}
