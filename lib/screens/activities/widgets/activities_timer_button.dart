import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';

enum MockTimerSignal { start, stop }

class MockActivitiesTimer {
  bool isRunning = false;
  MockTimerSignal? lastSignal;

  void receive(MockTimerSignal signal) {
    lastSignal = signal;
    isRunning = signal == MockTimerSignal.start;
  }
}

class ActivitiesTimerButton extends StatefulWidget {
  const ActivitiesTimerButton({super.key, required this.timer});

  static const toggleButtonKey = Key('activities_start_session');

  final MockActivitiesTimer timer;

  @override
  State<ActivitiesTimerButton> createState() => _ActivitiesTimerButtonState();
}

class _ActivitiesTimerButtonState extends State<ActivitiesTimerButton> {
  void _sendSignal() {
    final signal = widget.timer.isRunning
        ? MockTimerSignal.stop
        : MockTimerSignal.start;
    widget.timer.receive(signal);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.timer.isRunning;
    final actionLabel = isRunning ? 'Stop timer' : 'Start timer';

    return Tooltip(
      message: actionLabel,
      child: Semantics(
        label: actionLabel,
        button: true,
        child: SizedBox(
          width: 112,
          height: 112,
          child: FilledButton(
            key: ActivitiesTimerButton.toggleButtonKey,
            onPressed: _sendSignal,
            style: FilledButton.styleFrom(
              backgroundColor: appMossColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              elevation: 8,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isRunning),
                size: 52,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
