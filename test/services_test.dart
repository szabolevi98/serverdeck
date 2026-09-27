import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/probes/services.dart';

void main() {
  final ubuntu = File('test/fixtures/systemctl_ubuntu.txt').readAsStringSync();

  test('reads the services of an Ubuntu server', () {
    final services = parseServices(ubuntu);
    // auditd is not-found: a name, not a service.
    expect(services.map((s) => s.name), isNot(contains('auditd')));
    expect(services, hasLength(11));

    final apache = services.firstWhere((s) => s.name == 'apache2');
    expect(apache.state, ServiceState.running);
    expect(apache.description, 'The Apache HTTP Server');
    expect(apache.isEnabled, isTrue);

    final cloud = services.firstWhere((s) => s.name == 'cloud-init');
    expect(cloud.state, ServiceState.failed);

    expect(
      services.firstWhere((s) => s.name == 'ufw').state,
      ServiceState.exited,
    );
    expect(
      services.firstWhere((s) => s.name == 'apt-daily').state,
      ServiceState.inactive,
    );
    expect(services.firstWhere((s) => s.name == 'ssh').enabled, 'disabled');
    // An instance takes its template's file state.
    expect(services.firstWhere((s) => s.name == 'user@0').enabled, 'static');
  });

  test('a bullet in front of a failed unit is not part of its name', () {
    final s = parseServices(
      '● nginx.service loaded failed failed A high performance web server\n',
    );
    expect(s.single.unit, 'nginx.service');
    expect(s.single.state, ServiceState.failed);
    expect(s.single.enabled, isNull);
  });

  test('commands quote the unit and use sudo -n unless root', () {
    const s = Service(
      unit: "odd'name.service",
      active: 'active',
      sub: 'running',
      description: '',
    );
    expect(
      serviceActionCommand(s, ServiceAction.restart, root: true),
      r"systemctl restart 'odd'\''name.service'",
    );
    expect(
      serviceActionCommand(s, ServiceAction.stop, root: false),
      r"sudo -n systemctl stop 'odd'\''name.service'",
    );
    expect(shellQuote(r'a $(rm -rf /) `b`'), r"'a $(rm -rf /) `b`'");
  });

  test('reads docker ps JSON lines, and tells no Docker from no containers', () {
    const out =
        'DOCKER\n'
        '{"Command":"\\"docker-entrypoint.s…\\"","CreatedAt":"2026-09-01 10:00:00 +0200 CEST","ID":"4f1c2b9a7e3d5c6b8a9f0e1d2c3b4a5f","Image":"postgres:16","Labels":"","LocalVolumes":"1","Mounts":"pgdata","Names":"db","Networks":"app","Ports":"5432/tcp","RunningFor":"3 weeks ago","Size":"63B","State":"running","Status":"Up 3 weeks (healthy)"}\n'
        '{"ID":"aa11bb22cc33dd44","Image":"nginx:1.27","Names":"web,web-alias","Ports":"0.0.0.0:80->80/tcp","State":"exited","Status":"Exited (0) 2 days ago"}\n'
        '{"ID":"ee55","Image":"worker","Names":"worker","Ports":"","State":"running","Status":"Up 5 minutes (unhealthy)"}\n';
    final c = parseContainers(out)!;
    expect(c.map((x) => x.name), ['db', 'web', 'worker']);
    expect(c[0].id, '4f1c2b9a7e3d');
    expect(c[0].state, ContainerState.running);
    expect(c[0].unhealthy, isFalse);
    expect(c[1].state, ContainerState.exited);
    expect(c[2].unhealthy, isTrue);

    expect(parseContainers('NODOCKER\n'), isNull);
    expect(parseContainers('DOCKER\n'), isEmpty);
  });
}
