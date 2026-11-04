import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/presentation/activity_icon_catalog.dart';
import 'package:tenk/ui/widgets/translucent_panel.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({
    super.key,
    required this.onSaved,
    required this.onCancel,
    this.initialActivity,
  });

  static const screenKey = Key('create_activity_screen');
  static const nameFieldKey = Key('create_activity_name_field');
  static const saveButtonKey = Key('create_activity_save_button');
  static const saveErrorKey = Key('create_activity_save_error');
  static const cancelButtonKey = Key('create_activity_cancel_button');
  static const searchFieldKey = Key('create_activity_icon_search');
  static const selectedIconKey = Key('create_activity_selected_icon');
  static const maxNameLength = 40;

  final Future<void> Function(FirstActivity) onSaved;
  final VoidCallback onCancel;
  final FirstActivity? initialActivity;

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _iconScrollController = ScrollController();

  late String _iconId;
  String _searchTerm = '';
  String _category = 'All';
  String? _fieldError;
  String? _saveError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final activity = widget.initialActivity;
    _iconId = activity?.iconId ?? activityIconCatalog.first.id;
    if (activity != null) _nameController.text = activity.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _iconScrollController.dispose();
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

    final activity = FirstActivity(name: name, iconId: _iconId);
    try {
      await widget.onSaved(activity);
      if (!mounted) return;
      setState(() => _isSaving = false);
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filteredIcons = activityIconCatalog.where((option) {
      final matchesCategory =
          _category == 'All' || option.category == _category;
      final matchesSearch = option.label.toLowerCase().contains(_searchTerm);
      return matchesCategory && matchesSearch;
    }).toList();
    final gridColumns = MediaQuery.sizeOf(context).width < 420 ? 4 : 6;
    final hasMoreThanOneRow = filteredIcons.length > gridColumns;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: TranslucentPanel(
              key: CreateActivityScreen.screenKey,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: CreateActivityScreen.cancelButtonKey,
                      tooltip: 'Cancel',
                      onPressed: _isSaving ? null : widget.onCancel,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  Text(
                    widget.initialActivity == null
                        ? 'Add activity'
                        : 'Edit activity',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an icon and give it a name.',
                    style: textTheme.bodyLarge?.copyWith(color: appInkColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: CreateActivityScreen.searchFieldKey,
                    controller: _searchController,
                    enabled: !_isSaving,
                    style: textTheme.bodyLarge?.copyWith(
                      color: appInkColor,
                      fontSize: 12,
                    ),
                    onChanged: (value) => setState(
                      () => _searchTerm = value.trim().toLowerCase(),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Search icons',
                      labelStyle: const TextStyle(
                        color: appInkColor,
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      filled: true,
                      fillColor: appPanelFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: appPanelControlBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: appPanelControlBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: appInkColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final category in activityIconCategories)
                        ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          showCheckmark: true,
                          checkmarkColor: appInkColor,
                          labelStyle: const TextStyle(
                            color: appInkColor,
                            fontSize: 10,
                          ),
                          backgroundColor: appPanelTileColor,
                          selectedColor: appPanelSelectedTileColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(
                            color: appPanelControlBorderColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: _isSaving
                              ? null
                              : (_) => setState(() => _category = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filteredIcons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No icons found. Try another search.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    )
                  else
                    SizedBox(
                      height: 204,
                      child: Scrollbar(
                        controller: _iconScrollController,
                        thumbVisibility: hasMoreThanOneRow,
                        trackVisibility: hasMoreThanOneRow,
                        interactive: true,
                        child: GridView.builder(
                          controller: _iconScrollController,
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                childAspectRatio: 1.5,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                              ),
                          itemCount: filteredIcons.length,
                          itemBuilder: (context, index) {
                            final option = filteredIcons[index];
                            return Semantics(
                              button: true,
                              selected: option.id == _iconId,
                              label: option.label,
                              child: InkWell(
                                key: ValueKey(
                                  'create_activity_icon_${option.id}',
                                ),
                                onTap: _isSaving
                                    ? null
                                    : () => setState(() => _iconId = option.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: option.id == _iconId
                                        ? appPanelSelectedTileColor
                                        : appPanelTileColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: option.id == _iconId
                                        ? Border.all(
                                            color: colors.primary,
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    option.icon,
                                    key: option.id == _iconId
                                        ? CreateActivityScreen.selectedIconKey
                                        : null,
                                    size: 18,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    key: CreateActivityScreen.nameFieldKey,
                    controller: _nameController,
                    enabled: !_isSaving,
                    style: textTheme.bodyLarge?.copyWith(color: appInkColor),
                    maxLength: CreateActivityScreen.maxNameLength,
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
                      labelStyle: const TextStyle(color: appInkColor),
                      hintStyle: TextStyle(
                        color: appInkColor.withValues(alpha: 0.68),
                      ),
                      filled: true,
                      fillColor: appPanelFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: appPanelControlBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: appPanelControlBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: appInkColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (_saveError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _saveError!,
                      key: CreateActivityScreen.saveErrorKey,
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    key: CreateActivityScreen.saveButtonKey,
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Save'),
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
