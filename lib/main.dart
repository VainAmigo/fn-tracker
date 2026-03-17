import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/firebase_options.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(const AppView());
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    final firebaseAuthRepo = FirebaseAuthRepo();
    final transactionsRepo = TransactionsRepositoryImpl();
    final walletRepo = WalletRepository(transactionsRepo: transactionsRepo);
    final categoryRepo = CategoryRepository();
    final dataSeeder = DefaultDataSeeder(
      tasks: [
        WalletSeedTask(
          walletRepo: walletRepo,
          wallets: DefaultSeedData.wallets,
        ),
        CategorySeedTask(
          categoryRepo: categoryRepo,
          categories: DefaultSeedData.categories,
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo, dataSeeder: dataSeeder)
                ..checkAuth(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => CategoriesCubit(categoryRepo: categoryRepo),
        ),
        BlocProvider<QuickCategoriesSettingsCubit>(
          create: (context) => QuickCategoriesSettingsCubit(),
        ),
        BlocProvider<TransactionsCubit>(
          create: (context) =>
              TransactionsCubit(transactionsRepo: transactionsRepo),
        ),
        BlocProvider<AddTransactionCubit>(
          create: (context) =>
              AddTransactionCubit(transactionsRepo: transactionsRepo),
        ),
        BlocProvider<BudgetCubit>(
          create: (context) => BudgetCubit(walletRepo: walletRepo),
        ),
        BlocProvider<HomeCubit>(
          create: (context) =>
              HomeCubit(transactionsRepo: transactionsRepo),
        ),
        BlocProvider<WalletCubit>(
          create: (context) => WalletCubit(walletRepo: walletRepo),
        ),
        BlocProvider<GoalsCubit>(
          create: (context) => GoalsCubit(
            walletRepo: walletRepo,
            transactionsRepo: transactionsRepo,
          ),
        ),
        BlocProvider<AnalyticsCubit>(
          create: (context) =>
              AnalyticsCubit(analyticsRepo: AnalyticsRepository()),
        ),
        BlocProvider<ScheduledPaymentsCubit>(
          create: (context) => ScheduledPaymentsCubit(
            walletRepo: walletRepo,
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev is Authenticated && curr is Unauthenticated,
          listener: (context, state) async {
            await HydratedBloc.storage.clear();
            if (!context.mounted) return;
            context.read<WalletCubit>().clearForLogout();
            context.read<GoalsCubit>().clearForLogout();
            context.read<CategoriesCubit>().clearForLogout();
            context.read<QuickCategoriesSettingsCubit>().clearForLogout();
            context.read<ScheduledPaymentsCubit>().clearForLogout();
          },
          child: const FnTracker(),
        ),
      ),
    );
  }
}

class FnTracker extends StatelessWidget {
  const FnTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FN Tracker',
      initialRoute: AppRouter.main,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      theme: AppThemes.themeFor(themeProvider.state.palette, Brightness.light),
      darkTheme: AppThemes.themeFor(
        themeProvider.state.palette,
        Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
