import 'package:flutter/material.dart';

const appCanvasColor = Color(0xFFF4EFE3);
const appMossColor = Color(0xFF536A49);
const appInkColor = Color(0xFF273128);

ThemeData buildAppTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: appMossColor,
        brightness: Brightness.light,
        surface: appCanvasColor,
      ).copyWith(
        primary: appMossColor,
        onPrimary: const Color(0xFFFFFCF5),
        onSurface: appInkColor,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appCanvasColor,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: appInkColor,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -1.2,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF5D665D),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
