import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/sessions_controller.dart';

class AddManualScreen extends StatefulWidget {
  const AddManualScreen({super.key});

  @override
  State<AddManualScreen> createState() => _AddManualScreenState();
}

class _AddManualScreenState extends State<AddManualScreen> {
  final _minutesController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _save() {
    final raw = _minutesController.text.trim();
    final minutes = int.tryParse(raw);

    if (minutes == null || minutes <= 0) {
      setState(() => _errorText = 'Enter a positive number');
      return;
    }

    context.read<SessionsController>().addManual(minutes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add manually'),
      ),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
