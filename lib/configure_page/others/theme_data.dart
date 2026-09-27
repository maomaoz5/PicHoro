import 'package:flutter/material.dart';

const int lightPrimaryValue = 0xFF4596EB;
const int darkPrimaryValue = 0xFF111213;
const int greenPrimaryValue = 0xFF4CAF50;
const int purplePrimaryValue = 0xFF673AB7;
const int orangePrimaryValue = 0xFFFF9800;
const int pinkPrimaryValue = 0xFFE91E63;
const int cyanPrimaryValue = 0xFF00BCD4;
const int goldPrimaryValue = 0xFFFFC107;
const int redPrimaryValue = 0xFFF44336;
const int bluePrimaryValue = 0xFF2196F3;
const int tealPrimaryValue = 0xFF009688;
const int indigoPrimaryValue = 0xFF3F51B5;
const int limePrimaryValue = 0xFFCDDC39;
const int amberPrimaryValue = 0xFFFFAB00;
const int brownPrimaryValue = 0xFF795548;
const int greyPrimaryValue = 0xFF9E9E9E;
const int blueGreyPrimaryValue = 0xFF607D8B;

class AppThemeData {
  final String name;
  final int primaryValue;
  final Brightness brightness;

  const AppThemeData({
    required this.name,
    required this.primaryValue,
    this.brightness = Brightness.light,
  });
}

final List<AppThemeData> availableThemes = [
  const AppThemeData(name: 'Light', primaryValue: lightPrimaryValue),
  const AppThemeData(name: 'Dark', primaryValue: darkPrimaryValue, brightness: Brightness.dark),
  const AppThemeData(name: 'Green', primaryValue: greenPrimaryValue),
  const AppThemeData(name: 'Purple', primaryValue: purplePrimaryValue),
  const AppThemeData(name: 'Orange', primaryValue: orangePrimaryValue),
  const AppThemeData(name: 'Pink', primaryValue: pinkPrimaryValue),
  const AppThemeData(name: 'Cyan', primaryValue: cyanPrimaryValue),
  const AppThemeData(name: 'Gold', primaryValue: goldPrimaryValue),
  const AppThemeData(name: 'Red', primaryValue: redPrimaryValue),
  const AppThemeData(name: 'Blue', primaryValue: bluePrimaryValue),
  const AppThemeData(name: 'Teal', primaryValue: tealPrimaryValue),
  const AppThemeData(name: 'Indigo', primaryValue: indigoPrimaryValue),
  const AppThemeData(name: 'Lime', primaryValue: limePrimaryValue),
  const AppThemeData(name: 'Amber', primaryValue: amberPrimaryValue),
  const AppThemeData(name: 'Brown', primaryValue: brownPrimaryValue),
  const AppThemeData(name: 'Grey', primaryValue: greyPrimaryValue),
  const AppThemeData(name: 'Blue Grey', primaryValue: blueGreyPrimaryValue),
];

ThemeData generateThemeData(AppThemeData themeData) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Color(themeData.primaryValue),
    brightness: themeData.brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'SystemFont',
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.primary.withValues(alpha: 0.03),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconColor: colorScheme.primary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: colorScheme.secondaryContainer,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface);
        }
        return TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.primary, size: 24);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ),
    dividerTheme: DividerThemeData(
      thickness: 0.5,
      indent: 56,
      color: colorScheme.outlineVariant,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.surfaceContainerHighest;
      }),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      bodySmall: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
    ),
  );
}

final ThemeData lightThemeData = generateThemeData(availableThemes[0]);
final ThemeData darkThemeData = generateThemeData(availableThemes[1]);
final ThemeData greenThemeData = generateThemeData(availableThemes[2]);
final ThemeData purpleThemeData = generateThemeData(availableThemes[3]);
final ThemeData orangeThemeData = generateThemeData(availableThemes[4]);
final ThemeData pinkThemeData = generateThemeData(availableThemes[5]);
final ThemeData cyanThemeData = generateThemeData(availableThemes[6]);
final ThemeData goldThemeData = generateThemeData(availableThemes[7]);
final ThemeData redThemeData = generateThemeData(availableThemes[8]);
final ThemeData blueThemeData = generateThemeData(availableThemes[9]);
final ThemeData tealThemeData = generateThemeData(availableThemes[10]);
final ThemeData indigoThemeData = generateThemeData(availableThemes[11]);
final ThemeData limeThemeData = generateThemeData(availableThemes[12]);
final ThemeData amberThemeData = generateThemeData(availableThemes[13]);
final ThemeData brownThemeData = generateThemeData(availableThemes[14]);
final ThemeData greyThemeData = generateThemeData(availableThemes[15]);
final ThemeData blueGreyThemeData = generateThemeData(availableThemes[16]);
