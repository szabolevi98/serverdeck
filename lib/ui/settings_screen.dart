import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import 'app_lock.dart';
import 'theme_toggle.dart';
import 'theme.dart';
import 'widgets.dart';

final _deviceLockProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.read(localAuthProvider).isDeviceSupported(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final data = ref.watch(appDataProvider).value ?? const AppData();
    final supported = ref.watch(_deviceLockProvider).value ?? false;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SectionLabel(l.themeTitle),
          SegmentedButton<ThemeMode>(
            segments: [
              for (final mode in [
                ThemeMode.system,
                ThemeMode.light,
                ThemeMode.dark,
              ])
                ButtonSegment(
                  value: mode,
                  icon: Icon(ThemeModeButton.iconFor(mode)),
                  label: Text(ThemeModeButton.labelFor(context, mode)),
                ),
            ],
            selected: {data.settings.themeMode},
            onSelectionChanged: (s) => ref
                .read(appDataProvider.notifier)
                .updateSettings(data.settings.copyWith(themeMode: s.first)),
          ),
          SectionLabel(l.settingsSecurity),
          Card(
            child: SwitchListTile(
              secondary: const TintedIcon(Icons.fingerprint_rounded, size: 40),
              title: Text(l.settingsLock),
              subtitle: Text(
                supported ? l.settingsLockHint : l.settingsLockUnsupported,
              ),
              value: data.settings.appLock,
              onChanged: !supported
                  ? null
                  : (on) async {
                      // Turning it on or off both take the device lock, so
                      // someone holding an unlocked phone cannot switch it off.
                      final ok = await unlockWithDevice(ref, l.lockReason);
                      if (!ok) return;
                      await ref
                          .read(appDataProvider.notifier)
                          .updateSettings(data.settings.copyWith(appLock: on));
                    },
            ),
          ),
          SectionLabel(l.settingsKnownHosts),
          if (data.knownHosts.isEmpty)
            Text(
              l.settingsKnownHostsEmpty,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final (i, h) in data.knownHosts.indexed) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    _KnownHostTile(
                      host: h,
                      servers: data.servers
                          .where((s) => s.hostKeyId == h.host)
                          .map((s) => s.name)
                          .toList(),
                      added: DateFormat.yMMMd(locale).format(h.added),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            l.settingsKnownHostsHint,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SectionLabel(l.settingsAbout),
          Card(
            child: ListTile(
              leading: const TintedIcon(Icons.dns_rounded, size: 40),
              title: const Text('ServerDeck 1.0.0'),
              subtitle: Text(l.settingsAboutText),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnownHostTile extends ConsumerWidget {
  const _KnownHostTile({
    required this.host,
    required this.servers,
    required this.added,
  });

  final KnownHost host;
  final List<String> servers;
  final String added;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(host.host, style: mono(size: 13.5, weight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                host.fingerprint,
                style: mono(size: 11, color: context.colors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                [host.type, added, ...servers].join(' · '),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l.hostKeyForget,
          icon: Icon(Icons.delete_outline_rounded, color: context.colors.error),
          onPressed: () async {
            final ok = await confirm(
              context,
              title: context.l.hostKeyForgetTitle,
              message: context.l.hostKeyForgetMessage,
              action: context.l.hostKeyForget,
              destructive: true,
            );
            if (ok) {
              await ref.read(appDataProvider.notifier).forgetHost(host.host);
            }
          },
        ),
      ],
    ),
  );
}
