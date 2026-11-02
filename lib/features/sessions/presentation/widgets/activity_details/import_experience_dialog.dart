import 'package:flutter/material.dart';
import 'package:tenk/features/activities/domain/models/experience_calculator.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

class ImportExperienceResult {
  final int minutes;

  const ImportExperienceResult({required this.minutes});
}

class ImportExperienceDialog {
  static Future<ImportExperienceResult?> open(
    BuildContext context, {
    int initialMinutes = 0,
  }) {
    return showDialog<ImportExperienceResult>(
      context: context,
      builder: (_) => _ExperienceDialog(initialMinutes: initialMinutes),
    );
  }
}

enum _InputMode { estimate, total }

class _ExperienceDialog extends StatefulWidget {
  const _ExperienceDialog({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  final _years = TextEditingController();
  final _months = TextEditingController();
  final _hoursPerWeek = TextEditingController();
  late final TextEditingController _hours;
  late final TextEditingController _minutes;
  late _InputMode _mode;

  @override
  void initState() {
    super.initState();
    _hours = TextEditingController(text: '${widget.initialMinutes ~/ 60}');
    _minutes = TextEditingController(text: '${widget.initialMinutes % 60}');
    _mode = widget.initialMinutes > 0 ? _InputMode.total : _InputMode.estimate;
  }

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _hoursPerWeek.dispose();
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  int? _wholeNumber(String text) =>
      int.tryParse(text.trim().isEmpty ? '0' : text.trim());

  double? _weeklyHours(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String? _integerError(String? text, int max) {
    final value = _wholeNumber(text ?? '');
    return value == null || value < 0 || value > max
        ? 'Enter a whole number from 0 to $max'
        : null;
  }

  String? _weeklyHoursError(String? text) {
    final value = _weeklyHours(text ?? '');
    return value == null || !value.isFinite || value <= 0 || value > 168
        ? 'Enter hours above 0 and up to 168'
        : null;
  }

  int? get _result {
    if (_mode == _InputMode.estimate) {
      final years = _wholeNumber(_years.text);
      final months = _wholeNumber(_months.text);
      final weeklyHours = _weeklyHours(_hoursPerWeek.text);
      if (years == null || months == null || weeklyHours == null) return null;
      return ExperienceCalculator.estimateMinutes(
        years: years,
        months: months,
        hoursPerWeek: weeklyHours,
      );
    }
    final hours = _wholeNumber(_hours.text);
    final minutes = _wholeNumber(_minutes.text);
    if (hours == null ||
        hours < 0 ||
        hours > ExperienceCalculator.maxMinutes ~/ 60 ||
        minutes == null ||
        minutes < 0 ||
        minutes > 59) {
      return null;
    }
    final total = hours * 60 + minutes;
    return total <= ExperienceCalculator.maxMinutes ? total : null;
  }

  Widget _integerField(
    String label,
    TextEditingController controller,
    int max,
  ) {
    return TextFormField(
      key: ValueKey(label),
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (text) => _integerError(text, max),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return AlertDialog(
      title: const Text('Existing experience'),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current: ${ActivityDetailsFormat.formatHoursMinutes(widget.initialMinutes)}',
            ),
            const SizedBox(height: 12),
            SegmentedButton<_InputMode>(
              segments: const [
                ButtonSegment(
                  value: _InputMode.estimate,
                  label: Text('Estimate'),
                ),
                ButtonSegment(
                  value: _InputMode.total,
                  label: Text('Total time'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.single),
            ),
            const SizedBox(height: 12),
            if (_mode == _InputMode.estimate) ...[
              _integerField('Years', _years, 100),
              const SizedBox(height: 8),
              _integerField('Months', _months, 11),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('Hours per week'),
                controller: _hoursPerWeek,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Hours per week'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _weeklyHoursError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                'Approximate total using 4.345 weeks per month. Maximum: 100 years.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              _integerField(
                'Hours',
                _hours,
                ExperienceCalculator.maxMinutes ~/ 60,
              ),
              const SizedBox(height: 8),
              _integerField('Minutes', _minutes, 59),
              const SizedBox(height: 8),
              Text(
                'Set both fields to 0 to clear existing experience.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'New total: ${result == null ? '—' : ActivityDetailsFormat.formatHoursMinutes(result)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (result == null) ...[
              const SizedBox(height: 8),
              Text(
                _mode == _InputMode.estimate
                    ? 'Enter a positive duration up to 100 years and valid weekly hours.'
                    : 'Enter a valid total up to ${ExperienceCalculator.maxMinutes ~/ 60} hours.',
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Saving replaces your existing experience. It counts toward total '
              'progress, without adding sessions or changing daily statistics.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: result == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop(ImportExperienceResult(minutes: result)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
