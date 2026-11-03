import 'package:flutter/material.dart';

class ActivityIconOption {
  const ActivityIconOption({
    required this.id,
    required this.label,
    required this.category,
    required this.icon,
  });

  final String id;
  final String label;
  final String category;
  final IconData icon;
}

const activityIconCategories = [
  'All',
  'Creative',
  'Learning',
  'Movement',
  'Everyday',
];

const activityIconCatalog = [
  ActivityIconOption(
    id: 'sparkles',
    label: 'General',
    category: 'Everyday',
    icon: Icons.auto_awesome,
  ),
  ActivityIconOption(
    id: 'music',
    label: 'Music',
    category: 'Creative',
    icon: Icons.music_note,
  ),
  ActivityIconOption(
    id: 'instrument',
    label: 'Instrument',
    category: 'Creative',
    icon: Icons.library_music,
  ),
  ActivityIconOption(
    id: 'singing',
    label: 'Singing',
    category: 'Creative',
    icon: Icons.mic,
  ),
  ActivityIconOption(
    id: 'art',
    label: 'Art',
    category: 'Creative',
    icon: Icons.palette,
  ),
  ActivityIconOption(
    id: 'writing',
    label: 'Writing',
    category: 'Creative',
    icon: Icons.edit,
  ),
  ActivityIconOption(
    id: 'photography',
    label: 'Photography',
    category: 'Creative',
    icon: Icons.camera_alt,
  ),
  ActivityIconOption(
    id: 'crafts',
    label: 'Crafts',
    category: 'Creative',
    icon: Icons.handyman,
  ),
  ActivityIconOption(
    id: 'film',
    label: 'Film',
    category: 'Creative',
    icon: Icons.movie,
  ),
  ActivityIconOption(
    id: 'reading',
    label: 'Reading',
    category: 'Learning',
    icon: Icons.menu_book,
  ),
  ActivityIconOption(
    id: 'language',
    label: 'Languages',
    category: 'Learning',
    icon: Icons.translate,
  ),
  ActivityIconOption(
    id: 'coding',
    label: 'Coding',
    category: 'Learning',
    icon: Icons.code,
  ),
  ActivityIconOption(
    id: 'science',
    label: 'Science',
    category: 'Learning',
    icon: Icons.science,
  ),
  ActivityIconOption(
    id: 'study',
    label: 'Study',
    category: 'Learning',
    icon: Icons.school,
  ),
  ActivityIconOption(
    id: 'running',
    label: 'Running',
    category: 'Movement',
    icon: Icons.directions_run,
  ),
  ActivityIconOption(
    id: 'fitness',
    label: 'Fitness',
    category: 'Movement',
    icon: Icons.fitness_center,
  ),
  ActivityIconOption(
    id: 'cycling',
    label: 'Cycling',
    category: 'Movement',
    icon: Icons.directions_bike,
  ),
  ActivityIconOption(
    id: 'swimming',
    label: 'Swimming',
    category: 'Movement',
    icon: Icons.pool,
  ),
  ActivityIconOption(
    id: 'football',
    label: 'Football',
    category: 'Movement',
    icon: Icons.sports_soccer,
  ),
  ActivityIconOption(
    id: 'basketball',
    label: 'Basketball',
    category: 'Movement',
    icon: Icons.sports_basketball,
  ),
  ActivityIconOption(
    id: 'dance',
    label: 'Dance',
    category: 'Movement',
    icon: Icons.sports_gymnastics,
  ),
  ActivityIconOption(
    id: 'hiking',
    label: 'Hiking',
    category: 'Movement',
    icon: Icons.hiking,
  ),
  ActivityIconOption(
    id: 'meditation',
    label: 'Meditation',
    category: 'Movement',
    icon: Icons.self_improvement,
  ),
  ActivityIconOption(
    id: 'gardening',
    label: 'Gardening',
    category: 'Everyday',
    icon: Icons.local_florist,
  ),
  ActivityIconOption(
    id: 'cooking',
    label: 'Cooking',
    category: 'Everyday',
    icon: Icons.restaurant,
  ),
  ActivityIconOption(
    id: 'baking',
    label: 'Baking',
    category: 'Everyday',
    icon: Icons.cake,
  ),
  ActivityIconOption(
    id: 'home',
    label: 'Home',
    category: 'Everyday',
    icon: Icons.cleaning_services,
  ),
  ActivityIconOption(
    id: 'pets',
    label: 'Pets',
    category: 'Everyday',
    icon: Icons.pets,
  ),
  ActivityIconOption(
    id: 'travel',
    label: 'Travel',
    category: 'Everyday',
    icon: Icons.flight,
  ),
  ActivityIconOption(
    id: 'gaming',
    label: 'Gaming',
    category: 'Everyday',
    icon: Icons.sports_esports,
  ),
  ActivityIconOption(
    id: 'volunteering',
    label: 'Volunteering',
    category: 'Everyday',
    icon: Icons.volunteer_activism,
  ),
];

ActivityIconOption activityIconFor(String id) {
  for (final option in activityIconCatalog) {
    if (option.id == id) return option;
  }
  return activityIconCatalog.first;
}
