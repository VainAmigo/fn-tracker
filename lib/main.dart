import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  await GoogleSignIn.instance.initialize();

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
    final financeRepo = FinanceRepository(transactionsRepo: transactionsRepo);
    final categoryRepo = CategoryRepository();
    final dataSeeder = DefaultDataSeeder(
      tasks: [
        WalletSeedTask(
          financeRepo: financeRepo,
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
          create: (context) => CategoriesCubit(
            categoryRepo: categoryRepo,
            transactionsRepo: transactionsRepo,
          ),
        ),
        BlocProvider<QuickCategoriesSettingsCubit>(
          create: (context) => QuickCategoriesSettingsCubit(),
        ),
        BlocProvider<HomeWalletsSettingsCubit>(
          create: (context) => HomeWalletsSettingsCubit(),
        ),
        BlocProvider<HomeLayoutSettingsCubit>(
          create: (context) => HomeLayoutSettingsCubit(),
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
          create: (context) => BudgetCubit(financeRepo: financeRepo),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(transactionsRepo: transactionsRepo),
        ),
        BlocProvider<WalletCubit>(
          create: (context) => WalletCubit(financeRepo: financeRepo),
        ),
        BlocProvider<GoalsCubit>(
          create: (context) => GoalsCubit(
            financeRepo: financeRepo,
            transactionsRepo: transactionsRepo,
          ),
        ),
        BlocProvider<AnalyticsCubit>(
          create: (context) =>
              AnalyticsCubit(analyticsRepo: AnalyticsRepository()),
        ),
        BlocProvider<AnalyticsAiChatCubit>(
          create: (context) =>
              AnalyticsAiChatCubit(repository: AiAnalyticsChatRepositoryImpl()),
        ),
        BlocProvider<ExportCubit>(
          create: (context) => ExportCubit(
            exportRepo: ExportRepository(),
            excelService: ExportExcelService(),
          ),
        ),
        BlocProvider<ScheduledPaymentsCubit>(
          create: (context) => ScheduledPaymentsCubit(financeRepo: financeRepo),
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
            context.read<HomeWalletsSettingsCubit>().clearForLogout();
            context.read<HomeLayoutSettingsCubit>().clearForLogout();
            context.read<ScheduledPaymentsCubit>().clearForLogout();
            context.read<AnalyticsAiChatCubit>().resetForLogout();
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
    final palette = themeProvider.state.palette;
    final useDynamic = themeProvider.state.preferDynamicColor;

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final hasDynamic = lightDynamic != null && darkDynamic != null;
        final applyDynamic = useDynamic && hasDynamic;

        final lightTheme = applyDynamic
            ? AppThemes.themeFromDynamicColor(lightDynamic)
            : AppThemes.themeFor(palette, Brightness.light);
        final darkTheme = applyDynamic
            ? AppThemes.themeFromDynamicColor(darkDynamic)
            : AppThemes.themeFor(palette, Brightness.dark);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'INFinance',
          initialRoute: AppRouter.main,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
