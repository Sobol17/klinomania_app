enum ProfileMenuAction {
  personalData,
  settings,
  history,
  contacts,
  legal,
  logout,
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.action,
    required this.title,
    this.isDestructive = false,
  });

  final ProfileMenuAction action;
  final String title;
  final bool isDestructive;
}
