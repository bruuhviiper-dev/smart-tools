/// Sistema de medidas regional (métrico × imperial).
///
/// A região decide as unidades padrão: EUA/Libéria/Mianmar usam imperial
/// (°F, pés, milhas, libras); o resto do mundo usa métrico (°C, m, km, kg).
/// O usuário pode forçar um dos dois nos Ajustes ("auto" segue a região).
enum MeasureSystem { metric, imperial }

class Units {
  const Units._();

  /// Países que usam imperial por padrão.
  static const _imperialCountries = {'US', 'LR', 'MM'};

  /// Deriva o sistema a partir do modo salvo e do país do aparelho.
  /// [mode] = 'auto' | 'metric' | 'imperial'.
  static MeasureSystem resolve(String mode, String? country) {
    switch (mode) {
      case 'metric':
        return MeasureSystem.metric;
      case 'imperial':
        return MeasureSystem.imperial;
      default:
        final c = (country ?? '').toUpperCase();
        return _imperialCountries.contains(c)
            ? MeasureSystem.imperial
            : MeasureSystem.metric;
    }
  }

  static bool isImperial(MeasureSystem s) => s == MeasureSystem.imperial;

  // ---- Comprimento (base: metros) ----
  /// Régua: unidade curta preferida (cm × in).
  static String smallLenUnit(MeasureSystem s) => isImperial(s) ? 'in' : 'cm';
  static double metersToSmall(MeasureSystem s, double m) =>
      isImperial(s) ? m / 0.0254 : m * 100;

  // ---- Temperatura (base: Celsius) ----
  static String tempUnit(MeasureSystem s) => isImperial(s) ? '°F' : '°C';
  static double celsiusTo(MeasureSystem s, double c) =>
      isImperial(s) ? c * 9 / 5 + 32 : c;

  // ---- Velocidade (base: km/h) ----
  static String speedUnit(MeasureSystem s) => isImperial(s) ? 'mph' : 'km/h';
  static double kmhTo(MeasureSystem s, double kmh) =>
      isImperial(s) ? kmh / 1.60934 : kmh;

  // ---- Conversor: unidades padrão por categoria e sistema ----
  /// Retorna [from, to] iniciais para cada categoria conforme a região.
  static List<String> converterDefaults(String category, MeasureSystem s) {
    final imp = isImperial(s);
    switch (category) {
      case 'Length':
        return imp ? ['ft', 'in'] : ['m', 'cm'];
      case 'Weight':
        return imp ? ['lb', 'oz'] : ['kg', 'g'];
      case 'Temperature':
        return imp ? ['°C', '°F'] : ['°F', '°C'];
      case 'Speed':
        return imp ? ['mph', 'km/h'] : ['km/h', 'mph'];
      case 'Area':
        return imp ? ['ft²', 'm²'] : ['m²', 'ft²'];
      case 'Volume':
        return imp ? ['gal', 'L'] : ['L', 'mL'];
      default:
        return const [];
    }
  }
}
