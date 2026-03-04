import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

class CategoryCreateView extends StatefulWidget {
  const CategoryCreateView({super.key});

  @override
  State<CategoryCreateView> createState() => _CategoryCreateViewState();
}

class _CategoryCreateViewState extends State<CategoryCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _colorIdController = TextEditingController(text: 'default_color');
  final _iconIdController = TextEditingController(text: 'default_icon');

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    _colorIdController.dispose();
    _iconIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawLimit = _limitController.text.trim();

    double? limitValue;
    if (rawLimit.isNotEmpty) {
      limitValue = double.tryParse(rawLimit);
      if (limitValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Некорректное значение лимита'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });
    //
    // context.read<CategoriesCubit>().createCategory(
    //       name: name,
    //       colorId: colorId,
    //       iconId: iconId,
    //       limitValue: limitValue,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CategoryCreateSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop(state.createdCategory);
        } else if (state is CategoryCreateError) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is CategoryCreating) {
          setState(() {
            _isSubmitting = true;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Новая категория'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WhiteBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Основное',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Название категории',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите название';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Валюта (например, USD)',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите валюту';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _limitController,
                            decoration: const InputDecoration(
                              labelText: 'Месячный лимит (необязательно)',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _WhiteBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Визуал',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _colorIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID цвета (строка)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _iconIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID иконки (строка)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Создать категорию'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WhiteBox extends StatelessWidget {
  final Widget child;

  const _WhiteBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

