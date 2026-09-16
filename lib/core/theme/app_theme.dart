import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color _seedColor = Color(0xFF176B87);

  // ── Light Scheme ──────────────────────────────────────────────
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  // ── Dark Scheme ───────────────────────────────────────────────
  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );

  // ── Message Bubble Colors (Light) ────────────────────────────
  static const Color sentBubbleLight = Color(0xFF176B87);
  static const Color receivedBubbleLight = Color(0xFFF0F0F0);
  static const Color sentTextLight = Colors.white;
  static const Color receivedTextLight = Color(0xFF1A1A1A);

  // ── Message Bubble Colors (Dark) ─────────────────────────────
  static const Color sentBubbleDark = Color(0xFF1B8AAA);
  static const Color receivedBubbleDark = Color(0xFF2A2A2A);
  static const Color sentTextDark = Colors.white;
  static const Color receivedTextDark = Color(0xFFE0E0E0);

  // ── Online Indicator ─────────────────────────────────────────
  static const Color onlineIndicator = Color(0xFF4CAF50);
  static const Color offlineIndicator = Color(0xFF9E9E9E);

  // ── Read Receipt Colors ──────────────────────────────────────
  static const Color readReceipt = Color(0xFF176B87);
  static const Color unreadReceipt = Color(0xFF9E9E9E);
  static const Color deliveredReceipt = Color(0xFF607D8B);

  // ── Status Colors ────────────────────────────────────────────
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // ── Unread Badge ─────────────────────────────────────────────
  static const Color unreadBadge = Color(0xFFE53935);
}

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  // ── Display ──────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ── Headline ─────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ── Title ────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ── Body ─────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ── Label ────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ── Chat-specific ────────────────────────────────────────────
  static const TextStyle messageBody = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle messageTimestamp = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.27,
  );

  static const TextStyle chatTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.38,
  );

  static const TextStyle chatSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.38,
  );

  static const TextStyle typingIndicator = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.2,
    height: 1.38,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // ── Common paddings / margins ────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.all(base);
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets verticalPadding =
      EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets listTilePadding =
      EdgeInsets.symmetric(horizontal: base, vertical: sm);
}

class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double full = 999;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll =
      BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // ── Message bubble radii ─────────────────────────────────────
  static BorderRadius sentBubble(bool isFirst, bool isLast) {
    return BorderRadius.only(
      topLeft: const Radius.circular(large),
      topRight: Radius.circular(isFirst ? large : medium),
      bottomLeft: const Radius.circular(large),
      bottomRight: Radius.circular(isLast ? large : medium),
    );
  }

  static BorderRadius receivedBubble(bool isFirst, bool isLast) {
    return BorderRadius.only(
      topLeft: Radius.circular(isFirst ? large : medium),
      topRight: const Radius.circular(large),
      bottomLeft: Radius.circular(isLast ? large : medium),
      bottomRight: const Radius.circular(large),
    );
  }
}

class AppTheme {
  AppTheme._();

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = AppColors.lightScheme;
    return _buildTheme(colorScheme);
  }

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData dark() {
    final colorScheme = AppColors.darkScheme;
    return _buildTheme(colorScheme);
  }

  // ── System Theme ─────────────────────────────────────────────
  static ThemeData system(Brightness brightness) {
    return brightness == Brightness.dark ? dark() : light();
  }

  // ── Shared Builder ───────────────────────────────────────────
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      brightness: colorScheme.brightness,

      // ── Scaffold ─────────────────────────────────────────────
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : Colors.white,

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ── Navigation Bar (Material 3) ──────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: colorScheme.onPrimaryContainer,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumAll,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.outlineVariant,
        modalBarrierColor: Colors.black54,
      ),

      // ── Input Decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),

      // ── Elevated Button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mediumAll,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smallAll,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),

      // ── Icon ─────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ─────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smallAll,
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ── Snackbar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colorScheme.inverseSurface : colorScheme.onSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? colorScheme.onInverseSurface : colorScheme.surface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smallAll,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: AppTypography.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smallAll,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Progress Indicator ───────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
