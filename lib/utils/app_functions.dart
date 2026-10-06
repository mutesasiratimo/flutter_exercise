class AppFunctions {

  static String numberFormat(num n) {
    String numString = n.toString();
    // Split string by decimal points if any
    List<String> splitString = numString.split(".");

    String decimalPart = splitString.length > 1 ? splitString[1] : '';
    String integerPart = splitString[0];

    RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = integerPart.replaceAllMapped(
      regExp,
      (Match match) => '${match[1]},',
    );

    return '$result$decimalPart';
  }
}
