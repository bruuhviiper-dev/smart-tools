import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_theme.dart';
import 'l10n/strings.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/app_state.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // País do aparelho -> define métrico × imperial por padrão.
  final country =
      WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  final appState = AppState(prefs, country: country);

  runApp(SmartToolsApp(appState: appState));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    AdsService.instance.init();
    PurchaseService.instance
      ..onEntitlement((id) {
        // Qualquer produto Pro (assinatura ou vitalício) libera tudo.
        if (PurchaseService.proProducts.contains(id)) appState.grantPro();
      })
      ..init();
  });
}

class SmartToolsApp extends StatelessWidget {
  const SmartToolsApp({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, s, _) => MaterialApp(
          onGenerateTitle: (ctx) => T.of(ctx).appName,
          debugShowCheckedModeBanner: false,
          // Segue o idioma do aparelho; árabe ativa RTL automaticamente.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: T.locales,
          localeResolutionCallback: (device, supported) {
            if (device != null) {
              for (final sl in supported) {
                if (sl.languageCode == device.languageCode) return sl;
              }
            }
            return const Locale('en');
          },
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: s.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
