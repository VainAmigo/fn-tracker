import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';

class AddTransactionActionWidget extends StatefulWidget {
  const AddTransactionActionWidget({
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.note,
    required this.onNoteChanged,
    super.key,
  });

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
                title: 'Cash',
                subtitle: 'Take from',
                leading: Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: AppSizing.iconSizeM,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: AppSizing.iconSizeM,
                ),
              ),
            ),
            const SizedBox(width: AppSizing.spaceBtwItems),
            Expanded(
              child: CategoryCard(
                title: widget.selectedCategory?.name ?? 'Category',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: AppSizing.iconSizeM,
                ),
                onTap: () => _showCategoryPicker(context),
              ),
            ),
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
    Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwItems,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: AppSizing.spaceBtwItems),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listTileTitle(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
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
