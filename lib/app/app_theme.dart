import 'package:flutter/material.dart';

const appCanvasColor = Color(0xFFF4EFE3);
const appMossColor = Color(0xFF243F2A);
const appInkColor = Color(0xFF243F2A);
const appTranslucentPanelColor = Color(0x73FFFFFF);
const appPanelBorderColor = Color(0x80FFFFFF);
const appPanelTileColor = Color(0x33FFFFFF);
const appPanelSelectedTileColor = Color(0x9E9DCF7E);
const appPanelFieldColor = Color(0x7AFFFFFF);
const appPanelControlBorderColor = Color(0x73FFFFFF);
const appContextMenuColor = Color(0xDBFFFFFF);
const appContextMenuBorderColor = Color(0xCCFFFFFF);
const appContextMenuShadowColor = Color(0x55243F2A);
const appDestructiveActionColor = Color(0xFF98584D);
const appPanelRadius = 28.0;
const appContextMenuRadius = 18.0;
const appPanelBlurSigma = 16.0;

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
