import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ssh/session.dart';
import 'stats.dart';

/// The readings of one server, newest last, with the rates worked out.
class StatsState {
  const StatsState({
    this.samples = const [],
    this.cpu = const [],
    this.memory = const [],
    this.rx = const [],
    this.tx = const [],
    this.error,
  });

  final List<StatsSample> samples;

  /// Per reading, 0..1: CPU busy share since the reading before, memory used.
  final List<double> cpu;
  final List<double> memory;

  /// Per reading, bytes per second.
  final List<double> rx;
  final List<double> tx;

  /// The last refresh failed; [samples] still hold what came before.
  final Object? error;

  StatsSample? get latest => samples.lastOrNull;
  bool get hasData => samples.isNotEmpty;
}

/// Refreshes every [StatsNotifier.interval] while the overview is on screen
/// and the connection is up; [StatsNotifier.history] readings are kept.
final statsProvider = NotifierProvider.autoDispose
    .family<StatsNotifier, StatsState, String>(StatsNotifier.new);

class StatsNotifier extends Notifier<StatsState> {
  StatsNotifier(this.serverId);
  final String serverId;

  static const interval = Duration(seconds: 3);
  static const history = 60;

  Timer? _timer;
  bool _active = true;
  bool _busy = false;

  @override
  StatsState build() {
    final session = ref.watch(sessionProvider(serverId));
    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();
    if (session is SessionReady) {
      _timer = Timer.periodic(interval, (_) => refresh());
      Future.microtask(refresh);
    }
    // A reconnect keeps what was read before, so the charts do not reset.
    return stateOrNull ?? const StatsState();
  }

  /// Pauses the refreshes while the overview is not shown or the app is in
  /// the background, and catches up at once when it is again.
  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (active) refresh();
  }

  Future<void> refresh() async {
    if (!_active || _busy || !ref.mounted) return;
    final session = ref.read(sessionProvider(serverId));
    if (session is! SessionReady) return;
    _busy = true;
    try {
      final result = await session.connection.run(
        statsCommand,
        timeout: const Duration(seconds: 10),
      );
      if (!ref.mounted) return;
      _add(parseStats(result.stdout));
    } catch (e) {
      if (ref.mounted) {
        state = StatsState(
          samples: state.samples,
          cpu: state.cpu,
          memory: state.memory,
          rx: state.rx,
          tx: state.tx,
          error: e,
        );
      }
    } finally {
      _busy = false;
    }
  }

  void _add(StatsSample sample) {
    final previous = state.latest;
    final (rx, tx) = previous == null
        ? (0.0, 0.0)
        : sample.networkRateSince(previous);
    List<T> push<T>(List<T> list, T value) {
      final next = [...list, value];
      return next.length > history ? next.sublist(next.length - history) : next;
    }

    state = StatsState(
      samples: push(state.samples, sample),
      cpu: push(state.cpu, sample.cpuUsageSince(previous)),
      memory: push(state.memory, sample.memUsage),
      rx: push(state.rx, rx),
      tx: push(state.tx, tx),
    );
  }
}
