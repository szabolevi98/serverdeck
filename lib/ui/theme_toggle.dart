import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import 'widgets.dart';

/// Steps through the phone's theme, light and dark, one tap at a time.
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  static IconData iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_rounded,
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
  };

  static String labelFor(BuildContext context, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.system => context.l.themeSystem,
        ThemeMode.light => context.l.themeLight,
        ThemeMode.dark => context.l.themeDark,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appDataProvider).value?.settings;
    final mode = settings?.themeMode ?? ThemeMode.system;
    final next = switch (mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    return IconButton(
      tooltip: '${context.l.themeTitle}: ${labelFor(context, mode)}',
      onPressed: settings == null
          ? null
          : () {
              ref
                  .read(appDataProvider.notifier)
                  .updateSettings(settings.copyWith(themeMode: next));
              showMessage(
                context,
                '${context.l.themeTitle}: ${labelFor(context, next)}',
              );
            },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(iconFor(mode), key: ValueKey(mode)),
      ),
    );
  }
}
