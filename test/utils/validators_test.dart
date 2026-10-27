import 'package:flutter_test/flutter_test.dart';
import 'package:visitorappointment/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateRequired returns error when null or empty', () {
      expect(Validators.validateRequired(null, 'Name'), equals('Name is required'));
      expect(Validators.validateRequired('', 'Name'), equals('Name is required'));
      expect(Validators.validateRequired('   ', 'Name'), equals('Name is required'));
      expect(Validators.validateRequired('Valid Name', 'Name'), isNull);
    });

    test('validateMobile validates 10 numeric digits', () {
      expect(Validators.validateMobile(null), equals('Mobile number is required'));
      expect(Validators.validateMobile(''), equals('Mobile number is required'));
      expect(Validators.validateMobile('12345'), equals('Mobile number must be exactly 10 digits'));
      expect(Validators.validateMobile('123456789012'), equals('Mobile number must be exactly 10 digits'));
      expect(Validators.validateMobile('98765abcde'), equals('Mobile number must contain digits only'));
      expect(Validators.validateMobile('9876543210'), isNull);
    });

    test('validateEmail allows empty optional or validates format', () {
      expect(Validators.validateEmail(null), isNull);
      expect(Validators.validateEmail(''), isNull);
      expect(Validators.validateEmail('invalid-email'), equals('Enter a valid email address'));
      expect(Validators.validateEmail('john@'), equals('Enter a valid email address'));
      expect(Validators.validateEmail('john@example.com'), isNull);
    });
  });
}
