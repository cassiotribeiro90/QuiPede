import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Membros estáticos para compatibilidade br código legado
  static const Color primaryColor = Color(0xFF3949AB);
  static const Color darkColor = Color(0xFF212121);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  static const Color greyColor = Color(0xFF9E9E9E);

  // Tema Light
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: Color(0xFF26A69A),
      tertiary: Color(0xFFFF7043),
      surface: Colors.white,
      error: Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSurface: darkColor,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    fontFamily: 'Poppins',
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkColor),
      bodyMedium: TextStyle(color: Color(0xFF757575)),
      bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
      titleLarge: TextStyle(color: darkColor),
      titleMedium: TextStyle(color: Color(0xFF757575)),
      titleSmall: TextStyle(color: Color(0xFF9E9E9E)),
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: darkColor,
      iconTheme: IconThemeData(color: darkColor),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
    ),
  );

  // Tema Dark
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5C6BC0),
      secondary: Color(0xFF4DB6AC),
      tertiary: Color(0xFFFF8A65),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Poppins',
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
      bodySmall: TextStyle(color: Color(0xFF808080)),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Color(0xFFB0B0B0)),
      titleSmall: TextStyle(color: Color(0xFF808080)),
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!),
      ),
    ),
  );
}
