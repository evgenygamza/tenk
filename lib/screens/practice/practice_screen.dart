import 'dart:async';

import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.activityName});

  static const screenKey = Key('practice_screen');
  static const timerKey = Key('practice_timer');
  static const toggleButtonKey = Key('practice_toggle_button');

  final String activityName;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  Timer? _ticker;
  var _elapsed = Duration.zero;
  var _isRunning = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _ticker?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  String _formatElapsed() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: PracticeScreen.screenKey,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Занятие', style: textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(widget.activityName, style: textTheme.headlineLarge),
                  const SizedBox(height: 48),
                  Text(
                    _isRunning ? 'Время идёт' : 'Готово к началу',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatElapsed(),
                    key: PracticeScreen.timerKey,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(fontSize: 48),
                  ),
                  const SizedBox(height: 48),
                  FilledButton.icon(
                    key: PracticeScreen.toggleButtonKey,
                    onPressed: _toggleTimer,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(_isRunning ? 'Поставить на паузу' : 'Начать'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Пока таймер работает только на этом экране. '
                    'Сохранение результата появится позже.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
