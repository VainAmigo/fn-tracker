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
  String get exportColumnCreatedAt => 'Created at';

  @override
  String get exportColumnType => 'Type';

  @override
  String get exportColumnAmount => 'Amount';

  @override
  String get exportColumnCurrency => 'Currency';

  @override
  String get exportColumnCategory => 'Category';

  @override
  String get exportColumnWallet => 'Wallet';

  @override
  String get exportColumnNote => 'Note';

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
}
