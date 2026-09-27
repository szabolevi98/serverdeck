import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../ssh/reach.dart';
import 'keys_screen.dart';
import 'server_edit_screen.dart';
import 'server_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// A knock on each server's SSH port. Kept for the whole run and redone only
/// on pull to refresh: fail2ban in its stricter modes counts connections
/// closed before signing in, and coming back to the list must not add up.
final reachabilityProvider = FutureProvider.family<Reachability, (String, int)>(
  (ref, target) => knock(target.$1, target.$2),
);

class ServersScreen extends ConsumerWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider);
    final servers = data.value?.servers ?? const <ServerProfile>[];

    return Scaffold(
      body: RefreshIndicator(
        edgeOffset: 120,
        onRefresh: () async {
          ref.invalidate(reachabilityProvider);
          await Future.wait([
            for (final s in servers)
              ref.read(reachabilityProvider((s.host, s.port)).future),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: Text(context.l.serversTitle),
              actions: [
                IconButton(
                  tooltip: context.l.keysTitle,
                  icon: const Icon(Icons.key_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KeysScreen()),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (data.isLoading && !data.hasValue)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (servers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.dns_rounded,
                  title: context.l.serversEmptyTitle,
                  message: context.l.serversEmpty,
                  action: FilledButton.icon(
                    onPressed: () => _edit(context, null),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.l.serverAdd),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                sliver: SliverList.separated(
                  itemCount: servers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _ServerCard(
                    server: servers[i],
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServerScreen(serverId: servers[i].id),
                      ),
                    ),
                    onEdit: () => _edit(context, servers[i]),
                    onDelete: () => _delete(context, ref, servers[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: servers.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l.serverAdd),
            ),
    );
  }

  void _edit(BuildContext context, ServerProfile? server) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ServerEditScreen(server: server)),
  );

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ServerProfile server,
  ) async {
    final ok = await confirm(
      context,
      title: context.l.serverDeleteTitle(server.name),
      message: context.l.serverDeleteMessage,
      action: context.l.delete,
      destructive: true,
    );
    if (ok) await ref.read(appDataProvider.notifier).deleteServer(server.id);
  }
}

class _ServerCard extends ConsumerWidget {
  const _ServerCard({
    required this.server,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ServerProfile server;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reach = ref.watch(reachabilityProvider((server.host, server.port)));
    final status = context.status;

    final (Color color, String label, bool pulse) = switch (reach) {
      AsyncData(:final value) when value.isUp => (
        status.ok,
        '${value.latency!.inMilliseconds} ms',
        false,
      ),
      AsyncData() => (status.bad, context.l.statusDown, false),
      AsyncError() => (status.bad, context.l.statusDown, false),
      _ => (status.idle, context.l.statusChecking, true),
    };
    final software = describeBanner(reach.value?.banner);

    return Card(
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Row(
            children: [
              _Monogram(name: server.name, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: context.text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      server.address,
                      style: mono(
                        size: 12.5,
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (software != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        software,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: label, color: color, pulse: pulse),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: Text(context.l.edit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: context.colors.error,
                      ),
                      title: Text(
                        context.l.delete,
                        style: TextStyle(color: context.colors.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The first letters of the server's name, on a square tinted by its state.
class _Monogram extends StatelessWidget {
  const _Monogram({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'[\s.\-_]+'));
    final letters = words.length > 1
        ? '${words[0].characters.firstOrNull ?? ''}${words[1].characters.firstOrNull ?? ''}'
        : name.trim().characters.take(2).toString();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        letters.toUpperCase(),
        style: mono(size: 16, weight: FontWeight.w700, color: color),
      ),
    );
  }
}
