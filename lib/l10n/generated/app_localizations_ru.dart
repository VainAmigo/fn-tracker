// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String get januaryShort => 'Янв';

  @override
  String get februaryShort => 'Фев';

  @override
  String get marchShort => 'Мар';

  @override
  String get aprilShort => 'Апр';

  @override
  String get mayShort => 'Май';

  @override
  String get juneShort => 'Июн';

  @override
  String get julyShort => 'Июл';

  @override
  String get augustShort => 'Авг';

  @override
  String get septemberShort => 'Сен';

  @override
  String get octoberShort => 'Окт';

  @override
  String get novemberShort => 'Ноя';

  @override
  String get decemberShort => 'Дек';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get mondayShort => 'Пн';

  @override
  String get tuesdayShort => 'Вт';

  @override
  String get wednesdayShort => 'Ср';

  @override
  String get thursdayShort => 'Чт';

  @override
  String get fridayShort => 'Пт';

  @override
  String get saturdayShort => 'Сб';

  @override
  String get sundayShort => 'Вс';

  @override
  String get week => 'Неделя';

  @override
  String get threeMonths => '3 месяца';

  @override
  String get sixMonths => '6 месяцев';

  @override
  String get expense => 'Расход';

  @override
  String get income => 'Доход';

  @override
  String get deleteEntityCancel => 'Отмена';

  @override
  String get deleteEntityPartial => 'Удалить частично';

  @override
  String get deleteEntityFull => 'Удалить полностью';

  @override
  String get deleteEntityPartialHint =>
      'Удалить частично — удалить цель/кошелёк, транзакции сохранятся.';

  @override
  String get deleteEntityFullHint =>
      'Удалить полностью — удалить вместе со всеми связанными транзакциями.';

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get noTransactionsSubtitle => 'У вас пока нет транзакций';

  @override
  String get exportColumnDate => 'Дата';

  @override
  String get exportColumnCreatedAt => 'Создано';

  @override
  String get exportColumnType => 'Тип';

  @override
  String get exportColumnAmount => 'Сумма';

  @override
  String get exportColumnCurrency => 'Валюта';

  @override
  String get exportColumnCategory => 'Категория';

  @override
  String get exportColumnWallet => 'Кошелек';

  @override
  String get exportColumnNote => 'Заметка';

  @override
  String get exportColumnTransactionId => 'ID транзакции';

  @override
  String get exportColumnDateDescription =>
      'Дата операции, выбранная пользователем.';

  @override
  String get exportColumnCreatedAtDescription =>
      'Дата создания записи в базе данных.';

  @override
  String get exportColumnTypeDescription =>
      'Тип операции: расход, доход или перевод.';

  @override
  String get exportColumnAmountDescription =>
      'Сумма операции с двумя знаками после запятой.';

  @override
  String get exportColumnCurrencyDescription =>
      'Код валюты, используемый в операции.';

  @override
  String get exportColumnCategoryDescription =>
      'Название категории, связанной с операцией.';

  @override
  String get exportColumnWalletDescription =>
      'Название кошелька, связанного с операцией.';

  @override
  String get exportColumnNoteDescription =>
      'Пользовательская заметка к операции.';

  @override
  String get exportColumnTransactionIdDescription =>
      'Уникальный идентификатор операции.';

  @override
  String get startTakingControlOfYourFinances =>
      'Начните управлять своими финансами';

  @override
  String get continueWithEmail => 'Продолжить с электронной почтой';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get login => 'Войти';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердить пароль';

  @override
  String get enterYourEmail => 'Введите вашу электронную почту';

  @override
  String get enterYourPassword => 'Введите ваш пароль';

  @override
  String get confirmYourPassword => 'Подтвердите ваш пароль';

  @override
  String get invalidEmail => 'Некорректный email';

  @override
  String passwordMustBeAtLeast(int minLength) {
    return 'Пароль должен содержать не менее $minLength символов';
  }

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';
}
