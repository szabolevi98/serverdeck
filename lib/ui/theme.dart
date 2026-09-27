import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const monoFont = 'JetBrainsMono';

/// Colours with a meaning of their own: healthy, needs a look, broken, and
/// the series colours of the charts.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.ok,
    required this.warn,
    required this.bad,
    required this.idle,
    required this.cpu,
    required this.memory,
    required this.disk,
  });

  final Color ok;
  final Color warn;
  final Color bad;
  final Color idle;
  final Color cpu;
  final Color memory;
  final Color disk;

  /// Green below [warnAt], amber below [badAt], red from there.
  Color forLoad(double fraction, {double warnAt = 0.75, double badAt = 0.9}) =>
      fraction >= badAt ? bad : (fraction >= warnAt ? warn : ok);

  /// [normal] until [warnAt], then amber, then red from [badAt].
  Color tone(
    double fraction,
    Color normal, {
    double warnAt = 0.8,
    double badAt = 0.95,
  }) => fraction >= warnAt
      ? forLoad(fraction, warnAt: warnAt, badAt: badAt)
      : normal;

  @override
  StatusColors copyWith() => this;

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      ok: Color.lerp(ok, other.ok, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      idle: Color.lerp(idle, other.idle, t)!,
      cpu: Color.lerp(cpu, other.cpu, t)!,
      memory: Color.lerp(memory, other.memory, t)!,
      disk: Color.lerp(disk, other.disk, t)!,
    );
  }
}

extension ThemeLookup on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  StatusColors get status => Theme.of(this).extension<StatusColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

/// Monospaced text without ligatures, for anything a server printed.
TextStyle mono({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) => TextStyle(
  fontFamily: monoFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  fontFeatures: const [
    FontFeature.disable('calt'),
    FontFeature.disable('liga'),
  ],
);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final accent = dark ? const Color(0xFF3DDC97) : const Color(0xFF0B9A67);
  final background = dark ? const Color(0xFF151B23) : const Color(0xFFF4F6F9);
  final surface = dark ? const Color(0xFF1D2530) : const Color(0xFFFFFFFF);
  final raised = dark ? const Color(0xFF252E3A) : const Color(0xFFF0F3F7);
  final highest = dark ? const Color(0xFF2C3643) : const Color(0xFFE7ECF2);
  final outline = dark ? const Color(0xFF344152) : const Color(0xFFDCE2EA);
  final onSurface = dark ? const Color(0xFFE6EDF3) : const Color(0xFF16202B);
  final muted = dark ? const Color(0xFF98A4B3) : const Color(0xFF5E6B7A);

  final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
      .copyWith(
        primary: accent,
        onPrimary: dark ? const Color(0xFF04140D) : Colors.white,
        primaryContainer: accent.withValues(alpha: dark ? 0.16 : 0.12),
        onPrimaryContainer: accent,
        secondary: dark ? const Color(0xFF5AA9FF) : const Color(0xFF1F6FD1),
        tertiary: dark ? const Color(0xFFB794FF) : const Color(0xFF7447D6),
        error: dark ? const Color(0xFFFF6B6B) : const Color(0xFFD93636),
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: muted,
        surfaceContainerLowest: background,
        surfaceContainerLow: surface,
        surfaceContainer: raised,
        surfaceContainerHigh: highest,
        surfaceContainerHighest: highest,
        outline: outline,
        outlineVariant: outline.withValues(alpha: 0.6),
      );

  final status = dark
      ? const StatusColors(
          ok: Color(0xFF3DDC97),
          warn: Color(0xFFF5B94A),
          bad: Color(0xFFFF6B6B),
          idle: Color(0xFF5B6878),
          cpu: Color(0xFF3DDC97),
          memory: Color(0xFF5AA9FF),
          disk: Color(0xFFB794FF),
        )
      : const StatusColors(
          ok: Color(0xFF0B9A67),
          warn: Color(0xFFC98500),
          bad: Color(0xFFD93636),
          idle: Color(0xFF9AA5B1),
          cpu: Color(0xFF0B9A67),
          memory: Color(0xFF1F6FD1),
          disk: Color(0xFF7447D6),
        );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );
  final radius = BorderRadius.circular(18);

  return base.copyWith(
    scaffoldBackgroundColor: background,
    extensions: [status],
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: outline.withValues(alpha: dark ? 0.7 : 1)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: muted,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: accent.withValues(alpha: dark ? 0.18 : 0.14),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => base.textTheme.labelSmall?.copyWith(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? onSurface : muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? accent : muted,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: raised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        side: BorderSide(color: outline),
        selectedBackgroundColor: accent.withValues(alpha: dark ? 0.18 : 0.14),
        selectedForegroundColor: onSurface,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
