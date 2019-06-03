import 'dart:convert';

import 'package:http/http.dart' as http;

class NBPApiClient {
  final String _endpointUrl = 'http://api.nbp.pl/api';
  final _client = http.Client();

  String getCurrentExchangeRatesQuery() {
    return '$_endpointUrl/exchangerates/tables/a?format=json';
  }

  Future<List<Map<String, dynamic>>> getCurrentExchangeRates() async {
    final response = await _client.get(getCurrentExchangeRatesQuery());
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch available currencies!');
    }
    final dynamic jsonResponse = json.decode(response.body);
    final dynamic rates = jsonResponse[0]['rates'];

    return rates.cast<Map<String, dynamic>>();
  }
}
