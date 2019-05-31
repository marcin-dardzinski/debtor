class CurrenciesService {
  factory CurrenciesService() {
    return _instance;
  }
  CurrenciesService._internal();

  static final CurrenciesService _instance = CurrenciesService._internal();

  List<String> get allCurrencies => _allCurrencies;

  static final List<String> _allCurrencies = List.unmodifiable(<String>[
    'THB',
    'USD',
    'KRW',
    'CNY',
    'XDR',
    'AUD',
    'HKD',
    'CAD',
    'NZD',
    'SGD',
    'EUR',
    'HUF',
    'CHF',
    'GBP',
    'UAH',
    'JPY',
    'CZK',
    'DKK',
    'ISK',
    'NOK',
    'SEK',
    'HRK',
    'RON',
    'BGN',
    'TRY',
    'ILS',
    'CLP',
    'PHP',
    'MXN',
    'ZAR',
    'BRL',
    'MYR',
    'RUB',
    'IDR',
    'INR',
    'PLN'
  ]..sort());
}
