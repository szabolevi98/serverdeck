import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';

import '../ssh/connection.dart';
import '../ssh/session.dart';
import 'theme.dart';
import 'widgets.dart';

/// Graphite and mint, like the rest of the app, in both themes: terminal
/// colours are written for a dark background.
const _terminalTheme = TerminalTheme(
  cursor: Color(0xFF3DDC97),
  selection: Color(0x663DDC97),
  foreground: Color(0xFFE6EDF3),
  background: Color(0xFF10151C),
  black: Color(0xFF1D2530),
  red: Color(0xFFFF6B6B),
  green: Color(0xFF3DDC97),
  yellow: Color(0xFFF5B94A),
  blue: Color(0xFF5AA9FF),
  magenta: Color(0xFFB794FF),
  cyan: Color(0xFF4FD6D6),
  white: Color(0xFFD5DDE5),
  brightBlack: Color(0xFF6B7888),
  brightRed: Color(0xFFFF8A8A),
  brightGreen: Color(0xFF6BE8B1),
  brightYellow: Color(0xFFFFD27A),
  brightBlue: Color(0xFF8CC4FF),
  brightMagenta: Color(0xFFCFB5FF),
  brightCyan: Color(0xFF85E6E6),
  brightWhite: Color(0xFFFFFFFF),
  searchHitBackground: Color(0xFFF5B94A),
  searchHitBackgroundCurrent: Color(0xFF3DDC97),
  searchHitForeground: Color(0xFF10151C),
);

/// A shell on the server, on a pseudo-terminal, kept open while the server
/// screen is.
class TerminalTab extends ConsumerStatefulWidget {
  const TerminalTab({super.key, required this.serverId});
  final String serverId;

  @override
  ConsumerState<TerminalTab> createState() => _TerminalTabState();
}

class _TerminalTabState extends ConsumerState<TerminalTab> {
  late final Terminal _terminal = Terminal(
    maxLines: 5000,
    onOutput: _send,
    onResize: (w, h, pw, ph) => _shell?.resize(w, h, pw, ph),
  );
  final _controller = TerminalController();
  final _focus = FocusNode();
  ShellChannel? _shell;
  final _subscriptions = <StreamSubscription<Uint8List>>[];
  bool _closed = false;
  bool _ctrl = false;
  double _fontSize = 11.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    _close();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    _close();
    final session = ref.read(sessionProvider(widget.serverId));
    if (session is! SessionReady) return;
    setState(() => _closed = false);
    try {
      final shell = await session.connection.shell(
        columns: _terminal.viewWidth,
        rows: _terminal.viewHeight,
      );
      if (!mounted) {
        shell.close();
        return;
      }
      _shell = shell;
      final sink = const Utf8Decoder(allowMalformed: true)
          .startChunkedConversion(_TerminalSink(_terminal.write));
      _subscriptions.add(
        shell.output.listen(sink.add, onDone: sink.close, onError: (_) {}),
      );
      unawaited(
        shell.done.whenComplete(() {
          if (!mounted || !identical(_shell, shell)) return;
          _terminal.write('\r\n\x1b[2m${context.l.terminalClosed}\x1b[0m\r\n');
          setState(() => _closed = true);
        }),
      );
      _focus.requestFocus();
    } catch (e) {
      _terminal.write('\r\n\x1b[31m$e\x1b[0m\r\n');
      if (mounted) setState(() => _closed = true);
    }
  }

  void _close() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _shell?.close();
    _shell = null;
  }

  /// Keystrokes on their way to the server. With the sticky Ctrl on, a letter
  /// becomes its control character: c is ^C.
  void _send(String data) {
    var out = data;
    if (_ctrl && data.length == 1) {
      final code = data.toLowerCase().codeUnitAt(0);
      if (code >= 0x61 && code <= 0x7a) out = String.fromCharCode(code - 0x60);
      if (data == '[') out = '\x1b';
      if (data == '\\') out = '\x1c';
      setState(() => _ctrl = false);
    }
    _shell?.write(Uint8List.fromList(utf8.encode(out)));
  }

  void _key(TerminalKey key) {
    _terminal.keyInput(key);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: BoxDecoration(
              color: _terminalTheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                TerminalView(
                  _terminal,
                  controller: _controller,
                  focusNode: _focus,
                  theme: _terminalTheme,
                  padding: const EdgeInsets.all(10),
                  textStyle: TerminalStyle(
                    fontFamily: monoFont,
                    fontSize: _fontSize,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  deleteDetection: true,
                  cursorType: TerminalCursorType.block,
                ),
                if (_closed)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                      ),
                      onPressed: _open,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(context.l.terminalReopen),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _KeyBar(
          ctrl: _ctrl,
          onCtrl: () => setState(() => _ctrl = !_ctrl),
          onKey: _key,
          onText: (t) {
            _send(t);
            HapticFeedback.selectionClick();
          },
          onZoom: (delta) =>
              setState(() => _fontSize = (_fontSize + delta).clamp(8.0, 22.0)),
          onPaste: () async {
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            final text = data?.text;
            if (text != null && text.isNotEmpty) _terminal.paste(text);
          },
        ),
      ],
    );
  }
}

/// Feeds decoded text into the terminal as it arrives.
class _TerminalSink implements Sink<String> {
  _TerminalSink(this._write);
  final void Function(String) _write;

  @override
  void add(String data) => _write(data);

  @override
  void close() {}
}

/// The keys a phone keyboard does not have.
class _KeyBar extends StatelessWidget {
  const _KeyBar({
    required this.ctrl,
    required this.onCtrl,
    required this.onKey,
    required this.onText,
    required this.onZoom,
    required this.onPaste,
  });

  final bool ctrl;
  final VoidCallback onCtrl;
  final void Function(TerminalKey) onKey;
  final void Function(String) onText;
  final void Function(double) onZoom;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback onTap, {bool active = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Material(
            color: active
                ? context.colors.primary
                : context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minWidth: 44),
                height: 40,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  label,
                  style: mono(
                    size: 13,
                    weight: FontWeight.w600,
                    color: active
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 12),
        children: [
          key('esc', () => onKey(TerminalKey.escape)),
          key('tab', () => onKey(TerminalKey.tab)),
          key('ctrl', onCtrl, active: ctrl),
          key('←', () => onKey(TerminalKey.arrowLeft)),
          key('↑', () => onKey(TerminalKey.arrowUp)),
          key('↓', () => onKey(TerminalKey.arrowDown)),
          key('→', () => onKey(TerminalKey.arrowRight)),
          key('|', () => onText('|')),
          key('/', () => onText('/')),
          key('-', () => onText('-')),
          key('~', () => onText('~')),
          key('home', () => onKey(TerminalKey.home)),
          key('end', () => onKey(TerminalKey.end)),
          key('pgup', () => onKey(TerminalKey.pageUp)),
          key('pgdn', () => onKey(TerminalKey.pageDown)),
          key('A−', () => onZoom(-1)),
          key('A+', () => onZoom(1)),
          key(context.l.paste, onPaste),
        ],
      ),
    );
  }
}
