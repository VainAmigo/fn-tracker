import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/firebase_options.dart';
import 'package:fn_tracker/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String? _lastRoutedTo;

  @override
  Widget build(BuildContext context) {
    final firebaseAuthRepo = FirebaseAuthRepo();

    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth())],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, next) => next is Authenticated || next is Unauthenticated,
        listener: (context, state) {
          final nav = _navigatorKey.currentState;
          if (nav == null) return;

          String targetRoute;
          if (state is Authenticated) {
            targetRoute = AppRouter.app;
          } else if (state is Unauthenticated) {
            targetRoute = AppRouter.login;
          } else {
            return;
          }

          if (_lastRoutedTo == targetRoute) return;
          _lastRoutedTo = targetRoute;

          nav.pushNamedAndRemoveUntil(targetRoute, (route) => false);
        },
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'FN Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          initialRoute: AppRouter.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
