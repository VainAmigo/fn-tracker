import 'package:flutter/material.dart';

class AppMainView extends StatelessWidget {
  const AppMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
          child: Column(children: [Text('App main view')]),
        ),
      ),
    );
  }
}
