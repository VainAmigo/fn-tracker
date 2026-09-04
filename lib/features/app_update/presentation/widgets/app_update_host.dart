import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/app_update/app_update.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Проверяет патчи Shorebird и показывает шит обновления.
class AppUpdateHost extends StatefulWidget {
  const AppUpdateHost({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateHost> createState() => _AppUpdateHostState();
}

class _AppUpdateHostState extends State<AppUpdateHost>
    with WidgetsBindingObserver {
  var _sheetOpen = false;
  var _skippedAvailableThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppUpdateCubit>().checkForUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppUpdateCubit>().checkForUpdate();
    }
  }

  bool _shouldPrompt(AppUpdateState state) {
    return switch (state) {
      AppUpdateAvailable() ||
      AppUpdateDownloading() ||
      AppUpdateReadyToRestart() => true,
      AppUpdateError(:final fromDownload) => fromDownload,
      _ => false,
    };
  }

  Future<void> _openSheet() async {
    if (_sheetOpen || !mounted) return;
    _sheetOpen = true;
    await AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      child: const AppUpdateSheet(),
    );
    if (!mounted) return;
    _sheetOpen = false;
    if (context.read<AppUpdateCubit>().state is AppUpdateAvailable) {
      _skippedAvailableThisSession = true;
    }
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateCubit, AppUpdateState>(
      listener: (context, state) {
        if (state.userInitiated) {
          _skippedAvailableThisSession = false;
        }

        if (_shouldPrompt(state)) {
          final skipAvailable =
              state is AppUpdateAvailable &&
              _skippedAvailableThisSession &&
              !state.userInitiated;
          if (!skipAvailable) {
            _openSheet();
          }
          return;
        }

        if (!state.userInitiated) return;
        switch (state) {
          case AppUpdateUpToDate():
            _showMessage(context.l10n.appUpdateUpToDate);
          case AppUpdateUnavailable():
            _showMessage(context.l10n.appUpdateUnavailable);
          case AppUpdateError():
            _showMessage(context.l10n.appUpdateFailed);
          default:
            break;
        }
      },
      child: widget.child,
    );
  }
}
