import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/firebase_options.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) =>
              CategoriesCubit(categoryRepo: CategoryRepository()),
        ),
        BlocProvider<TransactionsCubit>(
          create: (context) =>
              TransactionsCubit(transactionsRepo: TransactionsRepository()),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ],
        child: FnTracker(),
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      theme: AppThemes.themeFor(themeProvider.state.palette, Brightness.light),
      darkTheme: AppThemes.themeFor(
        themeProvider.state.palette,
        Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      home: const _AuthRoot(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class _AuthRoot extends StatelessWidget {
  const _AuthRoot();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return const AppMainView();
        if (state is Unauthenticated) return const LoginView();

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
