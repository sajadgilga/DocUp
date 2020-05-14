import 'package:bloc/bloc.dart';
import 'package:docup/models/SearchResult.dart';
import 'package:docup/repository/InfoRepository.dart';
import 'package:docup/repository/SearchRepository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchRepository _repository = SearchRepository();

  @override
  get initialState => SearchUnloaded();

  Stream<SearchState> _searchDoctor(event) async* {
    yield SearchLoading();
    try {
      final SearchResult searchResult =
          await _repository.searchDoctor(event.text);
      yield SearchLoaded(result: searchResult);
    } catch (e) {
      yield SearchError();
    }
  }

  Stream<SearchState> _searchPatient(SearchPatient event) async* {
    yield SearchLoading();
    try {
      SearchResult searchResult;
      if (!event.isRequestOnly)
        searchResult = await _repository.searchPatient(event.text);
      else
        searchResult = await _repository.searchPatientRequests(event.text);
      yield SearchLoaded(result: searchResult);
    } catch (e) {
      yield SearchError();
    }
  }

  @override
  Stream<SearchState> mapEventToState(event) async* {
    if (event is SearchDoctor) {
      yield* _searchDoctor(event);
    } else if (event is SearchPatient) {
      yield* _searchPatient(event);
    }
  }
}

// events
abstract class SearchEvent {}

class SearchPatient extends SearchEvent {
  String text;
  bool isRequestOnly;

  SearchPatient({this.text, this.isRequestOnly});
}

class SearchDoctor extends SearchEvent {
  String text;

  SearchDoctor({this.text});
}

// states
abstract class SearchState {}

class SearchError extends SearchState {}

class SearchLoaded extends SearchState {
  SearchResult result;

  SearchLoaded({this.result});
}

class SearchLoading extends SearchState {}

class SearchUnloaded extends SearchState {}
