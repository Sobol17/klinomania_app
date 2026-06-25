import '../entities/address_suggestion.dart';
import '../repositories/address_suggestions_repository.dart';

class FetchAddressSuggestionsUseCase {
  const FetchAddressSuggestionsUseCase({
    required AddressSuggestionsRepository repository,
  }) : _repository = repository;

  final AddressSuggestionsRepository _repository;

  Future<List<AddressSuggestion>> call(String query) {
    return _repository.fetchSuggestions(query);
  }
}
