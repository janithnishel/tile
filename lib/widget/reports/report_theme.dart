// // lib/theme/report_theme.dart

// import 'package:flutter/material.dart';

// class ReportTheme {
//   // Primary Colors
//   static const Color primaryColor = Color(0xFF7B1FA2); // Purple 700
//   static const Color primaryLight = Color(0xFF9C27B0); // Purple 500
//   static const Color primaryDark = Color(0xFF4A148C); // Purple 900
  
//   // Secondary Colors
//   static const Color secondaryColor = Color(0xFFF57C00); // Orange 700
//   static const Color secondaryLight = Color(0xFFFF9800); // Orange 500
  
//   // Status Colors
//   static const Color successColor = Color(0xFF2E7D32); // Green 800
//   static const Color successLight = Color(0xFF4CAF50); // Green 500
//   static const Color errorColor = Color(0xFFC62828); // Red 800
//   static const Color errorLight = Color(0xFFEF5350); // Red 400
//   static const Color warningColor = Color(0xFFF9A825); // Yellow 800
//   static const Color infoColor = Color(0xFF1565C0); // Blue 800
  
//   // Neutral Colors
//   static const Color backgroundColor = Color(0xFFF5F5F5);
//   static const Color cardBackground = Colors.white;
//   static const Color dividerColor = Color(0xFFE0E0E0);
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color textSecondary = Color(0xFF757575);
//   static const Color textHint = Color(0xFFBDBDBD);

//   // Gradients
//   static LinearGradient get primaryGradient => LinearGradient(
//     colors: [primaryColor, primaryLight],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static LinearGradient get successGradient => LinearGradient(
//     colors: [successColor, successLight],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static LinearGradient get errorGradient => LinearGradient(
//     colors: [errorColor, errorLight],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static LinearGradient get warningGradient => LinearGradient(
//     colors: [warningColor, Color(0xFFFFCA28)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static LinearGradient get infoGradient => LinearGradient(
//     colors: [infoColor, Color(0xFF42A5F5)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   // Card Decoration
//   static BoxDecoration get cardDecoration => BoxDecoration(
//     color: cardBackground,
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.05),
//         blurRadius: 10,
//         offset: const Offset(0, 4),
//       ),
//     ],
//   );

//   // Text Styles
//   static TextStyle get headingLarge => const TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: textPrimary,
//   );

//   static TextStyle get headingMedium => const TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.bold,
//     color: textPrimary,
//   );

//   static TextStyle get headingSmall => const TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: textPrimary,
//   );

//   static TextStyle get bodyLarge => const TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.normal,
//     color: textPrimary,
//   );

//   static TextStyle get bodyMedium => const TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.normal,
//     color: textPrimary,
//   );

//   static TextStyle get caption => const TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.normal,
//     color: textSecondary,
//   );

//   static TextStyle get cardValue => const TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.bold,
//     color: Colors.white,
//   );

//   static TextStyle get cardLabel => TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     color: Colors.white.withOpacity(0.9),
//   );

//   // Input Decoration
//   static InputDecoration searchInputDecoration({
//     required String hintText,
//     Widget? prefixIcon,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: TextStyle(color: textHint),
//       prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: dividerColor),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: dividerColor),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: primaryColor, width: 2),
//       ),
//     );
//   }

//   // Tab Bar Theme
//   static TabBarTheme get tabBarTheme => TabBarTheme(
//     labelColor: primaryColor,
//     unselectedLabelColor: Colors.white,
//     labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//     unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//   );
// }



// lib/theme/report_theme.dart - Updated with Yellow colors

import 'package:flutter/material.dart';

class ReportTheme {
  // Primary Colors - Purple
  static const Color primaryColor = Color(0xFF7B1FA2); // Purple 700
  static const Color primaryLight = Color(0xFF9C27B0); // Purple 500
  static const Color primaryDark = Color(0xFF4A148C); // Purple 900
  
  // Accent Colors - Yellow/Amber
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color accentLight = Color(0xFFFFD54F); // Amber 300
  static const Color accentDark = Color(0xFFF57F17); // Yellow 900
  static const Color accentBackground = Color(0xFFFFF8E1); // Amber 50
  
  // Secondary Colors - Orange (keeping for compatibility)
  static const Color secondaryColor = Color(0xFFF57C00); // Orange 700
  static const Color secondaryLight = Color(0xFFFF9800); // Orange 500
  
  // Status Colors
  static const Color successColor = Color(0xFF2E7D32); // Green 800
  static const Color successLight = Color(0xFF4CAF50); // Green 500
  static const Color errorColor = Color(0xFFC62828); // Red 800
  static const Color errorLight = Color(0xFFEF5350); // Red 400
  static const Color warningColor = Color(0xFFF9A825); // Yellow 800
  static const Color infoColor = Color(0xFF1565C0); // Blue 800
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get primaryAccentGradient => const LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [successColor, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get errorGradient => const LinearGradient(
    colors: [errorColor, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warningGradient => LinearGradient(
    colors: [warningColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get infoGradient => const LinearGradient(
    colors: [infoColor, Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Accent Card Decoration (Yellow border)
  static BoxDecoration get accentCardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accentLight.withOpacity(0.5), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Text Styles
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static TextStyle get cardValue => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get cardLabel => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.9),
  );

  // Date Picker Theme
  static DatePickerThemeData get datePickerTheme => DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: primaryColor,
    headerForegroundColor: Colors.white,
    weekdayStyle: TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.bold,
    ),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor;
      }
      return null;
    }),
    todayBorder: const BorderSide(color: accentColor, width: 2),
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return accentColor;
    }),
    rangeSelectionBackgroundColor: accentBackground,
    rangePickerHeaderBackgroundColor: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}