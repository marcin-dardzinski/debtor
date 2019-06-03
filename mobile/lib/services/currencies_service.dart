import 'package:debtor/clients/nbp_api_client.dart';

class CurrencyExchangeService {
  factory CurrencyExchangeService() {
    return _instance;
  }
  CurrencyExchangeService._internal();

  static final CurrencyExchangeService _instance =
      CurrencyExchangeService._internal();

  final NBPApiClient client = NBPApiClient();

  Future<List<String>> allCuriencies() async {
    final currentExchangeRates = await client.getCurrentExchangeRates();
    final availableCurrencies = currentExchangeRates
        .map<String>((Map<String, dynamic> rate) => rate['code']);
    return availableCurrencies.toList()
      ..add('PLN')
      ..sort();
  }

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
