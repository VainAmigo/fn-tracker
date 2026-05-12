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
  String get transfer => 'Перевод';

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
  String get createdAt => 'Создано';

  @override
  String get exportColumnType => 'Тип';

  @override
  String get amount => 'Сумма';

  @override
  String get exportColumnCurrency => 'Валюта';

  @override
  String get exportColumnCategory => 'Категория';

  @override
  String get exportColumnWallet => 'Кошелек';

  @override
  String get note => 'Заметка';

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

  @override
  String get spent => 'Потрачено';

  @override
  String get quickCategories => 'Быстрые категории';

  @override
  String get lastTransactions => 'Последние операции';

  @override
  String get viewAll => 'Смотреть все';

  @override
  String get settings => 'Настройки';

  @override
  String get homeWalletsSettingsSubtitle =>
      'Выберите кошельки, отображаемые на главном экране';

  @override
  String get showOnHome => 'Показывать на главной';

  @override
  String get home => 'Главная';

  @override
  String get finance => 'Финансы';

  @override
  String get analytics => 'Аналитика';

  @override
  String get chooseHowCategoriesAreDisplayed =>
      'Выберите, как отображаются категории на главном экране';

  @override
  String get recent => 'Недавние';

  @override
  String get pinned => 'Закреплённые';

  @override
  String get showCategoriesFromYourLastTransactions =>
      'Показывать категории из последних операций';

  @override
  String get showCategoriesFromYourQuickCategories =>
      'Показывать закреплённые категории для быстрого доступа';

  @override
  String get homeScreenWidgetSource => 'Источник виджета на главном экране';

  @override
  String get systemQuickCategories => 'Системные быстрые категории';

  @override
  String get userQuickCategories =>
      'Пользовательские категории из текущего быстрого режима';

  @override
  String get customCategories => 'Свои категории';

  @override
  String get chooseFixedCategories =>
      'Выберите фиксированный список категорий для главного экрана';

  @override
  String get available => 'Доступные';

  @override
  String get createCategoriesFirst => 'Создайте категории сначала';

  @override
  String get pinnedCategories => 'Закреплённые категории';

  @override
  String get selectCategoriesToShowInQuickAccess =>
      'Выберите категории для быстрого доступа на главном экране';

  @override
  String get save => 'Сохранить';

  @override
  String get widgetCategories => 'Виджет категории';

  @override
  String get selectCustomCategoriesForTheHomeScreenWidget =>
      'Выберите свои категории для виджета на главном экране';

  @override
  String get transactions => 'Транзакции';

  @override
  String get category => 'Категория';

  @override
  String get description => 'Описание';

  @override
  String get to => 'Куда';

  @override
  String get from => 'Откуда';

  @override
  String get date => 'Дата';

  @override
  String get manageYourAccountAndPreferences =>
      'Управляйте аккаунтом и настройками';

  @override
  String get appSettings => 'Настройки приложения';

  @override
  String get appTheme => 'Тема приложения';

  @override
  String get language => 'Язык';

  @override
  String get currencyAndFormats => 'Валюта и форматы';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get security => 'Безопасность';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirmation => 'Выйти из аккаунта?';

  @override
  String get cancel => 'Отмена';

  @override
  String get selectYourCurrencyAndNumberFormat =>
      'Выберите валюту и формат чисел';

  @override
  String get dynamicColorsOfTheDevice => 'Динамические цвета устройства';

  @override
  String get dynamicColorsOfTheDeviceDescription =>
      'На Android 12+ тема подстраивается под устройство. На других платформах или если цвета недоступны, используется палитра ниже.';

  @override
  String get system => 'Системная';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get themeMode => 'Режим темы';

  @override
  String get theme => 'Тема';

  @override
  String get addTransaction => 'Добавить операцию';

  @override
  String get amountCannotBeEmpty => 'Сумма не может быть пустой';

  @override
  String get amountMustBeGreaterThanZero => 'Сумма должна быть больше нуля';

  @override
  String get selectBothSourceAndDestinationAccounts =>
      'Выберите счёт списания и счёт зачисления';

  @override
  String get sourceAndDestinationMustBeDifferent =>
      'Счета списания и зачисления должны различаться';

  @override
  String get selectWalletOrGoal => 'Выберите кошелёк или цель';

  @override
  String get categoryCannotBeEmpty => 'Категория не может быть пустой';

  @override
  String get addNote => 'Добавить заметку';

  @override
  String get enterYourNote => 'Введите заметку';

  @override
  String get wallet => 'Кошелёк';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get goal => 'Цель';

  @override
  String get chooseCategory => 'Выберите категорию';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String get chooseDate => 'Выберите дату';

  @override
  String get chooseAccount => 'Выберите счёт';

  @override
  String get yourWallets => 'Ваши кошельки';

  @override
  String get yourGoals => 'Ваши цели';

  @override
  String get cannotSelectSameAccount => 'Нельзя выбрать один и тот же счёт';

  @override
  String get addWithVoice => 'Добавить голосом';

  @override
  String get addWithFile => 'Добавить из файла';

  @override
  String get addManually => 'Добавить вручную';

  @override
  String get voice => 'Голос';

  @override
  String get file => 'Файл';

  @override
  String get addTransactionWithAi => 'Добавить операцию с ИИ';

  @override
  String get enterTransactionsManuallyOrUseTemplates =>
      'Вводите операции вручную или используйте шаблоны';

  @override
  String get attachment => 'Вложение';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get removeFile => 'Удалить файл';

  @override
  String get textCanBeEdited => 'Текст можно изменить';

  @override
  String get cancelAndReturnToInput => 'Отменить и вернуться к вводу';

  @override
  String get saveAll => 'Сохранить всё';

  @override
  String get returnToInput => 'Вернуться к вводу';

  @override
  String get listening => 'Слушаю...';

  @override
  String get listen => 'Слушать';

  @override
  String get photo => 'Фото';

  @override
  String get pdf => 'PDF';

  @override
  String get processing => 'Обработка...';

  @override
  String get recognize => 'Распознать';

  @override
  String get upTo5Words => 'До 5 слов';

  @override
  String get yourFinancesAndSavings => 'Ваши финансы и сбережения';

  @override
  String get budget => 'Бюджет';

  @override
  String get accounts => 'Счета';

  @override
  String get categories => 'Категории';

  @override
  String get scheduledPayments => 'Запланированные платежи';

  @override
  String get editBudget => 'Изменить бюджет';

  @override
  String get createBudget => 'Создать бюджет';

  @override
  String get noBudgetFound => 'Бюджет не найден. Создайте его.';

  @override
  String get somethingWentWrong => 'Что-то пошло не так. Попробуйте позже.';

  @override
  String get retry => 'Повторить';

  @override
  String get budgetDetails => 'Детали бюджета';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteBudget => 'Удалить бюджет?';

  @override
  String get deleteBudgetConfirmation => 'Удалить этот бюджет?';

  @override
  String get noHistoryEntries => 'Нет записей истории';

  @override
  String get editHistoryEntry => 'Изменить запись';

  @override
  String get deleteHistoryEntry => 'Удалить запись истории?';

  @override
  String get budgetExceeded => 'Бюджет превышен';

  @override
  String get remaining => 'осталось';

  @override
  String get overspent => 'Перерасход';

  @override
  String get replaceAll => 'Заменить всё';

  @override
  String get fromDate => 'С даты';

  @override
  String get effectiveFrom => 'Действует с';

  @override
  String get info => 'Сведения';

  @override
  String get aboutBudget => 'О бюджете';

  @override
  String get budgetDescription =>
      'Бюджет — это месячный лимит расходов. Вы можете отслеживать траты относительно него и добавлять новые суммы при изменении бюджета.';

  @override
  String get addOptions => 'Варианты добавления';

  @override
  String get replaceAllDescription =>
      'Полностью заменяет историю бюджета новой суммой. Используйте, если хотите полностью сбросить бюджет.';

  @override
  String get fromDateDescription =>
      'Добавляет новую сумму бюджета, действующую с указанной даты. Предыдущие записи остаются в истории.';

  @override
  String get yearlyBudget => 'Годовой бюджет';

  @override
  String get monthlyBudget => 'Месячный бюджет';

  @override
  String get weeklyBudget => 'Недельный бюджет';

  @override
  String get budgetCategories => 'Категории бюджета';

  @override
  String get limitExceeded => 'Лимит превышен';

  @override
  String get wallets => 'Кошельки';

  @override
  String get createWallet => 'Создать кошелёк';

  @override
  String get newGoal => 'Новая цель';

  @override
  String get changePin => 'Сменить PIN';

  @override
  String get pinSuccessfullyChanged => 'PIN успешно изменён';

  @override
  String get setPin => 'Задать PIN';

  @override
  String get pinRequiredForHiddenCards => 'Для скрытых карт требуется PIN';

  @override
  String get hiddenCards => 'Скрытые карты';

  @override
  String get enterPinToView => 'Введите PIN для просмотра';

  @override
  String get open => 'Открыть';

  @override
  String get invalidPin => 'Неверный PIN';

  @override
  String get goalUpdatedSuccessfully => 'Цель успешно обновлена';

  @override
  String get goalCreatedSuccessfully => 'Цель успешно создана';

  @override
  String get updateGoal => 'Обновить цель';

  @override
  String get createGoal => 'Создать цель';

  @override
  String get goalName => 'Название цели';

  @override
  String get targetAmount => 'Целевая сумма';

  @override
  String get howMuchDoYouWantToSave => 'Сколько хотите накопить?';

  @override
  String get progress => 'Прогресс';

  @override
  String get enterValidTargetAmount => 'Введите корректную целевую сумму';

  @override
  String get nameIsRequired => 'Название обязательно';

  @override
  String get walletUpdatedSuccessfully => 'Кошелёк успешно обновлён';

  @override
  String get walletCreatedSuccessfully => 'Кошелёк успешно создан';

  @override
  String get updateWallet => 'Обновить кошелёк';

  @override
  String get walletName => 'Название кошелька';

  @override
  String get completed => 'Завершено';

  @override
  String get complete => 'Завершить';

  @override
  String get goalDetailsTitle => 'Детали цели';

  @override
  String get goalAmount => 'Сумма цели';

  @override
  String get completedAmount => 'Накоплено';

  @override
  String get completedAt => 'Завершено';

  @override
  String get history => 'История';

  @override
  String get deleteGoalTitle => 'Удалить цель?';

  @override
  String get deleteGoalMessage => 'Удалить эту цель?';

  @override
  String get edit => 'Изменить';

  @override
  String get hideAmount => 'Скрыть сумму';

  @override
  String get hideGoal => 'Скрыть цель';

  @override
  String get hideGoalSubtitle => 'Будет видна только в блоке «Скрытые карты»';

  @override
  String get deleteGoalMessageHint => 'Выберите способ удаления цели';

  @override
  String get deposit => 'Пополнение';

  @override
  String get noGoals => 'Пока нет целей';

  @override
  String get card => 'карта';

  @override
  String get cards => 'карты';

  @override
  String get inProgress => 'В процессе';

  @override
  String get totalProgress => 'Общий прогресс';

  @override
  String get goals => 'Цели';

  @override
  String get active => 'Активные';

  @override
  String get walletDetails => 'Детали кошелька';

  @override
  String get hideWallet => 'Скрыть кошелёк';

  @override
  String get hideWalletSubtitle => 'Будет виден только в блоке «Скрытые карты»';

  @override
  String get deleteWalletTitle => 'Удалить кошелёк?';

  @override
  String get deleteWalletMessage => 'Удалить этот кошелёк?';

  @override
  String get deleteWalletMessageHint => 'Выберите способ удаления кошелька';

  @override
  String get noWallets => 'Пока нет кошельков';

  @override
  String get createYourFirstWallet => 'Создайте первый кошелёк';

  @override
  String get newWallet => 'Новый кошелёк';

  @override
  String get categoryDetails => 'Детали категории';

  @override
  String get createCategory => 'Создать категорию';

  @override
  String get limit => 'Лимит';

  @override
  String get deleteCategoryTitle => 'Удалить категорию?';

  @override
  String get deleteCategoryMessage => 'Удалить эту категорию?';

  @override
  String get deleteCategoryMessageHint => 'Выберите способ удаления категории';

  @override
  String get scheduledPayment => 'Запланированный платёж';

  @override
  String get paymentName => 'название платежа';

  @override
  String get paymentAmountDescription => 'Какую сумму вы хотите платить?';

  @override
  String get frequency => 'Периодичность';

  @override
  String get paymentDate => 'Дата платежа';

  @override
  String get scheduledPaymentType => 'Тип запланированного платежа';

  @override
  String get nextPayment => 'Следующий платёж';

  @override
  String get walletOrGoal => 'Кошелёк или цель';

  @override
  String get selectWallet => 'Выберите кошелёк';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get enableAutoPayment => 'Включить автоплатёж';

  @override
  String get enterName => 'Введите название';

  @override
  String get enterAmount => 'Введите сумму';

  @override
  String get selectDateOrDays => 'Выберите дату или дни';

  @override
  String get paymentDateMustBeInTheFuture =>
      'Дата платежа должна быть в будущем';

  @override
  String get once => 'Один раз';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get endOfMonth => 'Конец месяца';

  @override
  String get subscriptions => 'Подписки';

  @override
  String get regularPayments => 'Регулярные платежи';

  @override
  String get regularIncomePayments => 'Регулярные поступления';

  @override
  String get repeat => 'Повтор';

  @override
  String get paymentsOn => 'Платежи';

  @override
  String get add => 'Добавить';

  @override
  String get paymentFrequency => 'Частота платежей';

  @override
  String get paused => 'На паузе';

  @override
  String get done => 'Готово';

  @override
  String get daysOfMonth => 'Дни месяца';

  @override
  String get dayOfMonth => 'День месяца';

  @override
  String get paymentDatesInYear => 'Даты платежей в году';

  @override
  String get dateMonthDay => 'Дата (месяц и день)';

  @override
  String get selectDateForOneTimePayment =>
      'Выберите дату для разового платежа';

  @override
  String get paymentWillBeMadeOnSelectedDaysOfMonthEveryMonth =>
      'Платёж будет выполняться в выбранные дни месяца каждый месяц';

  @override
  String get paymentWillBeMadeOnSelectedDayOfMonthEveryMonth =>
      'Платёж будет выполняться в выбранный день месяца каждый месяц';

  @override
  String get paymentWillBeMadeOnSelectedDatesEveryYear =>
      'Платёж будет выполняться в выбранные даты каждый год';

  @override
  String get paymentWillBeMadeOnSelectedDateMonthDayEveryYear =>
      'Платёж будет выполняться в выбранную дату (месяц и день) каждый год';

  @override
  String get first => 'Первый';

  @override
  String get second => 'Второй';

  @override
  String get third => 'Третий';

  @override
  String get th => 'е';

  @override
  String get selectedDays => 'Выбранные дни';

  @override
  String get pressToSelectDays => 'Нажмите, чтобы выбрать дни';

  @override
  String get chooseMonthAndDay => 'Выберите месяц и день';

  @override
  String get addDate => 'Добавить дату';

  @override
  String get editScheduledPayment => 'Изменить запланированный платёж';

  @override
  String get paid => 'Оплачено';

  @override
  String get autoCreateTransaction => 'Автоматически создавать операцию';

  @override
  String get pause => 'Пауза';

  @override
  String get pay => 'Оплатить';

  @override
  String get typeOfScheduledPayment => 'Тип запланированного платежа';

  @override
  String get createScheduledPayment => 'Создать запланированный платёж';

  @override
  String get categoryDeleted => 'Категория удалена';

  @override
  String get categoryUpdatedSuccessfully => 'Категория успешно обновлена';

  @override
  String get categoryCreatedSuccessfully => 'Категория успешно создана';

  @override
  String get updateCategory => 'Обновить категорию';

  @override
  String get categoryName => 'Название категории';

  @override
  String get noLimit => 'Без лимита';

  @override
  String get monthlyLimit => 'Месячный лимит';

  @override
  String get update => 'Обновить';

  @override
  String get create => 'Создать';

  @override
  String get noCategories => 'Нет категорий';

  @override
  String get createYourFirstCategory => 'Создайте первую категорию';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get icon => 'Иконка';

  @override
  String get exportSettings => 'Настройки экспорта';

  @override
  String get period => 'Период';

  @override
  String get month => 'Месяц';

  @override
  String get custom => 'Пользовательский';

  @override
  String get selectedColumns => 'Выбранные столбцы';

  @override
  String get settingsSaved => 'Настройки сохранены';

  @override
  String get export => 'Экспорт';

  @override
  String get exportFileIsReady => 'Файл экспорта готов';

  @override
  String get fileCreatedButShareDialogIsUnavailableOnThisDevice =>
      'Файл создан, но окно «Поделиться» на этом устройстве недоступно';

  @override
  String get noDataForSelectedPeriod => 'Нет данных за выбранный период';

  @override
  String get choosePeriodInExportSettings =>
      'Выберите период в настройках экспорта';

  @override
  String get failedToExportData => 'Не удалось экспортировать данные';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get customPeriod => 'Произвольный период';

  @override
  String get deepAnalytics => 'Углублённая аналитика';

  @override
  String get askAboutYourAnalyticsForThisPeriod =>
      'Спросите об аналитике за этот период';

  @override
  String get clearChat => 'Очистить чат';

  @override
  String get askAboutYourAnalyticsForThisPeriodHint => 'Спросите об аналитике…';

  @override
  String get aiAssistant => 'ИИ-ассистент';

  @override
  String get spendingChart => 'Диаграмма расходов';

  @override
  String get balance => 'Баланс';

  @override
  String get enterCurrentPin => 'Введите текущий PIN';

  @override
  String get enterNewPin => 'Введите новый PIN';

  @override
  String get newPinDoesNotMatch => 'Новый PIN не совпадает';

  @override
  String get newPinMustBeDifferent => 'Новый PIN должен отличаться';

  @override
  String get invalidCurrentPin => 'Неверный текущий PIN';

  @override
  String get currentPin => 'Текущий PIN';

  @override
  String get newPin => 'Новый PIN';

  @override
  String get confirmNewPin => 'Подтвердите новый PIN';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get pinDoesNotMatch => 'PIN не совпадает';

  @override
  String get enterPin => 'Введите PIN';

  @override
  String get confirmPin => 'Подтвердите PIN';

  @override
  String get aiGoalAdviceTitle => 'ИИ-советы по накоплению';

  @override
  String get aiGoalAdviceSingleGoalHint =>
      'Спросите, как быстрее накопить именно на эту цель на основе ваших данных.';

  @override
  String get aiGoalAdviceAllGoalsHint =>
      'Спросите, как лучше распределить накопления между всеми целями.';

  @override
  String get aiGoalAdviceQuestionHint =>
      'Например: что сократить в первую очередь, чтобы быстрее закрыть цель?';

  @override
  String get aiGoalAdviceAsk => 'Получить совет';

  @override
  String get aiGoalAdviceTotalAsk => 'ИИ-советы по всем целям';

  @override
  String get aiGoalAdviceTotalTitle => 'ИИ-советы по всем целям';

  @override
  String get aiGoalAdviceDefaultQuestionAll =>
      'Проанализируй все мои цели, кошельки, категории и транзакции. Дай короткий план: какие цели приоритизировать, какие траты сократить в первую очередь и как ускорить накопления в целом.';

  @override
  String aiGoalAdviceDefaultQuestionSingle(Object goalName) {
    return 'Проанализируй все мои данные и дай практичные советы, как быстрее закрыть цель \"$goalName\": какие траты сокращать в первую очередь и сколько регулярно откладывать.';
  }

  @override
  String get pin => 'PIN';

  @override
  String get authErrorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get authErrorAccountExistsWithDifferentCredential =>
      'Аккаунт с этой почтой уже есть, но с другим способом входа.';

  @override
  String get authErrorCredentialAlreadyInUse =>
      'Этот аккаунт Google уже привязан к другому пользователю.';

  @override
  String get authErrorProviderAlreadyLinked =>
      'Google уже привязан к этому аккаунту.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Из соображений безопасности выйдите и войдите снова, затем привяжите Google.';

  @override
  String get authErrorInvalidCredential =>
      'Неверные данные. Проверьте аккаунт Google или попробуйте снова.';

  @override
  String get authErrorUserDisabled => 'Этот аккаунт отключён.';

  @override
  String get authErrorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get authErrorNotSignedIn => 'Вы не вошли в аккаунт.';

  @override
  String get authErrorGoogleSignIn =>
      'Не удалось войти через Google. Проверьте настройки в Firebase Console.';

  @override
  String get linkGoogleTitle => 'Привязать Google';

  @override
  String get linkGoogleSubtitle =>
      'Вход через Google на этом устройстве с тем же профилем';

  @override
  String get googleAlreadyLinkedTitle => 'Google привязан';

  @override
  String get googleAlreadyLinkedSubtitle =>
      'Вы можете входить через Google на этом устройстве';

  @override
  String get googleLinkedSuccessfully => 'Аккаунт Google привязан';

  @override
  String get displayNameLabel => 'Отображаемое имя';

  @override
  String get displayNameNotSet => 'Не установлено';

  @override
  String get displayNameTapToSet => 'Нажмите, чтобы изменить имя';

  @override
  String get displayNameWhenSet => 'Имя в приложении';

  @override
  String get editDisplayNameTitle => 'Изменить имя';

  @override
  String get displayNameUpdated => 'Имя обновлено';

  @override
  String get displayNameTooLong =>
      'Слишком длинное имя (не более 120 символов)';

  @override
  String get deleteUserDataSectionTitle => 'Данные и аккаунт';

  @override
  String get deleteUserDataButton => 'Удалить все данные';

  @override
  String get deleteUserDataTitle => 'Удалить все данные?';

  @override
  String get deleteUserDataMessage =>
      'Будут безвозвратно удалены все транзакции, кошельки, цели, категории, бюджеты и настройки в приложении. Вход и профиль (почта, имя) сохранятся.';

  @override
  String get deleteUserDataConfirm => 'Удалить данные';

  @override
  String get deleteAccountButton => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountMessage =>
      'Аккаунт и все данные будут безвозвратно удалены. Это действие нельзя отменить.';

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт';

  @override
  String get enterPasswordToConfirmDelete => 'Введите пароль для подтверждения';

  @override
  String get continueWithGoogleToConfirmDelete =>
      'Войдите через Google для подтверждения';

  @override
  String get userDataDeleted => 'Все данные удалены';

  @override
  String get accountDeleted => 'Аккаунт удалён';

  @override
  String get changePassword => 'Смена пароля';

  @override
  String get changePasswordCardSubtitle => 'Нажмите, чтобы сменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get enterYourCurrentPassword => 'Введите текущий пароль';

  @override
  String get passwordChangedSuccessfully => 'Пароль успешно изменён';

  @override
  String get passwordChangeEmailOnly =>
      'Смена пароля доступна только при входе по почте';

  @override
  String get account => 'Аккаунт';

  @override
  String get accountTitle => 'Ваш аккаунт';

  @override
  String get accountSubtitle => 'Настройте ваш аккаунт';

  @override
  String get accountSettings => 'Настройки аккаунта';

  @override
  String get securityIntro =>
      'Один PIN защищает скрытые кошельки и цели и может блокировать вход в приложение. Биометрия использует ту же проверку.';

  @override
  String get pinSectionTitle => 'PIN-код';

  @override
  String get pinSetSubtitle =>
      'Сменить PIN для блокировки приложения и скрытых карт.';

  @override
  String get pinNotSetSubtitle =>
      'Задайте PIN при скрытии кошелька или нажмите здесь.';

  @override
  String get appLockTitle => 'Блокировать приложение при запуске';

  @override
  String get appLockSubtitle =>
      'Запрашивать PIN или биометрию после открытия приложения';

  @override
  String get biometricUnlockTitle => 'Вход по биометрии';

  @override
  String get biometricUnlockSubtitle =>
      'Сначала отпечаток или Face ID, при необходимости — PIN';

  @override
  String get unlockAppTitle => 'Приложение заблокировано';

  @override
  String get unlockAppSubtitle => 'Разблокируйте, чтобы продолжить';

  @override
  String get biometricPromptUnlock => 'Подтвердите, что это вы';

  @override
  String get useBiometricButton => 'Биометрия';

  @override
  String get biometricsHintNoneEnrolled =>
      'На устройстве не добавлен отпечаток или Face ID. Добавьте в настройках системы (Безопасность / Блокировка экрана), затем снова откройте этот экран.';

  @override
  String get biometricsHintUnsupported =>
      'Устройство не сообщает о поддержке биометрии (часто так на эмуляторах).';

  @override
  String get biometricsHintProbeFailed =>
      'Не удалось определить статус биометрии. Полностью перезапустите приложение или выполните чистую пересборку после подключения local_auth.';
}
