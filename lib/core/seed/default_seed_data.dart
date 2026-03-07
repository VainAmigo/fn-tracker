import 'package:fn_tracker/features/features.dart';

/// Данные по умолчанию, которые создаются при регистрации.
///
/// Чтобы изменить стартовый набор — отредактируйте списки ниже.
class DefaultSeedData {
  DefaultSeedData._();

  static final wallets = [
    WalletModel(
      name: 'Cash',
      colorId: 'green_500',
      iconId: 'fin_wallet',
      isDefault: true,
    ),
    WalletModel(
      name: 'Card',
      colorId: 'blue_500',
      iconId: 'fin_credit',
      isDefault: false,
    ),
  ];

  static final categories = [
    CategoryModel(
      categoryId: '',
      name: 'Food',
      colorId: 'orange_500',
      iconId: 'food_restaurant',
    ),
    CategoryModel(
      categoryId: '',
      name: 'Transport',
      colorId: 'indigo_400',
      iconId: 'transport_car',
    ),
    CategoryModel(
      categoryId: '',
      name: 'Home',
      colorId: 'yellow_500',
      iconId: 'home_house',
    ),
    CategoryModel(
      categoryId: '',
      name: 'Shopping',
      colorId: 'red_400',
      iconId: 'shop_bag',
    ),
  ];
}
