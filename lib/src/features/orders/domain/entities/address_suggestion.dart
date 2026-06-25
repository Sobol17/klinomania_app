import 'package:equatable/equatable.dart';

class AddressSuggestion extends Equatable {
  const AddressSuggestion({
    required this.title,
    required this.subtitle,
    required this.address,
  });

  final String title;
  final String subtitle;
  final String address;

  @override
  List<Object?> get props => [title, subtitle, address];
}
