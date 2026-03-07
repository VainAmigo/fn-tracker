import 'package:flutter/widgets.dart';

class WalletsListWidget extends StatefulWidget {
  const WalletsListWidget({super.key});

  @override
  State<WalletsListWidget> createState() => _WalletsListWidgetState();
}

class _WalletsListWidgetState extends State<WalletsListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Wallets'),
    );
  }
}