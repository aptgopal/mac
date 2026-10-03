import 'dart:io';

enum Currency {
  inr('INR', '₹', 1.0, 'en-IN'),
  usd('USD', '\$', 83.0, 'en-US'),
  eur('EUR', '€', 90.0, 'en-EU'),
  gbp('GBP', '£', 105.0, 'en-GB'),
  cny('CNY', '¥', 11.0, 'zh-CN'),
  jpy('JPY', '¥', 0.55, 'ja-JP'),
  aud('AUD', 'A\$', 55.0, 'en-AU'),
  cad('CAD', 'C\$', 61.0, 'en-CA'),
  sgd('SGD', 'S\$', 61.0, 'en-SG');

  final String code;
  final String symbol;
  final double rateToInr;
  final String locale;

  const Currency(this.code, this.symbol, this.rateToInr, this.locale);

  static Currency fromLocale(String locale) {
    final normalized = locale.toLowerCase();
    if (normalized.startsWith('in')) return Currency.inr;
    if (normalized.startsWith('zh')) return Currency.cny;
    if (normalized.startsWith('ja')) return Currency.jpy;
    if (normalized.startsWith('de') || normalized.startsWith('fr') || normalized.startsWith('it') || normalized.startsWith('es')) return Currency.eur;
    if (normalized.startsWith('en-au')) return Currency.aud;
    if (normalized.startsWith('en-ca')) return Currency.cad;
    if (normalized.startsWith('en-sg')) return Currency.sgd;
    if (normalized.startsWith('en-gb')) return Currency.gbp;
    if (normalized.startsWith('en-us')) return Currency.usd;
    return Currency.usd;
  }

  static Currency fromCountryCode(String? countryCode) {
    if (countryCode == null) return Currency.usd;
    final code = countryCode.toUpperCase();
    switch (code) {
      case 'IN':
        return Currency.inr;
      case 'US':
        return Currency.usd;
      case 'GB':
        return Currency.gbp;
      case 'EU':
      case 'DE':
      case 'FR':
      case 'IT':
      case 'ES':
        return Currency.eur;
      case 'CN':
        return Currency.cny;
      case 'JP':
        return Currency.jpy;
      case 'AU':
        return Currency.aud;
      case 'CA':
        return Currency.cad;
      case 'SG':
        return Currency.sgd;
      default:
        return Currency.usd;
    }
  }

  double convertFromInr(double inrAmount) {
    return inrAmount / rateToInr;
  }

  double convertToInr(double localAmount) {
    return localAmount * rateToInr;
  }

  String format(double amount, {int decimals = 2}) {
    final formatted = amount.toStringAsFixed(decimals);
    return '$symbol$formatted';
  }
}

class CurrencyService {
  static Currency get currency => Currency.inr;

  static Currency detectCurrency() {
    try {
      final locale = Platform.localeName;
      return Currency.fromLocale(locale);
    } catch (e) {
      return Currency.usd;
    }
  }

  static String formatInr(double inrAmount, {int decimals = 2}) {
    return currency.format(inrAmount, decimals: decimals);
  }

  static String formatLocal(double inrAmount, Currency localCurrency, {int decimals = 2}) {
    final localAmount = localCurrency.convertFromInr(inrAmount);
    return localCurrency.format(localAmount, decimals: decimals);
  }
}
