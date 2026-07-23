import 'package:ciini_kaarey/main.dart';
import 'package:ciini_kaarey/services/storage_service.dart';
import 'package:ciini_kaarey/ui/screens/configuration_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('L\'accueil s\'affiche et navigue vers la configuration',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();

    await tester.pumpWidget(CiiniKaareyApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('Ciini Kaarey'), findsOneWidget);
    expect(find.text('Nouveau Khatim'), findsOneWidget);

    await tester.tap(find.text('Nouveau Khatim'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfigurationScreen), findsOneWidget);
    expect(find.text('1. Type de Khatim'), findsOneWidget);
    expect(find.text('Générer le Khatim'), findsOneWidget);
  });
}
