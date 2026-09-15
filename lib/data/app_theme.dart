import 'package:flutter/material.dart';

/// Tema do Smart Toolbox — vibrante e "tech" (índigo/roxo elétrico).
class AppTheme {
  AppTheme._();

  static const brand = Color(0xFF5B4BF5); // índigo elétrico
  static const brand2 = Color(0xFF8E54E9);
  static const accent = Color(0xFF00D4C7); // teal

  static const hero = [brand, brand2];

  static LinearGradient gradient(List<Color> colors) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF4F5FB),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF11121A),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}

/// Categoria de cor por ferramenta (deixa o grid colorido).
const List<List<Color>> kToolGradients = [
  [Color(0xFFFFB300), Color(0xFFFF6D00)], // lanterna
  [Color(0xFF00C6FB), Color(0xFF005BEA)], // bússola
  [Color(0xFF11998E), Color(0xFF38EF7D)], // régua
  [Color(0xFFF7971E), Color(0xFFFFD200)], // nível
  [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // lupa
  [Color(0xFFEE0979), Color(0xFFFF6A00)], // QR
  [Color(0xFF2193B0), Color(0xFF6DD5ED)], // conversor
  [Color(0xFF5B4BF5), Color(0xFF8E54E9)], // calculadora
  [Color(0xFFEB3349), Color(0xFFF45C43)], // cronômetro
  [Color(0xFF667EEA), Color(0xFF764BA2)], // transferidor
  [Color(0xFF11998E), Color(0xFF38EF7D)], // som
  [Color(0xFF636FA4), Color(0xFFE8CBC0)], // espelho
];
