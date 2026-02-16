import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';

class AddManualScreen extends StatefulWidget {
  const AddManualScreen({super.key});

  @override
  State<AddManualScreen> createState() => _AddManualScreenState();
}

class _AddManualScreenState extends State<AddManualScreen> {
  final _minutesController = TextEditingController();
  final _noteController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _minutesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _minutesController.text.trim();
    final minutes = int.tryParse(raw);

    if (minutes == null || minutes <= 0) {
      setState(() => _errorText = 'Enter a positive number');
      return;
    }

    final note = _noteController.text.trim();
    await context.read<SessionsController>().addManual(
      minutes,
      note: note.isEmpty ? null : note,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add manually')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minutes',
                hintText: 'e.g. 45',
                errorText: _errorText,
              ),
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. scales, chord changes, left hand...',
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
