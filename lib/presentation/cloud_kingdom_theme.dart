import 'package:flutter/material.dart';

abstract final class CloudKingdomColors {
  static const cloudstone = Color(0xff211d3a);
  static const deepCloud = Color(0xff15162b);
  static const cloudglass = Color(0xff3b526e);
  static const brass = Color(0xffffd36e);
  static const enchantedGreen = Color(0xff75d6a2);
  static const softText = Color(0xffe8e8f4);
}

ThemeData buildCloudKingdomTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: CloudKingdomColors.cloudstone,
    brightness: Brightness.dark,
    primary: CloudKingdomColors.enchantedGreen,
    secondary: CloudKingdomColors.brass,
    surface: CloudKingdomColors.cloudstone,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: CloudKingdomColors.deepCloud,
    cardTheme: CardThemeData(
      color: CloudKingdomColors.cloudstone,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xff544d74), width: .8),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CloudKingdomColors.deepCloud,
      foregroundColor: CloudKingdomColors.softText,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: CloudKingdomColors.brass),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: CloudKingdomColors.cloudglass,
      side: const BorderSide(color: Color(0xff796d99)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    focusColor: CloudKingdomColors.brass.withValues(alpha: .28),
    textTheme: base.textTheme.apply(
      bodyColor: CloudKingdomColors.softText,
      displayColor: CloudKingdomColors.softText,
    ),
  );
}
