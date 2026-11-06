import 'package:flutter/material.dart';

import 'models.dart';

class Palette {
  static const bg = Color(0xFFF7F2E8);
  static const card = Color(0xFFFFFDF8);
  static const line = Color(0xFFE6DCC8);
  static const ink = Color(0xFF1E2A22);
  static const muted = Color(0xFF66705F);
  static const green = Color(0xFF1F3D2B);
  static const greenDeep = Color(0xFF142A1D);
  static const gold = Color(0xFFE9C46A);
  static const tomato = Color(0xFFB8452B);
  static const shadow = [
    BoxShadow(color: Color(0x14281E0F), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F281E0F), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const tones = <List<Color>>[
    [Color(0xFFE9C46A), Color(0xFFC98B2B)],
    [Color(0xFFD9825F), Color(0xFFB8452B)],
    [Color(0xFF8DB38A), Color(0xFF3F7A53)],
    [Color(0xFFE6A5A0), Color(0xFFB4524F)],
    [Color(0xFFA9B8C9), Color(0xFF55708F)],
  ];
}

IconData categoryIcon(String c) => switch (c) {
      'Entradas' => Icons.tapas,
      'Pizzas' => Icons.local_pizza_outlined,
      'Massas' => Icons.ramen_dining_outlined,
      'Sobremesas' => Icons.icecream_outlined,
      _ => Icons.local_drink_outlined,
    };

/// Illustrated placeholder: a gradient tile with the category icon (no stock photos).
class DishTile extends StatelessWidget {
  const DishTile({super.key, required this.dish, required this.size});
  final Dish dish;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Palette.tones[dish.tone % Palette.tones.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: c),
      ),
      child: Icon(categoryIcon(dish.category), size: size * 0.46, color: Colors.white.withValues(alpha: 0.95)),
    );
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Palette.green, brightness: Brightness.light).copyWith(
    primary: Palette.green,
    onPrimary: Colors.white,
    secondary: Palette.gold,
    surface: Palette.card,
    onSurface: Palette.ink,
    error: Palette.tomato,
  );
  const serif = 'Fraunces';
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.bg,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontFamily: serif, fontSize: 38, fontWeight: FontWeight.w600, height: 1.05, color: Palette.ink),
      headlineSmall: TextStyle(fontFamily: serif, fontSize: 24, fontWeight: FontWeight.w600, color: Palette.ink),
      titleLarge: TextStyle(fontFamily: serif, fontSize: 20, fontWeight: FontWeight.w600, color: Palette.ink),
      titleMedium: TextStyle(fontFamily: serif, fontSize: 17, fontWeight: FontWeight.w600, color: Palette.ink),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Palette.ink),
      bodyMedium: TextStyle(fontSize: 14.5, color: Palette.ink),
      bodySmall: TextStyle(fontSize: 13, color: Palette.ink),
      labelSmall: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Palette.card,
      selectedColor: Palette.gold,
      side: const BorderSide(color: Palette.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Palette.ink, fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.green,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Palette.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Palette.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Palette.green, width: 2)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    ),
  );
}
