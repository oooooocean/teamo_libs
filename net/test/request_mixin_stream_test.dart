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

  group('isSseStreamDone', () {
    test('[DONE] literal returns true', () {
      expect(isSseStreamDone('[DONE]'), isTrue);
    });

    test('{"type":"done"} JSON returns true', () {
      expect(isSseStreamDone('{"type":"done"}'), isTrue);
    });

    test('{"type":"done","conversation_id":1} with extra fields returns true', () {
      expect(isSseStreamDone('{"type":"done","conversation_id":1}'), isTrue);
    });

    test('{"type":"content","content":"hello"} returns false', () {
      expect(isSseStreamDone('{"type":"content","content":"hello"}'), isFalse);
    });

    test('{"type":"error","error":"oops"} returns false', () {
      expect(isSseStreamDone('{"type":"error","error":"oops"}'), isFalse);
    });

    test('{"type":"metadata"} returns false', () {
      expect(isSseStreamDone('{"type":"metadata"}'), isFalse);
    });

    test('plain text returns false', () {
      expect(isSseStreamDone('hello world'), isFalse);
    });

    test('empty string returns false', () {
      expect(isSseStreamDone(''), isFalse);
    });
  });
}

