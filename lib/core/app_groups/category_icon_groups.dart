import 'package:flutter/material.dart';

class CategoryIcon {
  const CategoryIcon(this.id, this.icon);

  final String id;
  final IconData icon;
}

class CategoryIconGroup {
  const CategoryIconGroup({
    required this.label,
    required this.icon,
    required this.icons,
  });

  final String label;
  final IconData icon;
  final List<CategoryIcon> icons;
}

CategoryIcon? findIconById(String id) {
  for (final group in categoryIconGroups) {
    for (final icon in group.icons) {
      if (icon.id == id) return icon;
    }
  }
  return null;
}

CategoryIcon firstUnusedIcon(Set<String> usedIds) {
  for (final group in categoryIconGroups) {
    for (final icon in group.icons) {
      if (!usedIds.contains(icon.id)) return icon;
    }
  }
  return categoryIconGroups[0].icons.first;
}

const categoryIconGroups = [
  CategoryIconGroup(
    label: 'Food',
    icon: Icons.restaurant,
    icons: [
      CategoryIcon('food_restaurant', Icons.restaurant),
      CategoryIcon('food_coffee', Icons.coffee),
      CategoryIcon('food_local_bar', Icons.local_bar),
      CategoryIcon('food_bakery', Icons.bakery_dining),
      CategoryIcon('food_fastfood', Icons.fastfood),
      CategoryIcon('food_local_pizza', Icons.local_pizza),
      CategoryIcon('food_icecream', Icons.icecream),
      CategoryIcon('food_lunch_dining', Icons.lunch_dining),
      CategoryIcon('food_local_cafe', Icons.local_cafe),
      CategoryIcon('food_kitchen', Icons.kitchen),
    ],
  ),
  CategoryIconGroup(
    label: 'Transport',
    icon: Icons.directions_car,
    icons: [
      CategoryIcon('transport_car', Icons.directions_car),
      CategoryIcon('transport_bus', Icons.directions_bus),
      CategoryIcon('transport_train', Icons.train),
      CategoryIcon('transport_flight', Icons.flight),
      CategoryIcon('transport_bike', Icons.pedal_bike),
      CategoryIcon('transport_taxi', Icons.local_taxi),
      CategoryIcon('transport_subway', Icons.subway),
      CategoryIcon('transport_motorcycle', Icons.two_wheeler),
      CategoryIcon('transport_boat', Icons.directions_boat),
      CategoryIcon('transport_gas', Icons.local_gas_station),
    ],
  ),
  CategoryIconGroup(
    label: 'Health',
    icon: Icons.favorite,
    icons: [
      CategoryIcon('health_hospital', Icons.local_hospital),
      CategoryIcon('health_pharmacy', Icons.local_pharmacy),
      CategoryIcon('health_fitness', Icons.fitness_center),
      CategoryIcon('health_spa', Icons.spa),
      CategoryIcon('health_heart', Icons.favorite),
      CategoryIcon('health_medical', Icons.medical_services),
      CategoryIcon('health_psychology', Icons.psychology),
      CategoryIcon('health_vaccines', Icons.vaccines),
      CategoryIcon('health_monitor_heart', Icons.monitor_heart),
      CategoryIcon('health_self_care', Icons.self_improvement),
    ],
  ),
  CategoryIconGroup(
    label: 'Shopping',
    icon: Icons.shopping_bag,
    icons: [
      CategoryIcon('shop_bag', Icons.shopping_bag),
      CategoryIcon('shop_cart', Icons.shopping_cart),
      CategoryIcon('shop_gift', Icons.card_giftcard),
      CategoryIcon('shop_clothes', Icons.checkroom),
      CategoryIcon('shop_phone', Icons.phone_android),
      CategoryIcon('shop_laptop', Icons.laptop),
      CategoryIcon('shop_watch', Icons.watch),
      CategoryIcon('shop_storefront', Icons.storefront),
      CategoryIcon('shop_diamond', Icons.diamond),
      CategoryIcon('shop_headphones', Icons.headphones),
    ],
  ),
  CategoryIconGroup(
    label: 'Home',
    icon: Icons.home,
    icons: [
      CategoryIcon('home_house', Icons.home),
      CategoryIcon('home_electric', Icons.electric_bolt),
      CategoryIcon('home_water', Icons.water_drop),
      CategoryIcon('home_wifi', Icons.wifi),
      CategoryIcon('home_build', Icons.build),
      CategoryIcon('home_cleaning', Icons.cleaning_services),
      CategoryIcon('home_bed', Icons.bed),
      CategoryIcon('home_chair', Icons.chair),
      CategoryIcon('home_yard', Icons.yard),
      CategoryIcon('home_key', Icons.vpn_key),
    ],
  ),
  CategoryIconGroup(
    label: 'Education',
    icon: Icons.school,
    icons: [
      CategoryIcon('edu_school', Icons.school),
      CategoryIcon('edu_book', Icons.menu_book),
      CategoryIcon('edu_science', Icons.science),
      CategoryIcon('edu_calculate', Icons.calculate),
      CategoryIcon('edu_language', Icons.translate),
      CategoryIcon('edu_library', Icons.local_library),
      CategoryIcon('edu_draw', Icons.draw),
      CategoryIcon('edu_history', Icons.history_edu),
      CategoryIcon('edu_abc', Icons.abc),
      CategoryIcon('edu_code', Icons.code),
    ],
  ),
  CategoryIconGroup(
    label: 'Entertainment',
    icon: Icons.movie,
    icons: [
      CategoryIcon('fun_movie', Icons.movie),
      CategoryIcon('fun_music', Icons.music_note),
      CategoryIcon('fun_games', Icons.sports_esports),
      CategoryIcon('fun_theater', Icons.theater_comedy),
      CategoryIcon('fun_photo', Icons.photo_camera),
      CategoryIcon('fun_palette', Icons.palette),
      CategoryIcon('fun_headset', Icons.headset),
      CategoryIcon('fun_celebration', Icons.celebration),
      CategoryIcon('fun_casino', Icons.casino),
      CategoryIcon('fun_park', Icons.park),
    ],
  ),
  CategoryIconGroup(
    label: 'Family',
    icon: Icons.family_restroom,
    icons: [
      CategoryIcon('family_child', Icons.child_care),
      CategoryIcon('family_restroom', Icons.family_restroom),
      CategoryIcon('family_pets', Icons.pets),
      CategoryIcon('family_stroller', Icons.child_friendly),
      CategoryIcon('family_cake', Icons.cake),
      CategoryIcon('family_elderly', Icons.elderly),
      CategoryIcon('family_toys', Icons.toys),
      CategoryIcon('family_baby', Icons.baby_changing_station),
      CategoryIcon('family_people', Icons.people),
      CategoryIcon('family_heart', Icons.volunteer_activism),
    ],
  ),
  CategoryIconGroup(
    label: 'Finance',
    icon: Icons.savings,
    icons: [
      CategoryIcon('fin_savings', Icons.savings),
      CategoryIcon('fin_wallet', Icons.account_balance_wallet),
      CategoryIcon('fin_bank', Icons.account_balance),
      CategoryIcon('fin_credit', Icons.credit_card),
      CategoryIcon('fin_money', Icons.attach_money),
      CategoryIcon('fin_receipt', Icons.receipt_long),
      CategoryIcon('fin_trending', Icons.trending_up),
      CategoryIcon('fin_chart', Icons.pie_chart),
      CategoryIcon('fin_currency', Icons.currency_exchange),
      CategoryIcon('fin_payments', Icons.payments),
    ],
  ),
];
