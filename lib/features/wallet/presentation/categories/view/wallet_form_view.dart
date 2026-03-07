import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
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
    } else {
      _nameController = TextEditingController();
      _selectedIcon = categoryIconGroups[0].icons.first;
      _selectedShade = categoryColorPalettes[0].shades.first;
      _isDefault = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final walletsState = context.watch<WalletCubit>().state;
    final isLoading = _isSubmitting && walletsState is WalletsLoading;

    return BlocListener<WalletCubit, WalletsState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is WalletsLoaded) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Wallet updated successfully'
                    : 'Wallet created successfully',
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
          title: Text(_isEditing ? 'Update Wallet' : 'Create Wallet'),
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
                          label: 'Wallet name',
                          hintText: 'e.g. Cash',
                          controller: _nameController,
                        ),
                        if (_isEditing)
                          CategoryCard(
                            title: _isDefault ? 'Yes' : 'No',
                            subtitle: 'Default wallet',
                            leading: Icon(
                              _isDefault ? Icons.star : Icons.star_border,
                              color: colorScheme.onSecondary,
                            ),
                            onTap: widget.wallet!.isDefault
                                ? null
                                : () => setState(() => _isDefault = !_isDefault),
                          ),
                        CreateCategoryIconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: _selectedShade.color,
                          onIconSelected: (icon) =>
                              setState(() => _selectedIcon = icon),
                        ),
                        CreateCategoryColorPickerWidget(
                          selectedShade: _selectedShade,
                          onShadeSelected: (shade) =>
                              setState(() => _selectedShade = shade),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                if (_isEditing) ...[
                  PrimaryButton(
                    text: 'Delete',
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.primary,
                    size: PrimaryButtonSize.small,
                    rounded: true,
                    onPressed: isLoading ? null : _deleteWallet,
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                ],
                PrimaryButton(
                  text: _isEditing ? 'Update' : 'Create',
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

  void _deleteWallet() {
    setState(() => _isSubmitting = true);
    context.read<WalletCubit>().deleteWallet(
          walletId: widget.wallet!.id!,
        );
  }

  void _submitWallet() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
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
    );

    if (_isEditing) {
      context.read<WalletCubit>().updateWallet(wallet: wallet);
    } else {
      context.read<WalletCubit>().addWallet(wallet: wallet);
    }
  }
}
