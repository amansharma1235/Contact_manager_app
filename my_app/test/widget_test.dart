import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/contact.dart';
import 'package:my_app/utils/validators.dart';

void main() {
  test('Contact model creates vCard and initials correctly', () {
    final contact = Contact(
      id: 'test-1',
      name: 'Aman Sharma',
      phone: '+91 98765 43210',
      email: 'aman@example.com',
      category: 'Work',
      notes: 'Lead developer',
    );

    expect(contact.initials, 'AS');
    expect(contact.toVCard(), contains('BEGIN:VCARD'));
    expect(contact.toVCard(), contains('FN:Aman Sharma'));
    expect(contact.toVCard(), contains('EMAIL;TYPE=INTERNET:aman@example.com'));
    expect(contact.toVCard(), contains('END:VCARD'));
  });

  test('Validators properly validate name, phone, and email', () {
    expect(Validators.validateName(''), isNotNull);
    expect(Validators.validateName('A'), isNotNull);
    expect(Validators.validateName('Aman'), isNull);

    expect(Validators.validatePhone(''), isNotNull);
    expect(Validators.validatePhone('123'), isNotNull);
    expect(Validators.validatePhone('+91 98765 43210'), isNull);

    expect(Validators.validateEmail(''), isNotNull);
    expect(Validators.validateEmail('invalid-email'), isNotNull);
    expect(Validators.validateEmail('aman@example.com'), isNull);
  });

  testWidgets('ContactManagerApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ContactManagerApp());
    await tester.pump();
    expect(find.text('Contacts'), findsOneWidget);
  });
}
