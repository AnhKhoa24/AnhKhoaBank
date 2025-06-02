import 'package:intl/intl.dart';

class FormatUtils {
  static String formatBalance(int balance) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(balance);
  }
  static String maskAccountNumber(String accountNumber) {
    final length = accountNumber.length;

    if (length <= 3) {
      return accountNumber;
    } else if (length <= 6) {
      final part1 = accountNumber.substring(0, 3);
      final part2 = accountNumber.substring(3);
      return '$part1 $part2';
    } else {
      final part1 = accountNumber.substring(0, 3);
      final part2 = accountNumber.substring(3, 6);
      final part3 = accountNumber.substring(6);
      return '$part1 $part2 $part3';
    }
  }
}
