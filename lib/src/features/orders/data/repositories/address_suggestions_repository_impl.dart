import '../../domain/entities/address_suggestion.dart';
import '../../domain/repositories/address_suggestions_repository.dart';
import '../services/address_suggest_service.dart';

class AddressSuggestionsRepositoryImpl implements AddressSuggestionsRepository {
  AddressSuggestionsRepositoryImpl({required AddressSuggestService service})
    : _service = service;

  final AddressSuggestService _service;

  @override
  Future<List<AddressSuggestion>> fetchSuggestions(String query) {
    return _service.fetchSuggestions(query);
  }
}
