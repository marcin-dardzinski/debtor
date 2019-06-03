import 'package:debtor/clients/nbp_api_client.dart';

class CurrencyExchangeService {
  final NBPApiClient client;

  CurrencyExchangeService(this.client);

  Future<List<String>> getAvailableCurrencies() async {
    final currentExchangeRates = await client.getCurrentExchangeRates();
    final dynamic availableCurrencies = currentExchangeRates[0]['rates']
        .map((dynamic rate) => rate['code'])
        .toList()
          ..add('PLN');
    return availableCurrencies.cast<String>();
  }
}
