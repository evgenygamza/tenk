import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/session_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TenK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today: ${c.totalMinutesToday} min',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All time: ${c.totalMinutesAllTime} min',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddManualScreen(),
                    ),
                  );
                },
                child: const Text('Add manually'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.read<SessionsController>().addManual(15);
                },
                child: const Text('+15 min'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.read<SessionsController>().resetAll();
                },
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SessionList(entries: c.entries),
            ),
          ],
        ),
      ),
    );
  }
}
