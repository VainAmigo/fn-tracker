import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/export/export.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class ExportSettingsView extends StatelessWidget {
  const ExportSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.exportSettings),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: BlocBuilder<ExportCubit, ExportState>(
            builder: (context, state) {
              final l10n = context.l10n;
              final selected = state.settings.columnsOrder;
              final available = ExportColumn.values
                  .where((c) => !selected.contains(c))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitledSection(
                    title: context.l10n.period,
                    children: [
                      SegmentedControl<ExportPeriodPreset>(
                        segments: [
                          SegmentItem(
                            value: ExportPeriodPreset.week,
                            label: context.l10n.week,
                          ),
                          SegmentItem(
                            value: ExportPeriodPreset.month,
                            label: context.l10n.month,
                          ),
                          SegmentItem(
                            value: ExportPeriodPreset.threeMonths,
                            label: context.l10n.threeMonths,
                          ),
                          SegmentItem(
                            value: ExportPeriodPreset.sixMonths,
                            label: context.l10n.sixMonths,
                          ),
                          SegmentItem(
                            value: ExportPeriodPreset.custom,
                            label: context.l10n.custom,
                          ),
                        ],
                        selectedValue: state.settings.periodPreset,
                        onChanged: (value) async {
                          if (value == ExportPeriodPreset.custom) {
                            await _pickCustomRange(context);
                            return;
                          }
                          if (!context.mounted) return;
                          context.read<ExportCubit>().setPeriodPreset(value);
                        },
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItems),
                      if (state.settings.periodPreset ==
                          ExportPeriodPreset.custom)
                        SelectableCard(
                          isSelected: true,
                          onTap: () => _pickCustomRange(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizing.defaultPadding,
                              vertical: AppSizing.spaceBtwItems,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range),
                                const SizedBox(width: AppSizing.spaceBtwItems),
                                Expanded(
                                  child: Text(
                                    _periodSubtitle(state.settings, context),
                                    style: AppTextStyles.text14w400(context),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizing.spaceBtwElements),
                  Text(
                    context.l10n.selectedColumns,
                    style: AppTextStyles.sectionTitle(context),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selected.length,
                            buildDefaultDragHandles: false,
                            onReorder: context
                                .read<ExportCubit>()
                                .reorderColumns,
                            itemBuilder: (context, index) {
                              final column = selected[index];
                              return Card(
                                key: ValueKey(column.name),
                                margin: const EdgeInsets.only(
                                  bottom: AppSizing.spaceBtwItemsExtra,
                                ),
                                child: ListTile(
                                  title: Text(
                                    column.title(l10n),
                                    style: AppTextStyles.listTileTitle(context),
                                  ),
                                  tileColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadiusFor(
                                      radiusForIndex(index, selected.length),
                                    ),
                                  ),
                                  subtitle: Text(
                                    column.description(l10n),
                                    style: AppTextStyles.listTileSubtitle(
                                      context,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.check_circle_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => context
                                            .read<ExportCubit>()
                                            .toggleColumn(column),
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(Icons.drag_handle),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (available.isNotEmpty) ...[
                            const SizedBox(height: AppSizing.spaceBtwElements),
                            TitledSection(
                              title: context.l10n.available,
                              children: [
                                ...available.map(
                                  (column) => Card(
                                    margin: const EdgeInsets.only(
                                      bottom: AppSizing.spaceBtwItemsExtra,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        column.title(l10n),
                                        style: AppTextStyles.listTileTitle(
                                          context,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizing.borderRadius4,
                                        ),
                                      ),
                                      tileColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      subtitle: Text(
                                        column.description(l10n),
                                        style: AppTextStyles.listTileSubtitle(
                                          context,
                                        ),
                                      ),
                                      leading: Icon(
                                        Icons.add_circle_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                      ),
                                      onTap: () => context
                                          .read<ExportCubit>()
                                          .toggleColumn(column),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSizing.spaceBtwElements),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    text: context.l10n.save,
                    rounded: true,
                    size: PrimaryButtonSize.xSmall,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: state.isExporting
                        ? null
                        : () => _onSavePressed(context),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  PrimaryButton(
                    text: context.l10n.export,
                    rounded: true,
                    onPressed: state.isExporting
                        ? null
                        : () => _runExportFromSettings(context),
                    icon: Icons.file_download_outlined,
                    isLoading: state.isExporting,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwElements),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final cubit = context.read<ExportCubit>();
    final state = cubit.state;
    final initialRange = DateTimeRange(
      start:
          state.settings.customStart ??
          DateTime.now().subtract(const Duration(days: 30)),
      end: state.settings.customEnd ?? DateTime.now(),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
    );
    if (picked == null || !context.mounted) return;
    cubit.setCustomRange(picked.start, picked.end);
  }

  Future<void> _onSavePressed(BuildContext context) async {
    final cubit = context.read<ExportCubit>();
    final wasConfigured = cubit.state.hasConfiguredExport;
    cubit.saveSettings();
    if (!wasConfigured) {
      await _runExportFromSettings(context);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.settingsSaved)));
  }

  Future<void> _runExportFromSettings(BuildContext context) async {
    final cubit = context.read<ExportCubit>();
    final localeCode = Localizations.localeOf(context).languageCode;
    final status = await cubit.runExportWithSavedSettingsForLocale(
      localeLanguageCode: localeCode,
    );
    if (!context.mounted) return;
    final text = switch (status) {
      ExportRunStatus.success => context.l10n.exportFileIsReady,
      ExportRunStatus.successWithoutShare =>
        context.l10n.fileCreatedButShareDialogIsUnavailableOnThisDevice,
      ExportRunStatus.noData => context.l10n.noDataForSelectedPeriod,
      ExportRunStatus.missingPeriod =>
        context.l10n.choosePeriodInExportSettings,
      ExportRunStatus.failed =>
        '${context.l10n.failedToExportData}: ${cubit.state.lastError ?? context.l10n.unknownError}',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _periodSubtitle(ExportSettings settings, BuildContext context) {
    if (settings.periodPreset == ExportPeriodPreset.custom &&
        settings.customStart != null &&
        settings.customEnd != null) {
      return '${context.l10n.custom}: ${settings.customStart!.formatDotDate} - ${settings.customEnd!.formatDotDate}';
    }
    return context.l10n.customPeriod;
  }
}
