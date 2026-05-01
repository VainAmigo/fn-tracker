import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;
    final hasGoogle = _hasGoogleProvider(fbUser);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.account)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state is Authenticated
                  ? state.user
                  : context.read<AuthCubit>().currentUser;
              final displayName = user?.displayName?.trim();
              final hasDisplayName =
                  displayName != null && displayName.isNotEmpty;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabTitleWidget(
                      title: context.l10n.accountTitle,
                      subtitle: context.l10n.accountSubtitle,
                    ),
                    const SizedBox(height: AppSizing.spaceBtwSections),
                    TitledSection(
                      title: context.l10n.accountSettings,
                      children: [
                        CategoryCard(
                          title: user?.email ?? '',
                          subtitle: context.l10n.email,
                          radius: CardRadius.first,
                          leading: Icon(Icons.email),
                        ),
                        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                        CategoryCard(
                          title: hasDisplayName
                              ? displayName
                              : context.l10n.displayNameNotSet,
                          subtitle: hasDisplayName
                              ? context.l10n.displayNameWhenSet
                              : context.l10n.displayNameTapToSet,
                          radius: CardRadius.middle,
                          leading: Icon(Icons.person),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () =>
                              _openDisplayNameEditor(user?.displayName),
                        ),
                        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                        CategoryCard(
                          title: context.l10n.password,
                          subtitle: context.l10n.changePasswordCardSubtitle,
                          radius: CardRadius.last,
                          leading: Icon(Icons.lock),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            final current = FirebaseAuth.instance.currentUser;
                            final hasEmailPassword =
                                current?.providerData.any(
                                  (p) =>
                                      p.providerId ==
                                      EmailAuthProvider.PROVIDER_ID,
                                ) ??
                                false;
                            if (!hasEmailPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.passwordChangeEmailOnly,
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.changePassword);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizing.spaceBtwSections),
                    CategoryCard(
                      title: hasGoogle
                          ? context.l10n.googleAlreadyLinkedTitle
                          : context.l10n.linkGoogleTitle,
                      subtitle: hasGoogle
                          ? context.l10n.googleAlreadyLinkedSubtitle
                          : context.l10n.linkGoogleSubtitle,
                      radius: CardRadius.single,
                      leading: _linkingGoogle
                          ? SizedBox(
                              width: AppSizing.iconSizeM,
                              height: AppSizing.iconSizeM,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : SvgPicture.asset(
                              'assets/icons/google_icon.svg',
                              width: AppSizing.iconSizeM,
                              height: AppSizing.iconSizeM,
                            ),
                      trailing: hasGoogle || _linkingGoogle
                          ? null
                          : Icon(Icons.arrow_forward_ios),
                      onTap: hasGoogle || _linkingGoogle ? null : _onLinkGoogle,
                    ),
                    const SizedBox(height: AppSizing.spaceBtwSections),
                    TitledSection(
                      title: context.l10n.deleteUserDataSectionTitle,
                      children: [
                        PrimaryButton(
                          text: context.l10n.deleteUserDataButton,
                          onPressed: (_deletingData || _deletingAccount)
                              ? null
                              : _onDeleteUserDataTap,
                          isLoading: _deletingData,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: AppSizing.spaceBtwItems),
                        PrimaryButton(
                          text: context.l10n.deleteAccountButton,
                          onPressed: (_deletingData || _deletingAccount)
                              ? null
                              : _onDeleteAccountTap,
                          isLoading: _deletingAccount,
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizing.bottomPadding),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _linkingGoogle = false;
  bool _deletingData = false;
  bool _deletingAccount = false;

  bool _hasGoogleProvider(User? user) {
    return user?.providerData.any(
          (p) => p.providerId == GoogleAuthProvider.PROVIDER_ID,
        ) ??
        false;
  }

  Future<void> _onLinkGoogle() async {
    setState(() => _linkingGoogle = true);
    final outcome = await context.read<AuthCubit>().linkGoogleAccount();
    if (!mounted) return;

    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;

    setState(() => _linkingGoogle = false);

    switch (outcome) {
      case GoogleLinkSuccess():
        await context.read<AuthCubit>().refreshProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.googleLinkedSuccessfully)),
        );
      case GoogleLinkCancelled():
        break;
      case GoogleLinkFailure(:final firebaseCode, :final debugMessage):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              firebaseAuthMessage(context.l10n, firebaseCode, debugMessage),
            ),
          ),
        );
    }
  }

  Future<void> _openDisplayNameEditor(String? current) async {
    final ctrl = TextEditingController(text: current ?? '');
    final formKey = GlobalKey<FormState>();
    try {
      final result = await showDialog<String?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.editDisplayNameTitle),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: context.l10n.displayNameLabel,
                counterText: '',
              ),
              maxLength: 120,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  AuthValidationUtils.displayNameField(v, context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.deleteEntityCancel),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      );
      if (result == null || !mounted) return;
      final err = await context.read<AuthCubit>().updateDisplayName(result);
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.displayNameUpdated)),
        );
      }
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _onDeleteUserDataTap() async {
    final l10n = context.l10n;
    final confirmed = await AppBottomSheet.showFittedModalBottomSheet<bool>(
      context,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: AppSizing.bottomPadding,
          left: AppSizing.defaultPadding,
          right: AppSizing.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalSheetTitleWidget(title: l10n.deleteUserDataTitle),
            const SizedBox(height: AppSizing.spaceBtwSections),
            Text(
              l10n.deleteUserDataMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizing.spaceBtwSections),
            PrimaryButton(
              text: l10n.deleteUserDataConfirm,
              onPressed: () => Navigator.of(context).pop(true),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            PrimaryButton(
              text: l10n.cancel,
              onPressed: () => Navigator.of(context).pop(false),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingData = true);
    final err = await context.read<AuthCubit>().deleteAllUserData();
    if (!mounted) return;
    setState(() => _deletingData = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    await _reloadAppDataAfterWipe();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.userDataDeleted)),
    );
  }

  Future<void> _onDeleteAccountTap() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final current = FirebaseAuth.instance.currentUser;
    if (current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorNotSignedIn)),
      );
      return;
    }

    final hasPassword = current.providerData.any(
      (p) => p.providerId == EmailAuthProvider.PROVIDER_ID,
    );
    final hasGoogle = _hasGoogleProvider(current);

    String? emailPassword;
    OAuthCredential? googleCredential;

    if (hasPassword) {
      emailPassword = await _showDeleteAccountPasswordDialog();
      if (emailPassword == null || !mounted) return;
    } else if (hasGoogle) {
      final googleOk = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.continueWithGoogleToConfirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.continueWithGoogle),
            ),
          ],
        ),
      );
      if (googleOk != true || !mounted) return;

      setState(() => _deletingAccount = true);
      googleCredential =
          await context.read<AuthCubit>().obtainGoogleReauthCredential();
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      if (googleCredential == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authErrorGoogleSignIn)),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorGeneric)),
      );
      return;
    }

    setState(() => _deletingAccount = true);
    final err = await context.read<AuthCubit>().deleteAccount(
      emailPassword: emailPassword,
      googleCredential: googleCredential,
    );
    if (!mounted) return;
    setState(() => _deletingAccount = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRouter.authInit,
        (route) => false,
      );
    }
  }

  Future<String?> _showDeleteAccountPasswordDialog() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.enterPasswordToConfirmDelete),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.password,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return context.l10n.enterPasswordToConfirmDelete;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text);
                }
              },
              child: Text(context.l10n.deleteAccountConfirm),
            ),
          ],
        ),
      );
    } finally {
      // Диалог может перестроиться ещё один кадр после pop (IME/жесты) — нельзя
      // освобождать контроллер синхронно, иначе TextFormField трогает disposed controller.
      final c = ctrl;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.dispose();
      });
    }
  }

  Future<void> _reloadAppDataAfterWipe() async {
    if (!mounted) return;
    final (:start, :end) = MonthRangeUtils.currentMonth();
    context.read<QuickCategoriesSettingsCubit>().clearForLogout();
    await Future.wait([
      context.read<CategoriesCubit>().loadCategories(),
      context.read<WalletCubit>().loadWallets(),
      context.read<GoalsCubit>().loadGoals(),
      context.read<ScheduledPaymentsCubit>().loadPayments(),
      context.read<TransactionsCubit>().loadTransactionsByPeriod(
        TransactionPeriod.month,
      ),
    ]);
    if (!mounted) return;
    context.read<HomeCubit>().getHomePageStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
    context.read<AnalyticsCubit>().loadAnalytics();
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }
}
