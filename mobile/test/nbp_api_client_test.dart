import 'package:debtor/clients/nbp_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NBPApiClient', () {
    test(
        'NBP api client returns proper query for fetching available currencies.',
        () {
      final client = NBPApiClient();
      final query = client.getCurrentExchangeRatesQuery();

      expect(query, 'http://api.nbp.pl/api/tables/a?format=json');
    });
  });
}
