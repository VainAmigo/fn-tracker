import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class NoteFormModalSheet extends StatefulWidget {
  const NoteFormModalSheet({super.key, this.initialNote = ''});

  final String initialNote;

  /// `null` — шит закрыли свайпом, пустая строка — «Пропустить».
  static Future<String?> show(BuildContext context, {String initialNote = ''}) {
    return AppBottomSheet.showFittedModalBottomSheet<String>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: NoteFormModalSheet(initialNote: initialNote),
    );
  }

  @override
  State<NoteFormModalSheet> createState() => _NoteFormModalSheetState();
}

class _NoteFormModalSheetState extends State<NoteFormModalSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ModalSheetTitleWidget(title: context.l10n.addNote),
          const SizedBox(height: AppSizing.spaceBtwElements),
          CustomTextFormField(
            autofocus: true,
            hintText: context.l10n.enterYourNote,
            controller: _controller,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          PrimaryButton(
            text: context.l10n.save,
            onPressed: () {
              Navigator.of(context).pop(_controller.text.trim());
            },
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(context.l10n.skip),
            ),
          ),
        ],
      ),
    );
  }
}
