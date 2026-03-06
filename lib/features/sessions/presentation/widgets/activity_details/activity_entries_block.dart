import 'package:flutter/material.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';

class ActivityEntriesBlock extends StatelessWidget {
  final String activityId;
  final List<SessionEntry> entries;
  final VoidCallback onImportExperience;

  const ActivityEntriesBlock({
    super.key,
    required this.activityId,
    required this.entries,
    required this.onImportExperience,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
