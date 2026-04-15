import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsAiChatTabWidget extends StatefulWidget {
  const AnalyticsAiChatTabWidget({super.key});

  @override
  State<AnalyticsAiChatTabWidget> createState() =>
      _AnalyticsAiChatTabWidgetState();
}

class _AnalyticsAiChatTabWidgetState extends State<AnalyticsAiChatTabWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearChat() {
    context.read<AnalyticsAiChatCubit>().clearChat();
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<AnalyticsAiChatCubit>().sendUserMessage(text, context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<AnalyticsAiChatCubit, AnalyticsAiChatState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener: (context, state) {
        final msg = state.errorMessage;
        if (msg != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          context.read<AnalyticsAiChatCubit>().clearError();
        }
      },
      builder: (context, state) {
        final canClear = state.messages.isNotEmpty;
        final sending = state.isSending;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabTitleWidget(
              title: context.l10n.deepAnalytics,
              subtitle: context.l10n.askAboutYourAnalyticsForThisPeriod,
              action: IconButton(
                tooltip: context.l10n.clearChat,
                onPressed: canClear ? _clearChat : null,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: canClear
                      ? colorScheme.tertiary
                      : colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                vertical: AppSizing.spaceBtwItems,
              ),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSizing.spaceBtwItems,
                  ),
                  child: _AnalyticsAiChatBubble(message: message),
                );
              },
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _controller,
                    hintText: context.l10n.askAboutYourAnalyticsForThisPeriod,
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    readOnly: sending,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSizing.spaceBtwItems),
                PrimaryButton(
                  text: '',
                  icon: Icons.send_rounded,
                  iconOnly: true,
                  fullWidth: false,
                  size: PrimaryButtonSize.medium,
                  isLoading: sending,
                  onPressed: sending || _controller.text.trim().isEmpty
                      ? null
                      : _onSend,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsAiChatBubble extends StatelessWidget {
  const _AnalyticsAiChatBubble({required this.message});

  final AnalyticsAiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.role == AnalyticsAiMessageRole.user;

    if (message.isPending) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _TypingDots(color: colorScheme.onSecondary),
      );
    }

    final bg = isUser ? colorScheme.primary : colorScheme.secondary;
    final fg = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final timeStyle = AppTextStyles.listTileSubtitle(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSizing.borderRadius16),
              topRight: const Radius.circular(AppSizing.borderRadius16),
              bottomLeft: Radius.circular(
                isUser ? AppSizing.borderRadius16 : 4,
              ),
              bottomRight: Radius.circular(
                isUser ? 4 : AppSizing.borderRadius16,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.spaceBtwElements,
              vertical: AppSizing.spaceBtwItems,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: AppTextStyles.text16w400(context).copyWith(color: fg),
                ),
                const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                Text(
                  _formatTime(message.sentAt),
                  style: timeStyle.copyWith(
                    color: fg.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});

  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (t + i * 0.2) % 1.0;
                final opacity =
                    0.25 + 0.55 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
