import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;

class NBPApiClient {
  final String _endpointUrl = 'http://api.nbp.pl/api';
  final _client = http.Client();

  String getCurrentExchangeRatesQuery() {
    return '$_endpointUrl/exchangerates/tables/a?format=json';
  }

  String getExchangeRateQuery(String currencyCode) {
    return '$_endpointUrl/exchangerates/rates/a/$currencyCode?format=json';
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

  Future<Decimal> getExchangeRate(String currencyCode) async {
    if (currencyCode == 'PLN') {
      return Decimal.fromInt(1);
    }

    final queryString = getExchangeRateQuery(currencyCode);
    final response = await _client.get(queryString);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exchange rate for $currencyCode!');
    }

    final dynamic jsonResponse = json.decode(response.body);
    return Decimal.parse(jsonResponse['rates'][0]['mid'].toString());
  }
}
