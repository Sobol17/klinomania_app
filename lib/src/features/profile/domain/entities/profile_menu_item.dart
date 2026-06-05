enum ProfileMenuAction { history, logout, delete }

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.action,
    required this.title,
    this.description,
    this.isDestructive = false,
  });

  final ProfileMenuAction action;
  final String title;
  final String? description;
  final bool isDestructive;
}
