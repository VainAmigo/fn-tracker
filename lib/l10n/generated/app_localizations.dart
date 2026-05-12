import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ky'),
    Locale('ru'),
  ];

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @januaryShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get januaryShort;

  /// No description provided for @februaryShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get februaryShort;

  /// No description provided for @marchShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marchShort;

  /// No description provided for @aprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprilShort;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShort;

  /// No description provided for @juneShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get juneShort;

  /// No description provided for @julyShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julyShort;

  /// No description provided for @augustShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augustShort;

  /// No description provided for @septemberShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get septemberShort;

  /// No description provided for @octoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octoberShort;

  /// No description provided for @novemberShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novemberShort;

  /// No description provided for @decemberShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decemberShort;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get sixMonths;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @deleteEntityCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteEntityCancel;

  /// No description provided for @deleteEntityPartial.
  ///
  /// In en, this message translates to:
  /// **'Delete partially'**
  String get deleteEntityPartial;

  /// No description provided for @deleteEntityFull.
  ///
  /// In en, this message translates to:
  /// **'Delete fully'**
  String get deleteEntityFull;

  /// No description provided for @deleteEntityPartialHint.
  ///
  /// In en, this message translates to:
  /// **'Delete partially — remove the goal/wallet, transactions will be preserved.'**
  String get deleteEntityPartialHint;

  /// No description provided for @deleteEntityFullHint.
  ///
  /// In en, this message translates to:
  /// **'Delete fully — remove together with all related transactions.'**
  String get deleteEntityFullHint;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no transactions yet'**
  String get noTransactionsSubtitle;

  /// No description provided for @exportColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exportColumnDate;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @exportColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exportColumnType;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @exportColumnCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get exportColumnCurrency;

  /// No description provided for @exportColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exportColumnCategory;

  /// No description provided for @exportColumnWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get exportColumnWallet;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @exportColumnTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get exportColumnTransactionId;

  /// No description provided for @exportColumnDateDescription.
  ///
  /// In en, this message translates to:
  /// **'Transaction date selected by user.'**
  String get exportColumnDateDescription;

  /// No description provided for @exportColumnCreatedAtDescription.
  ///
  /// In en, this message translates to:
  /// **'Record creation date in database.'**
  String get exportColumnCreatedAtDescription;

  /// No description provided for @exportColumnTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Transaction type: expense, income, or transfer.'**
  String get exportColumnTypeDescription;

  /// No description provided for @exportColumnAmountDescription.
  ///
  /// In en, this message translates to:
  /// **'Transaction amount with 2 decimal places.'**
  String get exportColumnAmountDescription;

  /// No description provided for @exportColumnCurrencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Currency code used in transaction.'**
  String get exportColumnCurrencyDescription;

  /// No description provided for @exportColumnCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Category name linked to transaction.'**
  String get exportColumnCategoryDescription;

  /// No description provided for @exportColumnWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'Wallet name linked to transaction.'**
  String get exportColumnWalletDescription;

  /// No description provided for @exportColumnNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'User note from transaction.'**
  String get exportColumnNoteDescription;

  /// No description provided for @exportColumnTransactionIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Unique transaction identifier.'**
  String get exportColumnTransactionIdDescription;

  /// No description provided for @startTakingControlOfYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Start taking control of your finances'**
  String get startTakingControlOfYourFinances;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// Validation message when password is shorter than the minimum length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters'**
  String passwordMustBeAtLeast(int minLength);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @quickCategories.
  ///
  /// In en, this message translates to:
  /// **'Quick Categories'**
  String get quickCategories;

  /// No description provided for @lastTransactions.
  ///
  /// In en, this message translates to:
  /// **'Last Transactions'**
  String get lastTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @homeWalletsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which wallets appear on the home screen'**
  String get homeWalletsSettingsSubtitle;

  /// No description provided for @showOnHome.
  ///
  /// In en, this message translates to:
  /// **'Show on home'**
  String get showOnHome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @financeTabOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Tab order'**
  String get financeTabOrderTitle;

  /// No description provided for @financeTabOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag by the handle on the left to reorder tabs on the Finance screen'**
  String get financeTabOrderSubtitle;

  /// No description provided for @financeTabOrderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display order'**
  String get financeTabOrderSectionTitle;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @chooseHowCategoriesAreDisplayed.
  ///
  /// In en, this message translates to:
  /// **'Choose how categories are displayed on the home screen'**
  String get chooseHowCategoriesAreDisplayed;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @showCategoriesFromYourLastTransactions.
  ///
  /// In en, this message translates to:
  /// **'Show categories from your last transactions'**
  String get showCategoriesFromYourLastTransactions;

  /// No description provided for @showCategoriesFromYourQuickCategories.
  ///
  /// In en, this message translates to:
  /// **'Show categories you\'ve pinned for quick access'**
  String get showCategoriesFromYourQuickCategories;

  /// No description provided for @homeScreenWidgetSource.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget source'**
  String get homeScreenWidgetSource;

  /// No description provided for @systemQuickCategories.
  ///
  /// In en, this message translates to:
  /// **'System quick categories'**
  String get systemQuickCategories;

  /// No description provided for @userQuickCategories.
  ///
  /// In en, this message translates to:
  /// **'User categories from current quick mode'**
  String get userQuickCategories;

  /// No description provided for @customCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom categories'**
  String get customCategories;

  /// No description provided for @chooseFixedCategories.
  ///
  /// In en, this message translates to:
  /// **'Choose a fixed list of categories for the home screen'**
  String get chooseFixedCategories;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @createCategoriesFirst.
  ///
  /// In en, this message translates to:
  /// **'Create categories first'**
  String get createCategoriesFirst;

  /// No description provided for @pinnedCategories.
  ///
  /// In en, this message translates to:
  /// **'Pinned Categories'**
  String get pinnedCategories;

  /// No description provided for @selectCategoriesToShowInQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Select categories to show in quick access on home'**
  String get selectCategoriesToShowInQuickAccess;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @widgetCategories.
  ///
  /// In en, this message translates to:
  /// **'Widget Categories'**
  String get widgetCategories;

  /// No description provided for @selectCustomCategoriesForTheHomeScreenWidget.
  ///
  /// In en, this message translates to:
  /// **'Select custom categories for the home screen widget'**
  String get selectCustomCategoriesForTheHomeScreenWidget;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @manageYourAccountAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences'**
  String get manageYourAccountAndPreferences;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get appTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currencyAndFormats.
  ///
  /// In en, this message translates to:
  /// **'Currency and formats'**
  String get currencyAndFormats;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectYourCurrencyAndNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Select your currency and number format'**
  String get selectYourCurrencyAndNumberFormat;

  /// No description provided for @dynamicColorsOfTheDevice.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors of the device'**
  String get dynamicColorsOfTheDevice;

  /// No description provided for @dynamicColorsOfTheDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'On Android 12+ the theme is adapted to the device. On other platforms or if colors are not available, the palette below is used.'**
  String get dynamicColorsOfTheDeviceDescription;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @amountCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be empty'**
  String get amountCannotBeEmpty;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @selectBothSourceAndDestinationAccounts.
  ///
  /// In en, this message translates to:
  /// **'Select both source and destination accounts'**
  String get selectBothSourceAndDestinationAccounts;

  /// No description provided for @sourceAndDestinationMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Source and destination must be different'**
  String get sourceAndDestinationMustBeDifferent;

  /// No description provided for @selectWalletOrGoal.
  ///
  /// In en, this message translates to:
  /// **'Select a wallet or goal'**
  String get selectWalletOrGoal;

  /// No description provided for @categoryCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Category cannot be empty'**
  String get categoryCannotBeEmpty;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @enterYourNote.
  ///
  /// In en, this message translates to:
  /// **'Enter your note'**
  String get enterYourNote;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose account'**
  String get chooseAccount;

  /// No description provided for @yourWallets.
  ///
  /// In en, this message translates to:
  /// **'Your wallets'**
  String get yourWallets;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get yourGoals;

  /// No description provided for @cannotSelectSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot select the same account'**
  String get cannotSelectSameAccount;

  /// No description provided for @addWithVoice.
  ///
  /// In en, this message translates to:
  /// **'Add with voice'**
  String get addWithVoice;

  /// No description provided for @addWithFile.
  ///
  /// In en, this message translates to:
  /// **'Add with file'**
  String get addWithFile;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @addTransactionWithAi.
  ///
  /// In en, this message translates to:
  /// **'Add transaction with AI'**
  String get addTransactionWithAi;

  /// No description provided for @enterTransactionsManuallyOrUseTemplates.
  ///
  /// In en, this message translates to:
  /// **'Enter transactions manually or use templates'**
  String get enterTransactionsManuallyOrUseTemplates;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get removeFile;

  /// No description provided for @textCanBeEdited.
  ///
  /// In en, this message translates to:
  /// **'Text can be edited'**
  String get textCanBeEdited;

  /// No description provided for @cancelAndReturnToInput.
  ///
  /// In en, this message translates to:
  /// **'Cancel and return to input'**
  String get cancelAndReturnToInput;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get saveAll;

  /// No description provided for @returnToInput.
  ///
  /// In en, this message translates to:
  /// **'Return to input'**
  String get returnToInput;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @recognize.
  ///
  /// In en, this message translates to:
  /// **'Recognize'**
  String get recognize;

  /// No description provided for @upTo5Words.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 words'**
  String get upTo5Words;

  /// No description provided for @yourFinancesAndSavings.
  ///
  /// In en, this message translates to:
  /// **'Your finances and savings'**
  String get yourFinancesAndSavings;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @scheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'Scheduled payments'**
  String get scheduledPayments;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get createBudget;

  /// No description provided for @noBudgetFound.
  ///
  /// In en, this message translates to:
  /// **'No budget found. Please create one.'**
  String get noBudgetFound;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget details'**
  String get budgetDetails;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get deleteBudgetConfirmation;

  /// No description provided for @noHistoryEntries.
  ///
  /// In en, this message translates to:
  /// **'No history entries'**
  String get noHistoryEntries;

  /// No description provided for @editHistoryEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit history entry'**
  String get editHistoryEntry;

  /// No description provided for @deleteHistoryEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete history entry?'**
  String get deleteHistoryEntry;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get budgetExceeded;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @overspent.
  ///
  /// In en, this message translates to:
  /// **'Overspent'**
  String get overspent;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @effectiveFrom.
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get effectiveFrom;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @aboutBudget.
  ///
  /// In en, this message translates to:
  /// **'About budget'**
  String get aboutBudget;

  /// No description provided for @budgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Budget is a monthly spending limit. You can track how much you spend against it and add new amounts when your budget changes.'**
  String get budgetDescription;

  /// No description provided for @addOptions.
  ///
  /// In en, this message translates to:
  /// **'Add options'**
  String get addOptions;

  /// No description provided for @replaceAllDescription.
  ///
  /// In en, this message translates to:
  /// **'Replaces all budget history with the new amount. Use when you want to reset your budget completely.'**
  String get replaceAllDescription;

  /// No description provided for @fromDateDescription.
  ///
  /// In en, this message translates to:
  /// **'Adds a new budget amount effective from a specific date. Previous entries remain in history.'**
  String get fromDateDescription;

  /// No description provided for @yearlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Yearly budget'**
  String get yearlyBudget;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @weeklyBudget.
  ///
  /// In en, this message translates to:
  /// **'Weekly budget'**
  String get weeklyBudget;

  /// No description provided for @budgetCategories.
  ///
  /// In en, this message translates to:
  /// **'Budget categories'**
  String get budgetCategories;

  /// No description provided for @limitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Limit exceeded'**
  String get limitExceeded;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @createWallet.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get createWallet;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @pinSuccessfullyChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN successfully changed'**
  String get pinSuccessfullyChanged;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @pinRequiredForHiddenCards.
  ///
  /// In en, this message translates to:
  /// **'PIN is required for hidden cards'**
  String get pinRequiredForHiddenCards;

  /// No description provided for @hiddenCards.
  ///
  /// In en, this message translates to:
  /// **'Hidden cards'**
  String get hiddenCards;

  /// No description provided for @enterPinToView.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to view'**
  String get enterPinToView;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @invalidPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN'**
  String get invalidPin;

  /// No description provided for @goalUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal updated successfully'**
  String get goalUpdatedSuccessfully;

  /// No description provided for @goalCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal created successfully'**
  String get goalCreatedSuccessfully;

  /// No description provided for @updateGoal.
  ///
  /// In en, this message translates to:
  /// **'Update goal'**
  String get updateGoal;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @howMuchDoYouWantToSave.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to save?'**
  String get howMuchDoYouWantToSave;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @enterValidTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid target amount'**
  String get enterValidTargetAmount;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @walletUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Wallet updated successfully'**
  String get walletUpdatedSuccessfully;

  /// No description provided for @walletCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Wallet created successfully'**
  String get walletCreatedSuccessfully;

  /// No description provided for @updateWallet.
  ///
  /// In en, this message translates to:
  /// **'Update wallet'**
  String get updateWallet;

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletName;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @goalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal details'**
  String get goalDetailsTitle;

  /// No description provided for @goalAmount.
  ///
  /// In en, this message translates to:
  /// **'Goal amount'**
  String get goalAmount;

  /// No description provided for @completedAmount.
  ///
  /// In en, this message translates to:
  /// **'Completed amount'**
  String get completedAmount;

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed at'**
  String get completedAt;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get deleteGoalMessage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @hideAmount.
  ///
  /// In en, this message translates to:
  /// **'Hide amount'**
  String get hideAmount;

  /// No description provided for @hideGoal.
  ///
  /// In en, this message translates to:
  /// **'Hide goal'**
  String get hideGoal;

  /// No description provided for @hideGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Will be visible only in the \"Hidden cards\" block'**
  String get hideGoalSubtitle;

  /// No description provided for @deleteGoalMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the way to delete the goal'**
  String get deleteGoalMessageHint;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoals;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'card'**
  String get card;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'cards'**
  String get cards;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @totalProgress.
  ///
  /// In en, this message translates to:
  /// **'Total progress'**
  String get totalProgress;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @walletDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet details'**
  String get walletDetails;

  /// No description provided for @hideWallet.
  ///
  /// In en, this message translates to:
  /// **'Hide wallet'**
  String get hideWallet;

  /// No description provided for @hideWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Will be visible only in the \"Hidden cards\" block'**
  String get hideWalletSubtitle;

  /// No description provided for @deleteWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet?'**
  String get deleteWalletTitle;

  /// No description provided for @deleteWalletMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this wallet?'**
  String get deleteWalletMessage;

  /// No description provided for @deleteWalletMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the way to delete the wallet'**
  String get deleteWalletMessageHint;

  /// No description provided for @noWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get noWallets;

  /// No description provided for @createYourFirstWallet.
  ///
  /// In en, this message translates to:
  /// **'Create your first wallet'**
  String get createYourFirstWallet;

  /// No description provided for @newWallet.
  ///
  /// In en, this message translates to:
  /// **'New wallet'**
  String get newWallet;

  /// No description provided for @categoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Category details'**
  String get categoryDetails;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get deleteCategoryMessage;

  /// No description provided for @deleteCategoryMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the way to delete the category'**
  String get deleteCategoryMessageHint;

  /// No description provided for @scheduledPayment.
  ///
  /// In en, this message translates to:
  /// **'Scheduled payment'**
  String get scheduledPayment;

  /// No description provided for @paymentName.
  ///
  /// In en, this message translates to:
  /// **'payment name'**
  String get paymentName;

  /// No description provided for @paymentAmountDescription.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to pay?'**
  String get paymentAmountDescription;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// No description provided for @scheduledPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Scheduled payment type'**
  String get scheduledPaymentType;

  /// No description provided for @nextPayment.
  ///
  /// In en, this message translates to:
  /// **'Next payment'**
  String get nextPayment;

  /// No description provided for @walletOrGoal.
  ///
  /// In en, this message translates to:
  /// **'Wallet or goal'**
  String get walletOrGoal;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select wallet'**
  String get selectWallet;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @enableAutoPayment.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-payment'**
  String get enableAutoPayment;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @selectDateOrDays.
  ///
  /// In en, this message translates to:
  /// **'Select date or days'**
  String get selectDateOrDays;

  /// No description provided for @paymentDateMustBeInTheFuture.
  ///
  /// In en, this message translates to:
  /// **'Payment date must be in the future'**
  String get paymentDateMustBeInTheFuture;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @endOfMonth.
  ///
  /// In en, this message translates to:
  /// **'End of month'**
  String get endOfMonth;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @regularPayments.
  ///
  /// In en, this message translates to:
  /// **'Regular payments'**
  String get regularPayments;

  /// No description provided for @regularIncomePayments.
  ///
  /// In en, this message translates to:
  /// **'Regular income payments'**
  String get regularIncomePayments;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @paymentsOn.
  ///
  /// In en, this message translates to:
  /// **'Payments on'**
  String get paymentsOn;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @paymentFrequency.
  ///
  /// In en, this message translates to:
  /// **'Payment frequency'**
  String get paymentFrequency;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @daysOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Days of month'**
  String get daysOfMonth;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get dayOfMonth;

  /// No description provided for @paymentDatesInYear.
  ///
  /// In en, this message translates to:
  /// **'Payment dates in year'**
  String get paymentDatesInYear;

  /// No description provided for @dateMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Date (month & day)'**
  String get dateMonthDay;

  /// No description provided for @selectDateForOneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'Select date for one-time payment'**
  String get selectDateForOneTimePayment;

  /// No description provided for @paymentWillBeMadeOnSelectedDaysOfMonthEveryMonth.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made on selected days of month every month'**
  String get paymentWillBeMadeOnSelectedDaysOfMonthEveryMonth;

  /// No description provided for @paymentWillBeMadeOnSelectedDayOfMonthEveryMonth.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made on selected day of month every month'**
  String get paymentWillBeMadeOnSelectedDayOfMonthEveryMonth;

  /// No description provided for @paymentWillBeMadeOnSelectedDatesEveryYear.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made on selected dates every year'**
  String get paymentWillBeMadeOnSelectedDatesEveryYear;

  /// No description provided for @paymentWillBeMadeOnSelectedDateMonthDayEveryYear.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made on selected date (month & day) every year'**
  String get paymentWillBeMadeOnSelectedDateMonthDayEveryYear;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get first;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get second;

  /// No description provided for @third.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get third;

  /// No description provided for @th.
  ///
  /// In en, this message translates to:
  /// **'th'**
  String get th;

  /// No description provided for @selectedDays.
  ///
  /// In en, this message translates to:
  /// **'Selected days'**
  String get selectedDays;

  /// No description provided for @pressToSelectDays.
  ///
  /// In en, this message translates to:
  /// **'Press to select days'**
  String get pressToSelectDays;

  /// No description provided for @chooseMonthAndDay.
  ///
  /// In en, this message translates to:
  /// **'Choose month and day'**
  String get chooseMonthAndDay;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add date'**
  String get addDate;

  /// No description provided for @editScheduledPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit scheduled payment'**
  String get editScheduledPayment;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @autoCreateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Auto-create transaction'**
  String get autoCreateTransaction;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @typeOfScheduledPayment.
  ///
  /// In en, this message translates to:
  /// **'Type of scheduled payment'**
  String get typeOfScheduledPayment;

  /// No description provided for @createScheduledPayment.
  ///
  /// In en, this message translates to:
  /// **'Create scheduled payment'**
  String get createScheduledPayment;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @categoryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update category'**
  String get updateCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @createYourFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Create your first category'**
  String get createYourFirstCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @exportSettings.
  ///
  /// In en, this message translates to:
  /// **'Export settings'**
  String get exportSettings;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @selectedColumns.
  ///
  /// In en, this message translates to:
  /// **'Selected columns'**
  String get selectedColumns;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportFileIsReady.
  ///
  /// In en, this message translates to:
  /// **'Export file is ready'**
  String get exportFileIsReady;

  /// No description provided for @fileCreatedButShareDialogIsUnavailableOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'File created, but share dialog is unavailable on this device'**
  String get fileCreatedButShareDialogIsUnavailableOnThisDevice;

  /// No description provided for @noDataForSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for selected period'**
  String get noDataForSelectedPeriod;

  /// No description provided for @choosePeriodInExportSettings.
  ///
  /// In en, this message translates to:
  /// **'Choose period in export settings'**
  String get choosePeriodInExportSettings;

  /// No description provided for @failedToExportData.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get failedToExportData;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @customPeriod.
  ///
  /// In en, this message translates to:
  /// **'Custom period'**
  String get customPeriod;

  /// No description provided for @deepAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Deep analytics'**
  String get deepAnalytics;

  /// No description provided for @askAboutYourAnalyticsForThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Ask about your analytics for this period'**
  String get askAboutYourAnalyticsForThisPeriod;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @askAboutYourAnalyticsForThisPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your analytics…'**
  String get askAboutYourAnalyticsForThisPeriodHint;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get aiAssistant;

  /// No description provided for @spendingChart.
  ///
  /// In en, this message translates to:
  /// **'Spending chart'**
  String get spendingChart;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get enterNewPin;

  /// No description provided for @newPinDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New PIN does not match'**
  String get newPinDoesNotMatch;

  /// No description provided for @newPinMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New PIN must be different'**
  String get newPinMustBeDifferent;

  /// No description provided for @invalidCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid current PIN'**
  String get invalidCurrentPin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pinDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PIN does not match'**
  String get pinDoesNotMatch;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @aiGoalAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI savings advice'**
  String get aiGoalAdviceTitle;

  /// No description provided for @aiGoalAdviceSingleGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Ask how to save faster for this goal based on your real data.'**
  String get aiGoalAdviceSingleGoalHint;

  /// No description provided for @aiGoalAdviceAllGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for advice on how to optimize savings across all your goals.'**
  String get aiGoalAdviceAllGoalsHint;

  /// No description provided for @aiGoalAdviceQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'For example: what should I cut first to reach the goal faster?'**
  String get aiGoalAdviceQuestionHint;

  /// No description provided for @aiGoalAdviceAsk.
  ///
  /// In en, this message translates to:
  /// **'Get advice'**
  String get aiGoalAdviceAsk;

  /// No description provided for @aiGoalAdviceTotalAsk.
  ///
  /// In en, this message translates to:
  /// **'AI tips for all goals'**
  String get aiGoalAdviceTotalAsk;

  /// No description provided for @aiGoalAdviceTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'AI tips for all goals'**
  String get aiGoalAdviceTotalTitle;

  /// No description provided for @aiGoalAdviceDefaultQuestionAll.
  ///
  /// In en, this message translates to:
  /// **'Analyze all my goals, wallets, categories, and transactions. Give a short plan: which goals to prioritize, what spending to reduce first, and how to speed up my savings overall.'**
  String get aiGoalAdviceDefaultQuestionAll;

  /// No description provided for @aiGoalAdviceDefaultQuestionSingle.
  ///
  /// In en, this message translates to:
  /// **'Analyze all my data and give practical advice on how to reach the goal \"{goalName}\" faster: where to cut spending first and how much I should top up regularly.'**
  String aiGoalAdviceDefaultQuestionSingle(Object goalName);

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorAccountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email but a different sign-in method.'**
  String get authErrorAccountExistsWithDifferentCredential;

  /// No description provided for @authErrorCredentialAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already linked to another user.'**
  String get authErrorCredentialAlreadyInUse;

  /// No description provided for @authErrorProviderAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'Google is already linked to this account.'**
  String get authErrorProviderAlreadyLinked;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign out and sign in again, then try linking Google.'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Check your Google account or try again.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get authErrorNotSignedIn;

  /// No description provided for @authErrorGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Check app configuration in Firebase Console.'**
  String get authErrorGoogleSignIn;

  /// No description provided for @linkGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Google account'**
  String get linkGoogleTitle;

  /// No description provided for @linkGoogleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google on this device using the same profile'**
  String get linkGoogleSubtitle;

  /// No description provided for @googleAlreadyLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Google linked'**
  String get googleAlreadyLinkedTitle;

  /// No description provided for @googleAlreadyLinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can sign in with Google on this device'**
  String get googleAlreadyLinkedSubtitle;

  /// No description provided for @googleLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Google account linked'**
  String get googleLinkedSuccessfully;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @displayNameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get displayNameNotSet;

  /// No description provided for @displayNameTapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to change your display name'**
  String get displayNameTapToSet;

  /// No description provided for @displayNameWhenSet.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameWhenSet;

  /// No description provided for @editDisplayNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editDisplayNameTitle;

  /// No description provided for @displayNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display name updated'**
  String get displayNameUpdated;

  /// No description provided for @displayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long (max 120 characters)'**
  String get displayNameTooLong;

  /// No description provided for @deleteUserDataSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & account'**
  String get deleteUserDataSectionTitle;

  /// No description provided for @deleteUserDataButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteUserDataButton;

  /// No description provided for @deleteUserDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteUserDataTitle;

  /// No description provided for @deleteUserDataMessage.
  ///
  /// In en, this message translates to:
  /// **'All transactions, wallets, goals, categories, budgets, and settings in the app will be permanently deleted. Your login and profile (email, name) will stay.'**
  String get deleteUserDataMessage;

  /// No description provided for @deleteUserDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete data'**
  String get deleteUserDataConfirm;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account and all data will be permanently removed. This cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountConfirm;

  /// No description provided for @enterPasswordToConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get enterPasswordToConfirmDelete;

  /// No description provided for @continueWithGoogleToConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to confirm'**
  String get continueWithGoogleToConfirmDelete;

  /// No description provided for @userDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get userDataDeleted;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to change your password'**
  String get changePasswordCardSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @enterYourCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterYourCurrentPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordChangeEmailOnly.
  ///
  /// In en, this message translates to:
  /// **'Password change is only available for email sign-in'**
  String get passwordChangeEmailOnly;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get accountSubtitle;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// No description provided for @securityIntro.
  ///
  /// In en, this message translates to:
  /// **'One PIN protects hidden wallets and goals, and can lock the whole app. Biometrics use the same check when enabled.'**
  String get securityIntro;

  /// No description provided for @pinSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinSectionTitle;

  /// No description provided for @pinSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the PIN used for the app lock and hidden cards.'**
  String get pinSetSubtitle;

  /// No description provided for @pinNotSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN when you hide a wallet or tap here to set it now.'**
  String get pinNotSetSubtitle;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock app on open'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for PIN or biometrics after launching the app'**
  String get appLockSubtitle;

  /// No description provided for @biometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlockTitle;

  /// No description provided for @biometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID before entering PIN when available'**
  String get biometricUnlockSubtitle;

  /// No description provided for @unlockAppTitle.
  ///
  /// In en, this message translates to:
  /// **'App is locked'**
  String get unlockAppTitle;

  /// No description provided for @unlockAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get unlockAppSubtitle;

  /// No description provided for @biometricPromptUnlock.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you'**
  String get biometricPromptUnlock;

  /// No description provided for @useBiometricButton.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometricButton;

  /// No description provided for @biometricsHintNoneEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No fingerprint or Face ID is set up on this device. Add one in system Settings → Security, then open this screen again.'**
  String get biometricsHintNoneEnrolled;

  /// No description provided for @biometricsHintUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not report biometric hardware (common on some emulators).'**
  String get biometricsHintUnsupported;

  /// No description provided for @biometricsHintProbeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read biometric status. Fully restart the app, or run a clean rebuild after adding biometrics support.'**
  String get biometricsHintProbeFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ky', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ky':
      return AppLocalizationsKy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
