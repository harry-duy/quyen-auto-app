import 'package:flutter_test/flutter_test.dart';
import 'package:quyen_auto_app/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null for valid input', () {
      expect(Validators.required('hello'), isNull);
    });

    test('uses custom field name in message', () {
      final result = Validators.required(null, 'Email');
      expect(result, contains('Email'));
    });
  });

  group('Validators.phone', () {
    test('returns error for null', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for empty', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('returns error for too short', () {
      expect(Validators.phone('090123'), isNotNull);
    });

    test('returns error for invalid prefix', () {
      expect(Validators.phone('0101234567'), isNotNull);
    });

    test('accepts valid phone 09x', () {
      expect(Validators.phone('0912345678'), isNull);
    });

    test('accepts valid phone 03x', () {
      expect(Validators.phone('0312345678'), isNull);
    });

    test('accepts valid phone 07x', () {
      expect(Validators.phone('0712345678'), isNull);
    });

    test('accepts valid phone 08x', () {
      expect(Validators.phone('0812345678'), isNull);
    });

    test('accepts valid phone 05x', () {
      expect(Validators.phone('0512345678'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for null', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error for empty', () {
      expect(Validators.password(''), isNotNull);
    });

    test('returns error for too short', () {
      expect(Validators.password('12345'), isNotNull);
    });

    test('accepts 6+ chars', () {
      expect(Validators.password('123456'), isNull);
    });

    test('accepts long password', () {
      expect(Validators.password('a_very_secure_password'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns null for null (optional field)', () {
      expect(Validators.email(null), isNull);
    });

    test('returns null for empty (optional field)', () {
      expect(Validators.email(''), isNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('returns error for missing @', () {
      expect(Validators.email('test.example.com'), isNotNull);
    });

    test('accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('accepts email with subdomain', () {
      expect(Validators.email('user@mail.example.com'), isNull);
    });
  });
}
