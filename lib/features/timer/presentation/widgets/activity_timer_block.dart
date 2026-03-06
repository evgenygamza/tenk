import 'package:flutter/material.dart';

class ActivityTimerBlock extends StatelessWidget {
  final String activityId;
  final Color accent;

  const ActivityTimerBlock({
    super.key,
    required this.activityId,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
