import 'package:flutter/foundation.dart';
import '../services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  Currency _currency = CurrencyService.detectCurrency();

  Currency get currency => _currency;
  String get symbol => _currency.symbol;
  String get code => _currency.code;

  CurrencyProvider() {
    _detectCurrency();
  }

  Future<void> _detectCurrency() async {
    try {
      if (kIsWeb) {
        final locale = defaultTargetPlatform == TargetPlatform.windows
            ? 'en-US'
            : 'en-US';
        _currency = Currency.fromLocale(locale);
      } else {
        final locale = defaultTargetPlatform == TargetPlatform.windows
            ? 'en-US'
            : 'en-US';
        _currency = Currency.fromLocale(locale);
      }
      notifyListeners();
    } catch (e) {
      _currency = Currency.usd;
      notifyListeners();
    }
  }

  void setCurrency(Currency currency) {
    _currency = currency;
    notifyListeners();
  }

  String format(double inrAmount, {int decimals = 2}) {
    final localAmount = _currency.convertFromInr(inrAmount);
    return _currency.format(localAmount, decimals: decimals);
  }
}
