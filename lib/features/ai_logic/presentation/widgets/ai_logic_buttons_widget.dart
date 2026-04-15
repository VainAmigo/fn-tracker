import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

class AiLogicButtonsWidget extends StatelessWidget {
  const AiLogicButtonsWidget({
    super.key,
    required this.inputTab,
    required this.listening,
    required this.isParsing,
    required this.speechAvailable,
    required this.toggleSpeech,
    required this.choosePhotoAttachment,
    required this.pickPdf,
  });

  final AiInputTab inputTab;
  final bool listening;
  final bool isParsing;
  final bool speechAvailable;
  final void Function() toggleSpeech;
  final void Function() choosePhotoAttachment;
  final void Function() pickPdf;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        if (inputTab == AiInputTab.voice) ...[
          PrimaryButton(
            text: listening ? context.l10n.listening : context.l10n.listen,
            onPressed: isParsing || !speechAvailable ? null : toggleSpeech,
            icon: listening ? Icons.stop_rounded : Icons.mic_rounded,
            size: PrimaryButtonSize.large,
            backgroundColor: listening
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ] else ...[
          Row(
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              Expanded(
                child: PrimaryButton(
                  text: context.l10n.photo,
                  onPressed: isParsing ? null : choosePhotoAttachment,
                  icon: Icons.add_a_photo_outlined,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  text: context.l10n.pdf,
                  onPressed: isParsing ? null : pickPdf,
                  icon: Icons.picture_as_pdf_outlined,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
        PrimaryButton(
          text: isParsing ? context.l10n.processing : context.l10n.recognize,
          isLoading: isParsing,
          rounded: true,
          fullWidth: true,
          icon: Icons.auto_awesome,
          onPressed: isParsing
              ? null
              : () => context.read<AiLogicCubit>().runParse(),
        ),
        const SizedBox(height: AppSizing.bottomPadding),
      ],
    );
  }
}
