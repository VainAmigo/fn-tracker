import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/main/presentation/view/app_main_view.dart';
import 'package:fn_tracker/firebase_options.dart';

import 'features/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthRepo = FirebaseAuthRepo();

    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: const AuthGate(),
      ),
    );
  }
}
