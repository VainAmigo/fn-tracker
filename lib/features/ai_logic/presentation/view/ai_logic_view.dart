import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum AiInputTab { voice, attachment }

class AiLogicView extends StatefulWidget {
  const AiLogicView({super.key});

  @override
  State<AiLogicView> createState() => _AiLogicViewState();
}

class _AiLogicViewState extends State<AiLogicView> {
  final _textController = TextEditingController();
  late AiInputTab _inputTab;
  final _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;
  bool _saving = false;

  static const _segments = [
    SegmentItem<AiInputTab>(
      value: AiInputTab.voice,
      label: 'Голос',
      icon: Icons.mic_rounded,
    ),
    SegmentItem<AiInputTab>(
      value: AiInputTab.attachment,
      label: 'Файл',
      icon: Icons.attach_file_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final mode = context.read<AiLogicCubit>().state.entryMode;
    _inputTab = mode == AiLogicEntryMode.voice
        ? AiInputTab.voice
        : AiInputTab.attachment;
    _textController.text = context.read<AiLogicCubit>().state.editableText;
    _textController.addListener(_onTextChanged);
    _initSpeech();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiLogicCubit, AiLogicState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener: (context, state) {
        final msg = state.errorMessage;
        if (msg != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          context.read<AiLogicCubit>().resetError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Добавление траты')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizing.defaultPadding,
              ),
              child: state is AiLogicDraftsReady
                  ? _buildDrafts(context, state)
                  : _buildInput(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context, AiLogicState state) {
    final isParsing = state is AiLogicParsing;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TabTitleWidget(
                  title: 'Добавление траты с помощью AI',
                  subtitle:
                      'Введите траты вручную или используйте готовые шаблоны',
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                SegmentedControl<AiInputTab>(
                  segments: _segments,
                  height: AppSizing.heightS,
                  selectedValue: _inputTab,
                  onChanged: (v) => setState(() => _inputTab = v),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                if (state.attachmentBytes != null &&
                    state.attachmentBytes!.isNotEmpty &&
                    _inputTab == AiInputTab.attachment) ...[
                  const SizedBox(height: AppSizing.spaceBtwElements),
                  Text(
                    state.attachmentName ?? 'Вложение',
                    style: AppTextStyles.listTileTitle(context),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  if ((state.attachmentMime ?? '').startsWith('image/'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizing.borderRadius8,
                      ),
                      child: Image.memory(
                        Uint8List.fromList(state.attachmentBytes!),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Icon(Icons.insert_drive_file, size: 64),
                  PrimaryButton(
                    onPressed: isParsing
                        ? null
                        : () => context.read<AiLogicCubit>().clearAttachment(),
                    text: 'Убрать файл',
                    icon: Icons.folder_delete_outlined,
                    size: PrimaryButtonSize.xSmall,
                    rounded: true,
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                ] else if (_inputTab == AiInputTab.voice) ...[
                  const SizedBox(height: AppSizing.spaceBtwElements),
                  CustomTextFormField(
                    controller: _textController,
                    maxLines: 3,
                    readOnly: isParsing,
                    hintText: 'Текст можно отредактировать',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        AiLogicButtonsWidget(
          inputTab: _inputTab,
          listening: _listening,
          isParsing: isParsing,
          speechAvailable: _speechAvailable,
          toggleSpeech: _toggleSpeech,
          choosePhotoAttachment: _choosePhotoAttachment,
          pickPdf: _pickPdf,
        ),
      ],
    );
  }

  Widget _buildDrafts(BuildContext context, AiLogicDraftsReady state) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        return BlocBuilder<WalletCubit, WalletsState>(
          builder: (context, walletState) {
            return BlocBuilder<GoalsCubit, GoalsState>(
              builder: (context, goalsState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.drafts.length,
                        separatorBuilder: (_, _) => const SizedBox(
                          height: AppSizing.spaceBtwItemsExtra,
                        ),
                        itemBuilder: (context, index) {
                          final d = state.drafts[index];
                          final cat = _category(catState, d.categoryId);
                          final wal = _wallet(walletState, d.walletId);
                          final gl = _goal(goalsState, d.goalId);
                          return AiLogicDraftTile(
                            draft: d,
                            category: cat,
                            wallet: wal,
                            goal: gl,
                            onAccountTap: () => _openAccount(context, index, d),
                            onCategoryTap: () =>
                                _openCategory(context, index, d),
                            onDateTap: () => _pickDateForDraft(index, d),
                            onDraftChanged: (next) {
                              context.read<AiLogicCubit>().updateDraft(
                                index,
                                next,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    PrimaryButton(
                      text: 'Отменить и вернуться к вводу',
                      onPressed: () =>
                          context.read<AiLogicCubit>().backToInput(),
                      icon: Icons.arrow_back_rounded,
                      size: PrimaryButtonSize.xSmall,
                      rounded: true,
                      fullWidth: true,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItems),
                    PrimaryButton(
                      text: state.drafts.length > 1
                          ? 'Сохранить все'
                          : 'Сохранить',
                      isLoading: _saving,
                      rounded: true,
                      fullWidth: true,
                      onPressed: _saving ? null : () => _saveDrafts(context),
                    ),
                    const SizedBox(height: AppSizing.bottomPadding),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = ok);
  }

  void _onTextChanged() {
    context.read<AiLogicCubit>().setEditableText(_textController.text);
  }

  void _refreshAppData(BuildContext context) {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    context.read<HomeCubit>().getHomePageStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
    context.read<AnalyticsCubit>().loadAnalytics();
    context.read<WalletCubit>().loadWallets();
    context.read<GoalsCubit>().loadGoals();
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }

  Future<void> _toggleSpeech() async {
    if (!_speechAvailable) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        _textController.text = r.recognizedWords;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      },
      localeId: speechRecognitionLocaleId(context),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final mime = x.mimeType ?? 'image/jpeg';
    if (!mounted) return;
    context.read<AiLogicCubit>().setAttachment(
      bytes: bytes,
      mimeType: mime,
      name: x.name,
    );
  }

  Future<void> _choosePhotoAttachment() async {
    final source = await AppBottomSheet.showFittedModalBottomSheet<ImageSource>(
      context,
      child: Builder(
        builder: (sheetContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Камера'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Галерея'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              const SizedBox(height: AppSizing.bottomPadding),
            ],
          );
        },
      ),
    );
    if (!mounted || source == null) return;
    await _pickImageFromSource(source);
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (r == null || r.files.isEmpty) return;
    final f = r.files.single;
    final bytes = f.bytes;
    if (bytes == null) return;
    if (!mounted) return;
    context.read<AiLogicCubit>().setAttachment(
      bytes: bytes,
      mimeType: 'application/pdf',
      name: f.name,
    );
  }

  Future<void> _pickDateForDraft(int index, AiTransactionDraft draft) async {
    await AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      child: AddTransactionDateSheetWidget(
        initialDate: draft.date,
        onDateSelected: (d) {
          context.read<AiLogicCubit>().updateDraft(
            index,
            draft.copyWith(date: DateUtils.dateOnly(d)),
          );
        },
      ),
    );
  }

  CategoryModel? _category(CategoriesState categoriesState, String? id) {
    if (id == null || id.isEmpty) return null;
    if (categoriesState is! CategoriesLoaded) return null;
    for (final c in categoriesState.categories) {
      if (c.categoryId == id) return c;
    }
    return null;
  }

  WalletModel? _wallet(WalletsState ws, String? id) {
    if (id == null) return null;
    final list = switch (ws) {
      WalletsLoaded s => s.wallets,
      _ => const <WalletModel>[],
    };
    for (final w in list) {
      if (w.id == id) return w;
    }
    return null;
  }

  GoalModel? _goal(GoalsState gs, String? id) {
    if (id == null) return null;
    final goals = switch (gs) {
      GoalsLoaded s => s.goalsModel.goals,
      _ => const <GoalModel>[],
    };
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  Future<void> _saveDrafts(BuildContext context) async {
    final currency = context.read<CurrencyProvider>().currency.code;
    setState(() => _saving = true);
    try {
      final created = await context.read<AiLogicCubit>().saveAllDrafts(
        currencyCode: currency,
      );
      if (!context.mounted) return;
      context.read<TransactionsCubit>().addTransactionsLocally(created);
      _refreshAppData(context);
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openCategory(
    BuildContext context,
    int index,
    AiTransactionDraft draft,
  ) async {
    if (draft.transactionType != TransactionType.expense) return;
    final picked =
        await AppBottomSheet.showFittedModalBottomSheet<CategoryModel>(
          context,
          child: const AddTransactionCategorySheetWidget(),
        );
    if (!context.mounted || picked == null) return;
    context.read<AiLogicCubit>().updateDraft(
      index,
      draft.copyWith(categoryId: picked.categoryId),
    );
  }

  Future<void> _openAccount(
    BuildContext context,
    int index,
    AiTransactionDraft draft,
  ) async {
    final walletCubit = context.read<WalletCubit>();
    final goalsCubit = context.read<GoalsCubit>();
    final picked = await AppBottomSheet.showFittedModalBottomSheet<Object>(
      context,
      child: BlocProvider<WalletCubit>.value(
        value: walletCubit,
        child: BlocProvider<GoalsCubit>.value(
          value: goalsCubit,
          child: const AddTransactionAccountsSheetWidget(),
        ),
      ),
    );
    if (!context.mounted || picked == null) return;
    if (picked is WalletModel) {
      context.read<AiLogicCubit>().updateDraft(
        index,
        draft.copyWith(walletId: picked.id, clearGoal: true),
      );
    } else if (picked is GoalModel) {
      context.read<AiLogicCubit>().updateDraft(
        index,
        draft.copyWith(goalId: picked.id, clearWallet: true),
      );
    }
  }
}
