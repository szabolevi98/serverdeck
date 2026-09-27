import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/demo/demo.dart';
import 'package:serverdeck/probes/services.dart';
import 'package:serverdeck/probes/stats.dart';

void main() {
  // The demo speaks the same formats as a server, so the real parsers read it.
  const server = ServerProfile(
    id: 'web-1',
    name: 'web-1',
    host: '203.0.113.10',
    username: 'deploy',
  );

  test(
    'demo stats parse, and two readings give a sensible CPU share',
    () async {
      final c = DemoConnection(server);
      final a = parseStats((await c.run(statsCommand)).stdout);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final b = parseStats((await c.run(statsCommand)).stdout);
      expect(a.hostname, 'web-1');
      expect(a.disks, hasLength(3));
      expect(b.cpuUsageSince(a), inInclusiveRange(0.05, 0.6));
      final (rx, tx) = b.networkRateSince(a);
      expect(rx, greaterThan(0));
      expect(tx, greaterThan(0));
    },
  );

  test('demo services and containers parse', () async {
    final c = DemoConnection(server);
    final services = parseServices((await c.run(servicesCommand)).stdout);
    expect(services.where((s) => s.state == ServiceState.failed), hasLength(1));
    final containers = parseContainers((await c.run(dockerCommand)).stdout);
    expect(containers, hasLength(4));
  });
}
