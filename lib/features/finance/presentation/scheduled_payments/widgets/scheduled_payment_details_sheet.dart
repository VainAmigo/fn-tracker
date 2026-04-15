import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledPaymentDetailsSheet extends StatefulWidget {
  const ScheduledPaymentDetailsSheet({
    super.key,
    required this.payment,
    required this.onEdit,
    this.onPause,
    this.onDelete,
    this.onCreatePaymentNow,
  });

  final ScheduledPaymentModel payment;
  final VoidCallback onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;
  final VoidCallback? onCreatePaymentNow;

  @override
  State<ScheduledPaymentDetailsSheet> createState() =>
      _ScheduledPaymentDetailsSheetState();
}

class _ScheduledPaymentDetailsSheetState
    extends State<ScheduledPaymentDetailsSheet> {
  bool _loadTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadTriggered &&
        widget.payment.frequency == ScheduledPaymentFrequency.oneTime) {
      _loadTriggered = true;
      context.read<TransactionsCubit>().loadTransactionsById(
            TransactionIdType.scheduledPayment,
            widget.payment.id,
            TransactionPeriod.sixMonths,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOneTime =
        widget.payment.frequency == ScheduledPaymentFrequency.oneTime;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: isOneTime
          ? BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                final allTransactions = state is TransactionsLoaded
                    ? state.transactions
                    : <TransactionModel>[];
                final transactions = allTransactions
                    .where((t) => t.scheduledPaymentId == widget.payment.id)
                    .toList();
                final isPaid = transactions.isNotEmpty;
                final paidDate = isPaid ? transactions.first.date : null;
                return _buildContent(
                  context,
                  colorScheme: colorScheme,
                  isPaid: isPaid,
                  paidDate: paidDate,
                );
              },
            )
          : _buildContent(
              context,
              colorScheme: colorScheme,
              isPaid: false,
              paidDate: null,
            ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required ColorScheme colorScheme,
    required bool isPaid,
    required DateTime? paidDate,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
              ModalSheetTitleWidget(
                title: context.l10n.scheduledPayment,
                action: PrimaryButton(
                  text: context.l10n.edit,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onEdit();
                  },
                  size: PrimaryButtonSize.xSmall,
                  rounded: true,
                  fullWidth: false,
                ),
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              ScheduledPaymentCard(payment: widget.payment),
              if (isPaid && paidDate != null) ...[
                const SizedBox(height: AppSizing.spaceBtwElements),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizing.spaceBtwElements,
                    vertical: AppSizing.spaceBtwItemsExtra,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppSizing.borderRadius8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: AppSizing.iconSizeM,
                      ),
                      const SizedBox(width: AppSizing.spaceBtwItems),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.paid,
                            style: AppTextStyles.text14w400(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            paidDate.formatDotDate,
                            style: AppTextStyles.text12w400(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizing.spaceBtwElements),
              PrimaryButton(
                text: context.l10n.history,
                icon: Icons.history,
                size: PrimaryButtonSize.xSmall,
                rounded: true,
                backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
                foregroundColor: colorScheme.tertiary,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRouter.transactionsById,
                  arguments: {
                    'idType': TransactionIdType.scheduledPayment,
                    'id': widget.payment.id,
                  },
                ),
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              _InfoRow(
                label: context.l10n.autoCreateTransaction,
                value: widget.payment.autoCreateTransaction ? 'Да' : 'Нет',
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: AppSizing.spaceBtwItemsExtra,
                children: [
                  PrimaryButton(
                    text: context.l10n.pause,
                    icon: Icons.pause,
                    iconOnly: true,
                    onPressed: widget.onPause,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.primary,
                    size: PrimaryButtonSize.large,
                    paddingStyle: PrimaryButtonPaddingStyle.slim,
                    rounded: true,
                    fullWidth: false,
                  ),
                  PrimaryButton(
                    text: context.l10n.delete,
                    onPressed: widget.onDelete,
                    size: PrimaryButtonSize.large,
                    paddingStyle: PrimaryButtonPaddingStyle.slim,
                    backgroundColor: colorScheme.error.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.error,
                    icon: Icons.delete,
                    iconOnly: true,
                    rounded: true,
                    fullWidth: false,
                  ),
                  Expanded(
                    child: PrimaryButton(
                      text: isPaid
                          ? context.l10n.repeat
                          : widget.payment.type ==
                                  ScheduledPaymentType.regularIncome
                              ? context.l10n.deposit
                              : context.l10n.pay,
                      size: PrimaryButtonSize.large,
                      onPressed: isPaid
                          ? () {
                              Navigator.of(context).pop();
                              widget.onEdit();
                            }
                          : widget.onCreatePaymentNow,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: AppSizing.bottomPadding),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItems),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.text14w400(context)),
          Text(value, style: AppTextStyles.text14w400(context)),
        ],
      ),
    );
  }
}
