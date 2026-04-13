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

  /// No description provided for @exportColumnCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get exportColumnCreatedAt;

  /// No description provided for @exportColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exportColumnType;

  /// No description provided for @exportColumnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exportColumnAmount;

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

  /// No description provided for @exportColumnNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get exportColumnNote;

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
