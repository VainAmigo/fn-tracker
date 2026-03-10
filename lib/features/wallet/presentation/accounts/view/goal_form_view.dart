import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalFormView extends StatefulWidget {
  const GoalFormView({super.key, this.goal});

  final GoalModel? goal;

  @override
  State<GoalFormView> createState() => _GoalFormViewState();
}

class _GoalFormViewState extends State<GoalFormView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  bool _isSubmitting = false;
  bool _defaultsInitialized = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    if (goal != null) {
      _nameController = TextEditingController(text: goal.name);
      _targetAmountController = TextEditingController(
        text: goal.targetAmount.toStringAsFixed(0),
      );
      _selectedIcon =
          findIconById(goal.iconId) ?? categoryIconGroups[0].icons.first;
      _selectedShade =
          findShadeById(goal.colorId) ?? categoryColorPalettes[0].shades.first;
      _defaultsInitialized = true;
    } else {
      _nameController = TextEditingController();
      _targetAmountController = TextEditingController();
      _selectedIcon = categoryIconGroups[0].icons.first;
      _selectedShade = categoryColorPalettes[0].shades.first;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      _selectedIcon = firstUnusedIcon(usedIds.iconIds);
      _selectedShade = firstUnusedShade(usedIds.colorIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  ({Set<String> colorIds, Set<String> iconIds}) _collectUsedIds(
    BuildContext context,
  ) {
    final goals = context.read<GoalsCubit>().currentGoals;
    final wallets = context.read<WalletCubit>().currentWallets;
    final categories = context.read<CategoriesCubit>().currentCategories;

    final editingId = widget.goal?.id;

    final usedColorIds = <String>{};
    final usedIconIds = <String>{};

    for (final g in goals) {
      if (g.id == editingId) continue;
      usedColorIds.add(g.colorId);
      usedIconIds.add(g.iconId);
    }
    for (final w in wallets) {
      usedColorIds.add(w.colorId);
      usedIconIds.add(w.iconId);
    }
    for (final c in categories) {
      usedColorIds.add(c.colorId);
      usedIconIds.add(c.iconId);
    }

    return (colorIds: usedColorIds, iconIds: usedIconIds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalsState = context.watch<GoalsCubit>().state;
    final isLoading = _isSubmitting && goalsState is GoalsLoading;
    final usedIds = _collectUsedIds(context);

    return BlocListener<GoalsCubit, GoalsState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is GoalsLoaded || state is GoalsEmpty) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Goal updated successfully'
                    : 'Goal created successfully',
              ),
            ),
          );
          Navigator.of(context).pop();
        }
        if (state is GoalsError) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Update Goal' : 'Create Goal'),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSizing.spaceBtwElements,
                      children: [
                        const SizedBox(height: AppSizing.spaceBtwElements),
                        _buildPreview(context),
                        CustomTextFormField(
                          label: 'Goal name',
                          hintText: 'e.g. Trip to Bali',
                          controller: _nameController,
                        ),
                        CustomTextFormField(
                          label: 'Target amount',
                          hintText: 'e.g. 5000',
                          controller: _targetAmountController,
                          keyboardType: TextInputType.number,
                          prefixText: '\$ ',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        if (_isEditing) _buildProgressInfo(context),
                        CreateCategoryIconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: _selectedShade.color,
                          onIconSelected: (icon) =>
                              setState(() => _selectedIcon = icon),
                          usedIconIds: usedIds.iconIds,
                        ),
                        CreateCategoryColorPickerWidget(
                          selectedShade: _selectedShade,
                          onShadeSelected: (shade) =>
                              setState(() => _selectedShade = shade),
                          usedColorIds: usedIds.colorIds,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                PrimaryButton(
                  text: _isEditing ? 'Update' : 'Create',
                  onPressed: isLoading ? null : _submitGoal,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizing.heightL,
        height: AppSizing.heightL,
        decoration: BoxDecoration(
          color: _selectedShade.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Icon(
          _selectedIcon.icon,
          size: AppSizing.iconSizeL,
          color: _selectedShade.color,
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    final goal = widget.goal!;
    final remaining = (goal.targetAmount - goal.progress).clamp(
      0.0,
      double.infinity,
    );
    final percent = goal.targetAmount > 0
        ? (goal.progress / goal.targetAmount * 100).clamp(0.0, 100.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress', style: AppTextStyles.text14w400(context)),
        const SizedBox(height: AppSizing.spaceBtwElements),
        LinearProgressIndicator(
          value: percent / 100,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
          minHeight: 8,
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AmountDividerWidget(
              leftAmount: goal.progress,
              rightAmount: goal.targetAmount,
              dividerType: DividerType.slash,
              styel: AppTextStyles.text14w400(context),
            ),
            Text(
              'Remaining: \$${remaining.toStringAsFixed(0)}',
              style: AppTextStyles.text14w400(context),
            ),
          ],
        ),
      ],
    );
  }

  void _submitGoal() {
    final name = _nameController.text.trim();
    final targetText = _targetAmountController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    final targetAmount = double.tryParse(targetText);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid target amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final goal = GoalModel(
      id: widget.goal?.id ?? '',
      name: name,
      colorId: _selectedShade.id,
      iconId: _selectedIcon.id,
      progress: widget.goal?.progress ?? 0,
      targetAmount: targetAmount,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<GoalsCubit>().updateGoal(goal: goal);
    } else {
      context.read<GoalsCubit>().createGoal(goal: goal);
    }
  }
}
