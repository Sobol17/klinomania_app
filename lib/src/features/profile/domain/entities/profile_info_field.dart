enum ProfileInfoFieldType { name, phone, email, address, description }

class ProfileInfoField {
  const ProfileInfoField({
    required this.type,
    required this.label,
    required this.value,
    this.isEditable = false,
  });

  final ProfileInfoFieldType type;
  final String label;
  final String value;
  final bool isEditable;
}
