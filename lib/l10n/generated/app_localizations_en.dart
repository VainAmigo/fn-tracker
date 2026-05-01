// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get januaryShort => 'Jan';

  @override
  String get februaryShort => 'Feb';

  @override
  String get marchShort => 'Mar';

  @override
  String get aprilShort => 'Apr';

  @override
  String get mayShort => 'May';

  @override
  String get juneShort => 'Jun';

  @override
  String get julyShort => 'Jul';

  @override
  String get augustShort => 'Aug';

  @override
  String get septemberShort => 'Sep';

  @override
  String get octoberShort => 'Oct';

  @override
  String get novemberShort => 'Nov';

  @override
  String get decemberShort => 'Dec';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get week => 'Week';

  @override
  String get threeMonths => '3 months';

  @override
  String get sixMonths => '6 months';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get deleteEntityCancel => 'Cancel';

  @override
  String get deleteEntityPartial => 'Delete partially';

  @override
  String get deleteEntityFull => 'Delete fully';

  @override
  String get deleteEntityPartialHint =>
      'Delete partially — remove the goal/wallet, transactions will be preserved.';

  @override
  String get deleteEntityFullHint =>
      'Delete fully — remove together with all related transactions.';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get noTransactionsSubtitle => 'You have no transactions yet';

  @override
  String get exportColumnDate => 'Date';

  @override
  String get createdAt => 'Created at';

  @override
  String get exportColumnType => 'Type';

  @override
  String get amount => 'Amount';

  @override
  String get exportColumnCurrency => 'Currency';

  @override
  String get exportColumnCategory => 'Category';

  @override
  String get exportColumnWallet => 'Wallet';

  @override
  String get note => 'Note';

  @override
  String get exportColumnTransactionId => 'Transaction ID';

  @override
  String get exportColumnDateDescription =>
      'Transaction date selected by user.';

  @override
  String get exportColumnCreatedAtDescription =>
      'Record creation date in database.';

  @override
  String get exportColumnTypeDescription =>
      'Transaction type: expense, income, or transfer.';

  @override
  String get exportColumnAmountDescription =>
      'Transaction amount with 2 decimal places.';

  @override
  String get exportColumnCurrencyDescription =>
      'Currency code used in transaction.';

  @override
  String get exportColumnCategoryDescription =>
      'Category name linked to transaction.';

  @override
  String get exportColumnWalletDescription =>
      'Wallet name linked to transaction.';

  @override
  String get exportColumnNoteDescription => 'User note from transaction.';

  @override
  String get exportColumnTransactionIdDescription =>
      'Unique transaction identifier.';

  @override
  String get startTakingControlOfYourFinances =>
      'Start taking control of your finances';

  @override
  String get continueWithEmail => 'Continue with Email';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String passwordMustBeAtLeast(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get spent => 'Spent';

  @override
  String get quickCategories => 'Quick Categories';

  @override
  String get lastTransactions => 'Last Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get finance => 'Finance';

  @override
  String get analytics => 'Analytics';

  @override
  String get chooseHowCategoriesAreDisplayed =>
      'Choose how categories are displayed on the home screen';

  @override
  String get recent => 'Recent';

  @override
  String get pinned => 'Pinned';

  @override
  String get showCategoriesFromYourLastTransactions =>
      'Show categories from your last transactions';

  @override
  String get showCategoriesFromYourQuickCategories =>
      'Show categories you\'ve pinned for quick access';

  @override
  String get homeScreenWidgetSource => 'Home screen widget source';

  @override
  String get systemQuickCategories => 'System quick categories';

  @override
  String get userQuickCategories => 'User categories from current quick mode';

  @override
  String get customCategories => 'Custom categories';

  @override
  String get chooseFixedCategories =>
      'Choose a fixed list of categories for the home screen';

  @override
  String get available => 'Available';

  @override
  String get createCategoriesFirst => 'Create categories first';

  @override
  String get pinnedCategories => 'Pinned Categories';

  @override
  String get selectCategoriesToShowInQuickAccess =>
      'Select categories to show in quick access on home';

  @override
  String get save => 'Save';

  @override
  String get widgetCategories => 'Widget Categories';

  @override
  String get selectCustomCategoriesForTheHomeScreenWidget =>
      'Select custom categories for the home screen widget';

  @override
  String get transactions => 'Transactions';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get to => 'To';

  @override
  String get from => 'From';

  @override
  String get date => 'Date';

  @override
  String get manageYourAccountAndPreferences =>
      'Manage your account and preferences';

  @override
  String get appSettings => 'App settings';

  @override
  String get appTheme => 'App theme';

  @override
  String get language => 'Language';

  @override
  String get currencyAndFormats => 'Currency and formats';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get security => 'Security';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectYourCurrencyAndNumberFormat =>
      'Select your currency and number format';

  @override
  String get dynamicColorsOfTheDevice => 'Dynamic colors of the device';

  @override
  String get dynamicColorsOfTheDeviceDescription =>
      'On Android 12+ the theme is adapted to the device. On other platforms or if colors are not available, the palette below is used.';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get theme => 'Theme';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get amountCannotBeEmpty => 'Amount cannot be empty';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than zero';

  @override
  String get selectBothSourceAndDestinationAccounts =>
      'Select both source and destination accounts';

  @override
  String get sourceAndDestinationMustBeDifferent =>
      'Source and destination must be different';

  @override
  String get selectWalletOrGoal => 'Select a wallet or goal';

  @override
  String get categoryCannotBeEmpty => 'Category cannot be empty';

  @override
  String get addNote => 'Add note';

  @override
  String get enterYourNote => 'Enter your note';

  @override
  String get wallet => 'Wallet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get goal => 'Goal';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get selectDate => 'Select date';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get chooseAccount => 'Choose account';

  @override
  String get yourWallets => 'Your wallets';

  @override
  String get yourGoals => 'Your goals';

  @override
  String get cannotSelectSameAccount => 'Cannot select the same account';

  @override
  String get addWithVoice => 'Add with voice';

  @override
  String get addWithFile => 'Add with file';

  @override
  String get addManually => 'Add manually';

  @override
  String get voice => 'Voice';

  @override
  String get file => 'File';

  @override
  String get addTransactionWithAi => 'Add transaction with AI';

  @override
  String get enterTransactionsManuallyOrUseTemplates =>
      'Enter transactions manually or use templates';

  @override
  String get attachment => 'Attachment';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removeFile => 'Remove file';

  @override
  String get textCanBeEdited => 'Text can be edited';

  @override
  String get cancelAndReturnToInput => 'Cancel and return to input';

  @override
  String get saveAll => 'Save all';

  @override
  String get returnToInput => 'Return to input';

  @override
  String get listening => 'Listening...';

  @override
  String get listen => 'Listen';

  @override
  String get photo => 'Photo';

  @override
  String get pdf => 'PDF';

  @override
  String get processing => 'Processing...';

  @override
  String get recognize => 'Recognize';

  @override
  String get upTo5Words => 'Up to 5 words';

  @override
  String get yourFinancesAndSavings => 'Your finances and savings';

  @override
  String get budget => 'Budget';

  @override
  String get accounts => 'Accounts';

  @override
  String get categories => 'Categories';

  @override
  String get scheduledPayments => 'Scheduled payments';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get createBudget => 'Create budget';

  @override
  String get noBudgetFound => 'No budget found. Please create one.';

  @override
  String get somethingWentWrong =>
      'Something went wrong. Please try again later.';

  @override
  String get retry => 'Retry';

  @override
  String get budgetDetails => 'Budget details';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBudget => 'Delete budget?';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget?';

  @override
  String get noHistoryEntries => 'No history entries';

  @override
  String get editHistoryEntry => 'Edit history entry';

  @override
  String get deleteHistoryEntry => 'Delete history entry?';

  @override
  String get budgetExceeded => 'Budget exceeded';

  @override
  String get remaining => 'remaining';

  @override
  String get overspent => 'Overspent';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get fromDate => 'From date';

  @override
  String get effectiveFrom => 'Effective from';

  @override
  String get info => 'Info';

  @override
  String get aboutBudget => 'About budget';

  @override
  String get budgetDescription =>
      'Budget is a monthly spending limit. You can track how much you spend against it and add new amounts when your budget changes.';

  @override
  String get addOptions => 'Add options';

  @override
  String get replaceAllDescription =>
      'Replaces all budget history with the new amount. Use when you want to reset your budget completely.';

  @override
  String get fromDateDescription =>
      'Adds a new budget amount effective from a specific date. Previous entries remain in history.';

  @override
  String get yearlyBudget => 'Yearly budget';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get weeklyBudget => 'Weekly budget';

  @override
  String get budgetCategories => 'Budget categories';

  @override
  String get limitExceeded => 'Limit exceeded';

  @override
  String get wallets => 'Wallets';

  @override
  String get createWallet => 'Create wallet';

  @override
  String get newGoal => 'New goal';

  @override
  String get changePin => 'Change PIN';

  @override
  String get pinSuccessfullyChanged => 'PIN successfully changed';

  @override
  String get setPin => 'Set PIN';

  @override
  String get pinRequiredForHiddenCards => 'PIN is required for hidden cards';

  @override
  String get hiddenCards => 'Hidden cards';

  @override
  String get enterPinToView => 'Enter PIN to view';

  @override
  String get open => 'Open';

  @override
  String get invalidPin => 'Invalid PIN';

  @override
  String get goalUpdatedSuccessfully => 'Goal updated successfully';

  @override
  String get goalCreatedSuccessfully => 'Goal created successfully';

  @override
  String get updateGoal => 'Update goal';

  @override
  String get createGoal => 'Create goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get howMuchDoYouWantToSave => 'How much do you want to save?';

  @override
  String get progress => 'Progress';

  @override
  String get enterValidTargetAmount => 'Enter a valid target amount';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get walletUpdatedSuccessfully => 'Wallet updated successfully';

  @override
  String get walletCreatedSuccessfully => 'Wallet created successfully';

  @override
  String get updateWallet => 'Update wallet';

  @override
  String get walletName => 'Wallet name';

  @override
  String get completed => 'Completed';

  @override
  String get complete => 'Complete';

  @override
  String get goalDetailsTitle => 'Goal details';

  @override
  String get goalAmount => 'Goal amount';

  @override
  String get completedAmount => 'Completed amount';

  @override
  String get completedAt => 'Completed at';

  @override
  String get history => 'History';

  @override
  String get deleteGoalTitle => 'Delete goal?';

  @override
  String get deleteGoalMessage => 'Are you sure you want to delete this goal?';

  @override
  String get edit => 'Edit';

  @override
  String get hideAmount => 'Hide amount';

  @override
  String get hideGoal => 'Hide goal';

  @override
  String get hideGoalSubtitle =>
      'Will be visible only in the \"Hidden cards\" block';

  @override
  String get deleteGoalMessageHint => 'Choose the way to delete the goal';

  @override
  String get deposit => 'Deposit';

  @override
  String get noGoals => 'No goals yet';

  @override
  String get card => 'card';

  @override
  String get cards => 'cards';

  @override
  String get inProgress => 'In progress';

  @override
  String get totalProgress => 'Total progress';

  @override
  String get goals => 'Goals';

  @override
  String get active => 'Active';

  @override
  String get walletDetails => 'Wallet details';

  @override
  String get hideWallet => 'Hide wallet';

  @override
  String get hideWalletSubtitle =>
      'Will be visible only in the \"Hidden cards\" block';

  @override
  String get deleteWalletTitle => 'Delete wallet?';

  @override
  String get deleteWalletMessage =>
      'Are you sure you want to delete this wallet?';

  @override
  String get deleteWalletMessageHint => 'Choose the way to delete the wallet';

  @override
  String get noWallets => 'No wallets yet';

  @override
  String get createYourFirstWallet => 'Create your first wallet';

  @override
  String get newWallet => 'New wallet';

  @override
  String get categoryDetails => 'Category details';

  @override
  String get createCategory => 'Create category';

  @override
  String get limit => 'Limit';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCategoryMessage =>
      'Are you sure you want to delete this category?';

  @override
  String get deleteCategoryMessageHint =>
      'Choose the way to delete the category';

  @override
  String get scheduledPayment => 'Scheduled payment';

  @override
  String get paymentName => 'payment name';

  @override
  String get paymentAmountDescription => 'How much do you want to pay?';

  @override
  String get frequency => 'Frequency';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get scheduledPaymentType => 'Scheduled payment type';

  @override
  String get nextPayment => 'Next payment';

  @override
  String get walletOrGoal => 'Wallet or goal';

  @override
  String get selectWallet => 'Select wallet';

  @override
  String get selectCategory => 'Select category';

  @override
  String get enableAutoPayment => 'Enable auto-payment';

  @override
  String get enterName => 'Enter name';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get selectDateOrDays => 'Select date or days';

  @override
  String get paymentDateMustBeInTheFuture =>
      'Payment date must be in the future';

  @override
  String get once => 'Once';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get weekly => 'Weekly';

  @override
  String get endOfMonth => 'End of month';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get regularPayments => 'Regular payments';

  @override
  String get regularIncomePayments => 'Regular income payments';

  @override
  String get repeat => 'Repeat';

  @override
  String get paymentsOn => 'Payments on';

  @override
  String get add => 'Add';

  @override
  String get paymentFrequency => 'Payment frequency';

  @override
  String get paused => 'Paused';

  @override
  String get done => 'Done';

  @override
  String get daysOfMonth => 'Days of month';

  @override
  String get dayOfMonth => 'Day of month';

  @override
  String get paymentDatesInYear => 'Payment dates in year';

  @override
  String get dateMonthDay => 'Date (month & day)';

  @override
  String get selectDateForOneTimePayment => 'Select date for one-time payment';

  @override
  String get paymentWillBeMadeOnSelectedDaysOfMonthEveryMonth =>
      'Payment will be made on selected days of month every month';

  @override
  String get paymentWillBeMadeOnSelectedDayOfMonthEveryMonth =>
      'Payment will be made on selected day of month every month';

  @override
  String get paymentWillBeMadeOnSelectedDatesEveryYear =>
      'Payment will be made on selected dates every year';

  @override
  String get paymentWillBeMadeOnSelectedDateMonthDayEveryYear =>
      'Payment will be made on selected date (month & day) every year';

  @override
  String get first => 'First';

  @override
  String get second => 'Second';

  @override
  String get third => 'Third';

  @override
  String get th => 'th';

  @override
  String get selectedDays => 'Selected days';

  @override
  String get pressToSelectDays => 'Press to select days';

  @override
  String get chooseMonthAndDay => 'Choose month and day';

  @override
  String get addDate => 'Add date';

  @override
  String get editScheduledPayment => 'Edit scheduled payment';

  @override
  String get paid => 'Paid';

  @override
  String get autoCreateTransaction => 'Auto-create transaction';

  @override
  String get pause => 'Pause';

  @override
  String get pay => 'Pay';

  @override
  String get typeOfScheduledPayment => 'Type of scheduled payment';

  @override
  String get createScheduledPayment => 'Create scheduled payment';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryUpdatedSuccessfully => 'Category updated successfully';

  @override
  String get categoryCreatedSuccessfully => 'Category created successfully';

  @override
  String get updateCategory => 'Update category';

  @override
  String get categoryName => 'Category name';

  @override
  String get noLimit => 'No limit';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get noCategories => 'No categories';

  @override
  String get createYourFirstCategory => 'Create your first category';

  @override
  String get newCategory => 'New category';

  @override
  String get icon => 'Icon';

  @override
  String get exportSettings => 'Export settings';

  @override
  String get period => 'Period';

  @override
  String get month => 'Month';

  @override
  String get custom => 'Custom';

  @override
  String get selectedColumns => 'Selected columns';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get export => 'Export';

  @override
  String get exportFileIsReady => 'Export file is ready';

  @override
  String get fileCreatedButShareDialogIsUnavailableOnThisDevice =>
      'File created, but share dialog is unavailable on this device';

  @override
  String get noDataForSelectedPeriod => 'No data for selected period';

  @override
  String get choosePeriodInExportSettings => 'Choose period in export settings';

  @override
  String get failedToExportData => 'Failed to export data';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get customPeriod => 'Custom period';

  @override
  String get deepAnalytics => 'Deep analytics';

  @override
  String get askAboutYourAnalyticsForThisPeriod =>
      'Ask about your analytics for this period';

  @override
  String get clearChat => 'Clear chat';

  @override
  String get askAboutYourAnalyticsForThisPeriodHint =>
      'Ask about your analytics…';

  @override
  String get aiAssistant => 'AI assistant';

  @override
  String get spendingChart => 'Spending chart';

  @override
  String get balance => 'Balance';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPin => 'Enter new PIN';

  @override
  String get newPinDoesNotMatch => 'New PIN does not match';

  @override
  String get newPinMustBeDifferent => 'New PIN must be different';

  @override
  String get invalidCurrentPin => 'Invalid current PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get confirm => 'Confirm';

  @override
  String get pinDoesNotMatch => 'PIN does not match';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get aiGoalAdviceTitle => 'AI savings advice';

  @override
  String get aiGoalAdviceSingleGoalHint =>
      'Ask how to save faster for this goal based on your real data.';

  @override
  String get aiGoalAdviceAllGoalsHint =>
      'Ask for advice on how to optimize savings across all your goals.';

  @override
  String get aiGoalAdviceQuestionHint =>
      'For example: what should I cut first to reach the goal faster?';

  @override
  String get aiGoalAdviceAsk => 'Get advice';

  @override
  String get aiGoalAdviceTotalAsk => 'AI tips for all goals';

  @override
  String get aiGoalAdviceTotalTitle => 'AI tips for all goals';

  @override
  String get aiGoalAdviceDefaultQuestionAll =>
      'Analyze all my goals, wallets, categories, and transactions. Give a short plan: which goals to prioritize, what spending to reduce first, and how to speed up my savings overall.';

  @override
  String aiGoalAdviceDefaultQuestionSingle(Object goalName) {
    return 'Analyze all my data and give practical advice on how to reach the goal \"$goalName\" faster: where to cut spending first and how much I should top up regularly.';
  }

  @override
  String get pin => 'PIN';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authErrorAccountExistsWithDifferentCredential =>
      'An account already exists with this email but a different sign-in method.';

  @override
  String get authErrorCredentialAlreadyInUse =>
      'This Google account is already linked to another user.';

  @override
  String get authErrorProviderAlreadyLinked =>
      'Google is already linked to this account.';

  @override
  String get authErrorRequiresRecentLogin =>
      'For security, sign out and sign in again, then try linking Google.';

  @override
  String get authErrorInvalidCredential =>
      'Invalid credentials. Check your Google account or try again.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorNetwork => 'Network error. Check your connection.';

  @override
  String get authErrorNotSignedIn => 'You are not signed in.';

  @override
  String get authErrorGoogleSignIn =>
      'Google Sign-In failed. Check app configuration in Firebase Console.';

  @override
  String get linkGoogleTitle => 'Link Google account';

  @override
  String get linkGoogleSubtitle =>
      'Sign in with Google on this device using the same profile';

  @override
  String get googleAlreadyLinkedTitle => 'Google linked';

  @override
  String get googleAlreadyLinkedSubtitle =>
      'You can sign in with Google on this device';

  @override
  String get googleLinkedSuccessfully => 'Google account linked';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameNotSet => 'Not set';

  @override
  String get displayNameTapToSet => 'Tap to change your display name';

  @override
  String get displayNameWhenSet => 'Display name';

  @override
  String get editDisplayNameTitle => 'Edit display name';

  @override
  String get displayNameUpdated => 'Display name updated';

  @override
  String get displayNameTooLong => 'Name is too long (max 120 characters)';

  @override
  String get deleteUserDataSectionTitle => 'Data & account';

  @override
  String get deleteUserDataButton => 'Delete all data';

  @override
  String get deleteUserDataTitle => 'Delete all data?';

  @override
  String get deleteUserDataMessage =>
      'All transactions, wallets, goals, categories, budgets, and settings in the app will be permanently deleted. Your login and profile (email, name) will stay.';

  @override
  String get deleteUserDataConfirm => 'Delete data';

  @override
  String get deleteAccountButton => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountMessage =>
      'Your account and all data will be permanently removed. This cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String get enterPasswordToConfirmDelete => 'Enter your password to confirm';

  @override
  String get continueWithGoogleToConfirmDelete =>
      'Sign in with Google to confirm';

  @override
  String get userDataDeleted => 'All data has been deleted';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordCardSubtitle => 'Tap to change your password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get enterYourCurrentPassword => 'Enter your current password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get passwordChangeEmailOnly =>
      'Password change is only available for email sign-in';

  @override
  String get account => 'Account';

  @override
  String get accountTitle => 'Your account';

  @override
  String get accountSubtitle => 'Manage your account';

  @override
  String get accountSettings => 'Account settings';
}
