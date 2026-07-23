import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'ui/providers/history_provider.dart';
import 'ui/providers/khatim_provider.dart';
import 'ui/providers/settings_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(CiiniKaareyApp(storage: storage));
}

class CiiniKaareyApp extends StatelessWidget {
  const CiiniKaareyApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(create: (_) => KhatimProvider(storage: storage)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(storage)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Ciini Kaarey — Khatim',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: const Locale('fr'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'),
            Locale('ar'),
          ],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
