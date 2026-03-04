// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fn_tracker/features/features.dart';
//
// /// Экран списка транзакций (примитивный white box)
// class TransactionsListView extends StatefulWidget {
//   const TransactionsListView({super.key});
//
//   @override
//   State<TransactionsListView> createState() => _TransactionsListViewState();
// }
//
// class _TransactionsListViewState extends State<TransactionsListView> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<TransactionsCubit>().loadTransactions();
//     // Параллельно подгружаем категории, чтобы можно было показать имена категорий
//     context.read<CategoriesCubit>().loadCategories();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Транзакции')),
//       body: BlocBuilder<TransactionsCubit, TransactionsState>(
//         builder: (context, state) {
//           if (state is TransactionsLoading || state is TransactionsInitial) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is TransactionsError) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Не удалось загрузить транзакции',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     state.message,
//                     style: Theme.of(context).textTheme.bodySmall,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () =>
//                         context.read<TransactionsCubit>().loadTransactions(),
//                     child: const Text('Повторить'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final transactions = switch (state) {
//             TransactionsLoaded s => s.transactions,
//             TransactionCreateSuccess s => s.transactions,
//             TransactionCreating s => s.previousTransactions,
//             TransactionCreateError s =>
//               s.previousTransactions ?? const <TransactionModel>[],
//             TransactionsEmpty _ => const <TransactionModel>[],
//             _ => const <TransactionModel>[],
//           };
//
//           if (transactions.isEmpty) {
//             return Center(
//               child: Text(
//                 'Транзакций пока нет',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             );
//           }
//           // Берём категории из CategoriesCubit, чтобы сгруппировать транзакции по категориям
//           final categoriesState = context.watch<CategoriesCubit>().state;
//           final categories = switch (categoriesState) {
//             CategoriesLoaded s => s.categories,
//             CategoryCreateSuccess s => s.categories,
//             CategoryCreating s => s.previousCategories,
//             CategoryCreateError s =>
//               s.previousCategories ?? const <CategoryModel>[],
//             CategoriesEmpty _ => const <CategoryModel>[],
//             _ => const <CategoryModel>[],
//           };
//
//           final summaries = _groupTransactionsByCategory(
//             transactions,
//             categories,
//           );
//
//           if (summaries.isEmpty) {
//             return Center(
//               child: Text(
//                 'Транзакций пока нет',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             );
//           }
//
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: summaries.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final item = summaries[index];
//
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.05),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.category?.name ?? item.categoryId,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Итого по категории',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '-${item.totalAmount.toStringAsFixed(2)} '
//                             '${item.currency}',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Последняя транзакция: '
//                             '${item.lastTransactionAt.toLocal()}',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.of(
//             context,
//           ).push(MaterialPageRoute(builder: (_) => const AddTransactionView()));
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
//
// /// Агрегированная информация по транзакциям в категории
// class _CategoryTransactionsSummary {
//   final CategoryModel? category;
//   final String categoryId;
//   final double totalAmount;
//   final DateTime lastTransactionAt;
//   final String currency;
//
//   _CategoryTransactionsSummary({
//     required this.category,
//     required this.categoryId,
//     required this.totalAmount,
//     required this.lastTransactionAt,
//     required this.currency,
//   });
// }
//
// /// Группировка транзакций по категориям и сортировка по дате последней транзакции
// List<_CategoryTransactionsSummary> _groupTransactionsByCategory(
//   List<TransactionModel> transactions,
//   List<CategoryModel> categories,
// ) {
//   if (transactions.isEmpty) return const [];
//
//   final categoryById = {for (final c in categories) c.categoryId: c};
//
//   final Map<String, List<TransactionModel>> grouped = {};
//
//   for (final t in transactions) {
//     grouped.putIfAbsent(t.categoryId, () => <TransactionModel>[]).add(t);
//   }
//
//   final summaries = grouped.entries.map((entry) {
//     final txs = List<TransactionModel>.from(entry.value);
//     txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//     final total = txs.fold<double>(0, (sum, t) => sum + t.amount);
//
//     final lastDate = txs.first.createdAt;
//     final currency = txs.first.currency;
//
//     return _CategoryTransactionsSummary(
//       category: categoryById[entry.key],
//       categoryId: entry.key,
//       totalAmount: total,
//       lastTransactionAt: lastDate,
//       currency: currency,
//     );
//   }).toList();
//
//   summaries.sort((a, b) => b.lastTransactionAt.compareTo(a.lastTransactionAt));
//
//   return summaries;
// }
//
// /// Экран добавления транзакции (примитивный white box)
// class AddTransactionView extends StatefulWidget {
//   const AddTransactionView({super.key});
//
//   @override
//   State<AddTransactionView> createState() => _AddTransactionViewState();
// }
//
// class _AddTransactionViewState extends State<AddTransactionView> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _currencyController = TextEditingController(text: 'USD');
//   final _noteController = TextEditingController();
//   final _categoryIdController = TextEditingController();
//
//   bool _isSubmitting = false;
//   TransactionType _selectedType = TransactionType.expense;
//   CategoryModel? _selectedCategory;
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     _currencyController.dispose();
//     _noteController.dispose();
//     _categoryIdController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     context.read<TransactionsCubit>().addTransaction(
//       categoryId: _selectedCategory?.categoryId ?? '',
//       currency: _currencyController.text,
//       note: _noteController.text,
//       rawAmount: _amountController.text,
//       type: _selectedType,
//     );
//   }
//
//   Future<void> _openCategoryPicker() async {
//     final categoriesCubit = context.read<CategoriesCubit>();
//     final currentState = categoriesCubit.state;
//
//     if (currentState is! CategoriesLoaded &&
//         currentState is! CategoryCreateSuccess &&
//         currentState is! CategoryCreating) {
//       await categoriesCubit.loadCategories();
//     }
//
//     final result = await showModalBottomSheet<CategoryModel>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return BlocProvider.value(
//           value: categoriesCubit,
//           child: const _CategoryPickerBottomSheet(),
//         );
//       },
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedCategory = result;
//         _categoryIdController.text = result.name;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<TransactionsCubit, TransactionsState>(
//       listener: (context, state) {
//         if (state is TransactionCreateSuccess) {
//           setState(() {
//             _isSubmitting = false;
//           });
//           Navigator.of(context).pop(state.createdTransaction);
//         } else if (state is TransactionCreateError) {
//           setState(() {
//             _isSubmitting = false;
//           });
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(state.message)));
//         } else if (state is TransactionCreating) {
//           setState(() {
//             _isSubmitting = true;
//           });
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Новая транзакция')),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _WhiteBox(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Основное',
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 12),
//                           DropdownButtonFormField<TransactionType>(
//                             value: _selectedType,
//                             items: const [
//                               DropdownMenuItem(
//                                 value: TransactionType.expense,
//                                 child: Text('Расход'),
//                               ),
//                               DropdownMenuItem(
//                                 value: TransactionType.income,
//                                 child: Text('Доход'),
//                               ),
//                             ],
//                             decoration: const InputDecoration(labelText: 'Тип'),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   _selectedType = value;
//                                 });
//                               }
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: _amountController,
//                             decoration: const InputDecoration(
//                               labelText: 'Сумма',
//                             ),
//                             keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Введите сумму';
//                               }
//                               final parsed = double.tryParse(
//                                 value.trim().replaceAll(',', '.'),
//                               );
//                               if (parsed == null || parsed <= 0) {
//                                 return 'Некорректная сумма';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: _currencyController,
//                             decoration: const InputDecoration(
//                               labelText: 'Валюта (например, USD)',
//                             ),
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Введите валюту';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: _categoryIdController,
//                             readOnly: true,
//                             decoration: const InputDecoration(
//                               labelText: 'Категория',
//                               hintText: 'Выберите категорию',
//                               suffixIcon: Icon(Icons.keyboard_arrow_up),
//                             ),
//                             onTap: _openCategoryPicker,
//                             validator: (_) {
//                               if (_selectedCategory == null) {
//                                 return 'Укажите категорию';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: _noteController,
//                             decoration: const InputDecoration(
//                               labelText: 'Заметка (необязательно)',
//                             ),
//                             maxLines: 2,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       height: 48,
//                       child: ElevatedButton(
//                         onPressed: _isSubmitting ? null : _submit,
//                         child: _isSubmitting
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : const Text('Добавить транзакцию'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _CategoryPickerBottomSheet extends StatelessWidget {
//   const _CategoryPickerBottomSheet();
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Выберите категорию',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: BlocBuilder<CategoriesCubit, CategoriesState>(
//                 builder: (context, state) {
//                   if (state is CategoriesLoading ||
//                       state is CategoriesInitial) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (state is CategoriesError) {
//                     return Center(
//                       child: Text(state.message, textAlign: TextAlign.center),
//                     );
//                   }
//
//                   final categories = switch (state) {
//                     CategoriesLoaded s => s.categories,
//                     CategoryCreateSuccess s => s.categories,
//                     CategoryCreating s => s.previousCategories,
//                     CategoryCreateError s =>
//                       s.previousCategories ?? const <CategoryModel>[],
//                     CategoriesEmpty _ => const <CategoryModel>[],
//                     _ => const <CategoryModel>[],
//                   };
//
//                   if (categories.isEmpty) {
//                     return const Center(child: Text('Категорий пока нет'));
//                   }
//
//                   return ListView.separated(
//                     itemCount: categories.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 8),
//                     itemBuilder: (context, index) {
//                       final category = categories[index];
//                       return InkWell(
//                         onTap: () => Navigator.of(context).pop(category),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withValues(alpha: 0.05),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       category.name,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleMedium
//                                           ?.copyWith(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       category.currency,
//                                       style: Theme.of(
//                                         context,
//                                       ).textTheme.bodySmall,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _WhiteBox extends StatelessWidget {
//   final Widget child;
//
//   const _WhiteBox({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: child,
//     );
//   }
// }
