import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/app_update/app_update.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AppUpdateSheet extends StatelessWidget {
  const AppUpdateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AppUpdateCubit, AppUpdateState>(
      builder: (context, state) {
        final isDownloading = state is AppUpdateDownloading;
        final isRestart = state is AppUpdateReadyToRestart;
        final isError = state is AppUpdateError;
        final restartFailed =
            state is AppUpdateReadyToRestart && state.restartFailed;

        final title = isRestart
            ? context.l10n.appUpdateRestartTitle
            : context.l10n.appUpdateAvailableTitle;
        final subtitle = isDownloading
            ? context.l10n.appUpdateDownloadingSubtitle
            : isRestart
            ? context.l10n.appUpdateRestartSubtitle
            : context.l10n.appUpdateAvailableSubtitle;
        final buttonLabel = isError
            ? context.l10n.retry
            : isRestart
            ? context.l10n.appUpdateRestartButton
            : context.l10n.update;

        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSizing.bottomPadding,
            left: AppSizing.defaultPadding,
            right: AppSizing.defaultPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalSheetTitleWidget(
                title: title,
                subtitle: subtitle,
                action: Icon(
                  isRestart
                      ? Icons.restart_alt_rounded
                      : Icons.system_update_alt_rounded,
                  color: colorScheme.primary,
                  size: AppSizing.iconSizeL,
                ),
              ),
              if (isError || restartFailed) ...[
                const SizedBox(height: AppSizing.spaceBtwElements),
                Text(
                  restartFailed
                      ? context.l10n.appUpdateRestartFailed
                      : context.l10n.appUpdateFailed,
                  style: AppTextStyles.text14w400(
                    context,
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSizing.spaceBtwSections),
              PrimaryButton(
                text: buttonLabel,
                isLoading: isDownloading,
                onPressed: () {
                  if (isDownloading) return;
                  final cubit = context.read<AppUpdateCubit>();
                  if (isRestart) {
                    cubit.restartApp();
                    return;
                  }
                  cubit.downloadUpdate();
                },
              ),
              if (!isDownloading && !isRestart) ...[
                const SizedBox(height: AppSizing.spaceBtwItems),
                PrimaryButton(
                  text: context.l10n.cancel,
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSurface,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
