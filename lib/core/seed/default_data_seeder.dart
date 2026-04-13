import 'package:fn_tracker/features/features.dart';

/// Отвечает за создание данных по умолчанию при регистрации.
///
/// Принимает список [SeedTask], каждый из которых инкапсулирует
/// логику создания конкретного типа данных (кошельки, категории и т.д.).
/// Для добавления нового типа достаточно реализовать [SeedTask]
/// и передать его в конструктор.
class DefaultDataSeeder {
  DefaultDataSeeder({required this.tasks});

  final List<SeedTask> tasks;

  Future<void> seed() async {
    for (final task in tasks) {
      await task.execute();
    }
  }
}

/// Единица работы по сидированию данных.
abstract class SeedTask {
  const SeedTask();

  Future<void> execute();
}

/// Создаёт кошельки по умолчанию.
class WalletSeedTask extends SeedTask {
  const WalletSeedTask({required this.financeRepo, required this.wallets});

  final FinanceRepoImpl financeRepo;
  final List<WalletModel> wallets;

  @override
  Future<void> execute() async {
    for (final wallet in wallets) {
      await financeRepo.addWallet(wallet: wallet);
    }
  }
}

/// Создаёт категории по умолчанию.
class CategorySeedTask extends SeedTask {
  const CategorySeedTask({
    required this.categoryRepo,
    required this.categories,
  });

  final CategoryRepoImpl categoryRepo;
  final List<CategoryModel> categories;

  @override
  Future<void> execute() async {
    for (final category in categories) {
      await categoryRepo.addCategory(category: category);
    }
  }
}
