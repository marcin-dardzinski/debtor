import 'package:debtor/clients/nbp_api_client.dart';
import 'package:debtor/services/currency_exchange_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNBPApiClient extends Mock implements NBPApiClient {}

void main() {
  group('CurrencyExchangeService', () {
    test('Available currencies are retrieved correctly.', () async {
      final client = MockNBPApiClient();

      when(client.getCurrentExchangeRates())
          .thenAnswer((_) async => <Map<String, dynamic>>[
                <String, dynamic>{
                  "rates": [
                    {
                      "currency": "bat (Tajlandia)",
                      "code": "THB",
                      "mid": 0.1216
                    },
                    {
                      "currency": "dolar amerykański",
                      "code": "USD",
                      "mid": 3.8498
                    },
                    {
                      "currency": "dolar australijski",
                      "code": "AUD",
                      "mid": 2.6630
                    }
                  ]
                }
              ]);
      final service = CurrencyExchangeService(client);
      final availableCurrencies = await service.getAvailableCurrencies();

      expect(availableCurrencies, <String>['THB', 'USD', 'AUD']);
    });
  });
}
