import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalAiAdviceSectionWidget extends StatefulWidget {
  const GoalAiAdviceSectionWidget({super.key, this.goal, this.compact = false});

  final GoalModel? goal;
  final bool compact;

  @override
  State<GoalAiAdviceSectionWidget> createState() =>
      _GoalAiAdviceSectionWidgetState();
}

class _GoalAiAdviceSectionWidgetState extends State<GoalAiAdviceSectionWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(
        widget.compact ? AppSizing.defaultPadding : AppSizing.spaceBtwElements,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.tertiary,
                size: AppSizing.iconSizeM,
              ),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Expanded(
                child: Text(
                  context.l10n.aiGoalAdviceTitle,
                  style: AppTextStyles.text16w400(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            widget.goal == null
                ? context.l10n.aiGoalAdviceAllGoalsHint
                : context.l10n.aiGoalAdviceSingleGoalHint,
            style: AppTextStyles.text14w400(
              context,
              color: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: context.l10n.aiGoalAdviceAsk,
            icon: Icons.send_rounded,
            size: PrimaryButtonSize.small,
            rounded: true,
            onPressed: () => AppBottomSheet.showFittedModalBottomSheet(
              context,
              child: _GoalAiAdviceRequestSheet(goal: widget.goal),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalAiAdviceRequestSheet extends StatefulWidget {
  const _GoalAiAdviceRequestSheet({this.goal});

  final GoalModel? goal;

  @override
  State<_GoalAiAdviceRequestSheet> createState() =>
      _GoalAiAdviceRequestSheetState();
}

class _GoalAiAdviceRequestSheetState extends State<_GoalAiAdviceRequestSheet> {
  final TextEditingController _controller = TextEditingController();
  final AiGoalSavingsAdviceRepository _repository =
      AiGoalSavingsAdviceRepositoryImpl();

  bool _isLoading = false;
  String? _advice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _advice != null || _isLoading) return;
      _askAdviceWithQuestion(_defaultQuestion(context));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _askAdvice() async {
    await _askAdviceWithQuestion(_controller.text.trim());
  }

  Future<void> _askAdviceWithQuestion(String question) async {
    if (question.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final goalsCubit = context.read<GoalsCubit>();
      final walletCubit = context.read<WalletCubit>();
      final categoriesCubit = context.read<CategoriesCubit>();

      if (walletCubit.currentWallets.isEmpty &&
          walletCubit.state is! WalletsLoading) {
        await walletCubit.loadWallets();
      }
      if (categoriesCubit.currentCategories.isEmpty &&
          categoriesCubit.state is! CategoriesLoading) {
        await categoriesCubit.loadCategories();
      }
      if (goalsCubit.currentGoals.isEmpty &&
          goalsCubit.state is! GoalsLoading) {
        await goalsCubit.loadGoals();
      }

      final contextJson = GoalSavingsAiContextBuilder.buildJsonString(
        goals: goalsCubit.currentGoals,
        wallets: walletCubit.currentWallets,
        categories: categoriesCubit.currentCategories,
        transactions: await goalsCubit.transactionsRepo
            .getAllUserTransactions(),
        focusGoalId: widget.goal?.id,
      );

      final advice = await _repository.generateAdvice(
        userQuestion: question,
        contextJsonPayload: contextJson,
      );

      if (!mounted) return;
      setState(() => _advice = advice);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _defaultQuestion(BuildContext context) {
    if (widget.goal == null) {
      return context.l10n.aiGoalAdviceDefaultQuestionAll;
    }
    return context.l10n.aiGoalAdviceDefaultQuestionSingle(widget.goal!.name);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizing.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModalSheetTitleWidget(title: context.l10n.aiGoalAdviceTitle),
                const SizedBox(height: AppSizing.spaceBtwElements),
                if (_isLoading && _advice == null) ...[
                  const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (_advice != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizing.defaultPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizing.borderRadius12,
                      ),
                    ),
                    child: Text(
                      _advice!,
                      style: AppTextStyles.text14w400(context),
                    ),
                  ),
                ],
                const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                CustomTextFormField(
                  controller: _controller,
                  hintText: context.l10n.aiGoalAdviceQuestionHint,
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  readOnly: _isLoading,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSizing.spaceBtwItems),
                PrimaryButton(
                  text: context.l10n.aiGoalAdviceAsk,
                  icon: Icons.send_rounded,
                  size: PrimaryButtonSize.small,
                  rounded: true,
                  isLoading: _isLoading,
                  onPressed: _isLoading || _controller.text.trim().isEmpty
                      ? null
                      : _askAdvice,
                ),
                const SizedBox(height: AppSizing.bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
