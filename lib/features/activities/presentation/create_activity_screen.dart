import 'package:flutter/material.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({
    super.key,
    required this.repository,
    required this.onSaved,
  });

  static const routeName = '/create-activity';
  static const screenKey = Key('create_activity_screen');
  static const nameFieldKey = Key('create_activity_name_field');
  static const saveButtonKey = Key('create_activity_save_button');
  static const saveErrorKey = Key('create_activity_save_error');

  final FirstActivityRepository repository;
  final ValueChanged<String> onSaved;

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _nameController = TextEditingController();

  String? _fieldError;
  String? _saveError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _fieldError = 'Enter an activity name';
        _saveError = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _fieldError = null;
      _saveError = null;
      _isSaving = true;
    });

    try {
      await widget.repository.saveName(name);
      if (!mounted) return;
      setState(() => _isSaving = false);
      widget.onSaved(name);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Could not save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: CreateActivityScreen.screenKey,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('First activity', style: textTheme.headlineLarge),
                      const SizedBox(height: 12),
                      Text(
                        'What would you like to develop? Start with a name.',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        key: CreateActivityScreen.nameFieldKey,
                        controller: _nameController,
                        enabled: !_isSaving,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_fieldError != null || _saveError != null) {
                            setState(() {
                              _fieldError = null;
                              _saveError = null;
                            });
                          }
                        },
                        onSubmitted: (_) => _save(),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: 'For example, guitar',
                          errorText: _fieldError,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      if (_saveError != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _saveError!,
                          key: CreateActivityScreen.saveErrorKey,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 24),
                      FilledButton(
                        key: CreateActivityScreen.saveButtonKey,
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
