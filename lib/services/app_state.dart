import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/units.dart';

/// Estado global: tema, sistema de medidas regional e entitlements (Pro).
class AppState extends ChangeNotifier {
  AppState(this._prefs, {String? country}) : _country = country {
    _dark = _prefs.getBool(_kDark) ?? false;
    _unitsMode = _prefs.getString(_kUnits) ?? 'auto';
    _entitlements.addAll(_prefs.getStringList(_kEnt) ?? const []);
  }

  final SharedPreferences _prefs;
  static const _kDark = 'dark';
  static const _kUnits = 'units_mode';
  static const _kEnt = 'entitlements';

  /// Entitlement único que libera tudo (sem anúncios + ferramentas Pro).
  static const String pPro = 'pro';

  final String? _country;
  bool _dark = false;
  String _unitsMode = 'auto'; // auto | metric | imperial
  final Set<String> _entitlements = {};

  /// Só para debug: força o idioma do app (para capturar prints da loja).
  Locale? debugLocale;
  void cycleDebugLocale(List<Locale> locales) {
    if (debugLocale == null) {
      debugLocale = locales.first;
    } else {
      final i = locales.indexWhere((l) => l.languageCode == debugLocale!.languageCode);
      debugLocale = locales[(i + 1) % locales.length];
    }
    notifyListeners();
  }

  bool get isDark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;

  bool get isPro => _entitlements.contains(pPro);
  bool get adsRemoved => isPro;

  String get unitsMode => _unitsMode;
  MeasureSystem get system => Units.resolve(_unitsMode, _country);
  bool get isImperial => system == MeasureSystem.imperial;

  void toggleDark() {
    _dark = !_dark;
    _prefs.setBool(_kDark, _dark);
    notifyListeners();
  }

  void setUnitsMode(String mode) {
    if (_unitsMode == mode) return;
    _unitsMode = mode;
    _prefs.setString(_kUnits, mode);
    notifyListeners();
  }

  void grantEntitlement(String id) {
    if (_entitlements.add(id)) {
      _prefs.setStringList(_kEnt, _entitlements.toList());
      notifyListeners();
    }
  }

  /// Concede Pro (usado pelas compras de assinatura e vitalícia).
  void grantPro() => grantEntitlement(pPro);
}
