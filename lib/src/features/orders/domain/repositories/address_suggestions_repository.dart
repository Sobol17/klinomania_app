import '../entities/address_suggestion.dart';

abstract class AddressSuggestionsRepository {
  Future<List<AddressSuggestion>> fetchSuggestions(String query);
}
