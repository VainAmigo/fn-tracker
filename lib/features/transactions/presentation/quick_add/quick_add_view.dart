import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class QuickAddView extends StatefulWidget {
  const QuickAddView({super.key});

  @override
  State<QuickAddView> createState() => _QuickAddViewState();
}

class _QuickAddViewState extends State<QuickAddView> {
  bool _started = false;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runFlow());
  }

  Future<void> _runFlow() async {
    if (_started || !mounted) return;
    _started = true;

    final auth = await _waitForAuth();
    if (!mounted) return;
    if (auth is! Authenticated) {
      await _showMessageAndClose(context.l10n.authErrorNotSignedIn);
      return;
    }

    final walletCubit = context.read<WalletCubit>();
    if (walletCubit.state is! WalletsLoaded) {
      await walletCubit.loadWallets();
    }
    if (!mounted) return;

    final wallet = _defaultWallet();
    if (wallet == null) {
      await _showMessageAndClose(context.l10n.selectWalletOrGoal);
      return;
    }

    final categoriesCubit = context.read<CategoriesCubit>();
    if (categoriesCubit.state is! CategoriesLoaded) {
      await categoriesCubit.loadCategories();
    }
    if (!mounted) return;

    final amount = await AmountFormModalSheet.pick(
      context,
      title: context.l10n.amount,
      saveLabel: context.l10n.save,
      enableCalculator: true,
    );
    if (!mounted) return;
    if (amount == null) {
      _close();
      return;
    }

    final note = await NoteFormModalSheet.show(context);
    if (!mounted) return;
    if (note == null) {
      _close();
      return;
    }

    final category =
        await AppBottomSheet.showFittedModalBottomSheet<CategoryModel>(
          context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: const AddTransactionCategorySheetWidget(),
        );
    if (!mounted) return;
    if (category == null) {
      _close();
      return;
    }

    setState(() => _saving = true);
    final cubit = context.read<AddTransactionCubit>()..reset();
    final now = DateTime.now();
    await cubit.addTransaction(
      transaction: TransactionModel(
        id: '',
        categoryId: category.categoryId,
        walletId: wallet.id,
        amount: amount,
        note: note,
        type: TransactionType.expense,
        createdAt: now,
        date: now,
        dayKey: now.dayKey,
        periodKey: now.periodKey,
      ),
    );
    if (!mounted) return;

    if (cubit.state is AddTransactionError) {
      final message = (cubit.state as AddTransactionError).message;
      await _showMessageAndClose(message);
      return;
    }

    _close();
  }

  Future<AuthState> _waitForAuth() async {
    final cubit = context.read<AuthCubit>();
    final current = cubit.state;
    if (current is Authenticated ||
        current is Unauthenticated ||
        current is AuthError) {
      return current;
    }
    return cubit.stream.firstWhere(
      (state) =>
          state is Authenticated ||
          state is Unauthenticated ||
          state is AuthError,
    );
  }

  WalletModel? _defaultWallet() {
    final state = context.read<WalletCubit>().state;
    if (state is! WalletsLoaded) return null;
    return state.wallets.cast<WalletModel?>().firstWhere(
      (wallet) => wallet!.isDefault && !wallet.isHidden,
      orElse: () => state.wallets.where((wallet) => !wallet.isHidden).firstOrNull,
    );
  }

  Future<void> _showMessageAndClose(String message) async {
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = message;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    _close();
  }

  void _close() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _message != null
          ? Center(
              child: Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizing.defaultPadding),
                  child: Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text16w400(context),
                  ),
                ),
              ),
            )
          : _saving
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox.shrink(),
    );
  }
}
