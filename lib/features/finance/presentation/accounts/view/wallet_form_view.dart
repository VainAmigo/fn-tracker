import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletFormView extends StatefulWidget {
  const WalletFormView({super.key, this.wallet});

  final WalletModel? wallet;

  @override
  State<WalletFormView> createState() => _WalletFormViewState();
}

class _WalletFormViewState extends State<WalletFormView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  late TextEditingController _nameController;
  late bool _isDefault;
  bool _isSubmitting = false;
  bool _defaultsInitialized = false;

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    if (wallet != null) {
      _nameController = TextEditingController(text: wallet.name);
      _selectedIcon = findIconById(wallet.iconId)!;
      _selectedShade = findShadeById(wallet.colorId)!;
      _isDefault = wallet.isDefault;
      _defaultsInitialized = true;
    } else {
      _nameController = TextEditingController();
      _selectedIcon = categoryIconGroups[0].icons.first;
      _selectedShade = categoryColorPalettes[0].shades.first;
      _isDefault = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      _selectedIcon = firstUnusedIcon(usedIds.iconIds);
      _selectedShade = firstUnusedShade(usedIds.colorIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ({Set<String> colorIds, Set<String> iconIds}) _collectUsedIds(
    BuildContext context,
  ) {
    final wallets = context.read<WalletCubit>().currentWallets;
    final categories = context.read<CategoriesCubit>().currentCategories;

    final editingId = widget.wallet?.id;

    final usedColorIds = <String>{};
    final usedIconIds = <String>{};

    for (final w in wallets) {
      if (w.id == editingId) continue;
      usedColorIds.add(w.colorId);
      usedIconIds.add(w.iconId);
    }
    for (final c in categories) {
      usedColorIds.add(c.colorId);
      usedIconIds.add(c.iconId);
    }

    return (colorIds: usedColorIds, iconIds: usedIconIds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final walletsState = context.watch<WalletCubit>().state;
    final isLoading = _isSubmitting && walletsState is WalletsLoading;
    final usedIds = _collectUsedIds(context);

    return BlocListener<WalletCubit, WalletsState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is WalletsLoaded) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? context.l10n.walletUpdatedSuccessfully
                    : context.l10n.walletCreatedSuccessfully,
              ),
            ),
          );
          Navigator.of(context).pop();
        }
        if (state is WalletsError) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? context.l10n.updateWallet : context.l10n.createWallet),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSizing.spaceBtwElements,
                      children: [
                        const SizedBox(height: AppSizing.spaceBtwElements),
                        _buildPreview(context),
                        CustomTextFormField(
                          label: context.l10n.walletName,
                          controller: _nameController,
                        ),
                        CreateCategoryIconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: _selectedShade.color,
                          onIconSelected: (icon) =>
                              setState(() => _selectedIcon = icon),
                          usedIconIds: usedIds.iconIds,
                        ),
                        CreateCategoryColorPickerWidget(
                          selectedShade: _selectedShade,
                          onShadeSelected: (shade) =>
                              setState(() => _selectedShade = shade),
                          usedColorIds: usedIds.colorIds,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                PrimaryButton(
                  text: _isEditing ? context.l10n.updateWallet : context.l10n.createWallet,
                  onPressed: isLoading ? null : _submitWallet,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizing.heightL,
        height: AppSizing.heightL,
        decoration: BoxDecoration(
          color: _selectedShade.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Icon(
          _selectedIcon.icon,
          size: AppSizing.iconSizeL,
          color: _selectedShade.color,
        ),
      ),
    );
  }

  void _submitWallet() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.nameIsRequired)));
      return;
    }

    setState(() => _isSubmitting = true);

    final wallet = WalletModel(
      id: widget.wallet?.id,
      name: name,
      colorId: _selectedShade.id,
      iconId: _selectedIcon.id,
      balance: widget.wallet?.balance,
      isDefault: _isDefault,
      hideAmount: widget.wallet?.hideAmount ?? false,
      isHidden: widget.wallet?.isHidden ?? false,
    );

    if (_isEditing) {
      context.read<WalletCubit>().updateWallet(wallet: wallet);
    } else {
      context.read<WalletCubit>().addWallet(wallet: wallet);
    }
  }
}
