import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net/request_mixin.dart';

void main() {
  group('extractSsePayload', () {
    test('returns null when no data lines exist', () {
      expect(extractSsePayload('event: ping\n\n'), isNull);
    });

    test('collects single data line', () {
      expect(extractSsePayload('data: {"id":1}\n\n'), '{"id":1}');
    });

    test('merges multiple data lines', () {
      final rawEvent = 'data: delta\n'
          'data: token\n'
          '\n';
      expect(extractSsePayload(rawEvent), 'delta\ntoken');
    });
  });

  group('decodeSsePayload', () {
    test('returns payload for string target', () {
      expect(decodeSsePayload<String>('hello', null), 'hello');
    });

    test('uses custom decoder when provided', () {
      final decoder = (String payload) => int.parse(payload);
      expect(decodeSsePayload<int>('42', decoder), 42);
    });

    test('throws when decoder missing for non-string target', () {
      expect(
        () => decodeSsePayload<int>('42', null),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}

