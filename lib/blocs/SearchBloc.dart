import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/repository/SearchRepository.dart';
import 'package:bloc/bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchRepository _repository = SearchRepository();

  @override
  get initialState => SearchUnloaded();

  Stream<SearchState> _searchDoctor(SearchDoctor event) async* {
    if (state?.result?.isDoctor == true) {
      yield SearchLoading(result: state.result);
    } else {
      yield SearchLoading();
    }
    try {
      SearchResult searchResult;
      if (event.isMyDoctors) {
        searchResult = await _repository.searchMyDoctor();
      } else {
        searchResult = await _repository.searchDoctor(
            event.paramSearch, event.clinicId, event.expertise);
      }

      yield SearchLoaded(result: searchResult);
    } catch (e) {
      yield SearchError();
    }
  }

  Stream<SearchState> _searchPatient(SearchPatient event) async* {
    if (state?.result?.isPatient == true) {
      yield SearchLoading(result: state.result);
    } else {
      yield SearchLoading();
    }
    try {
      SearchResult searchResult;
      searchResult =
          await _repository.searchPatient(event.text, event.patientFilter);
      yield SearchLoaded(result: searchResult, count: searchResult.count);
    } catch (e) {
      yield SearchError();
    }
  }

  Stream<SearchState> _searchVisit(SearchVisit event) async* {
    if (state?.result?.isVisit == true) {
      yield SearchLoading(result: state.result);
    } else {
      yield SearchLoading();
    }
    try {
      SearchResult searchResult;
      searchResult = await _repository.searchPatientVisits(
          event.text, event.acceptStatus, event.visitType);
      yield SearchLoaded(result: searchResult, count: searchResult.count);
    } catch (e) {
      yield SearchError();
    }
  }

  Stream<SearchState> _searchClinic(SearchClinic event) async* {
    if (state?.result?.isClinic == true) {
      yield SearchLoading(result: state.result);
    } else {
      yield SearchLoading();
    }
    try {
      SearchResult searchResult;
      searchResult = await _repository.searchClinics();
      yield SearchLoaded(result: searchResult, count: searchResult.count);
    } catch (e) {
      print(e);
      yield SearchError();
    }
  }

  Stream<SearchState> _searchCount(SearchCountGet event) async* {
    yield SearchLoading(count: state.count, result: state.result);
    try {
      SearchResult searchResult;
      searchResult = await _repository.searchPatientVisits(
          event.text, event.acceptStatus, event.visitType);
      yield SearchLoaded(result: searchResult, count: searchResult.count);
    } catch (e) {
      yield SearchError(count: state.count, result: state.result);
    }
  }

  @override
  Stream<SearchState> mapEventToState(event) async* {
    if (event is SearchDoctor) {
      yield* _searchDoctor(event);
    } else if (event is SearchPatient) {
      yield* _searchPatient(event);
    } else if (event is SearchVisit) {
      yield* _searchVisit(event);
    } else if (event is SearchCountGet) {
      yield* _searchCount(event);
    } else if (event is SearchClinic) {
      yield* _searchClinic(event);
    } else if (event is SearchLoadingEvent) {
      yield SearchLoading();
    } else if (event is ErrorEvent) {
      yield SearchError();
    }
  }
}

// events
abstract class SearchEvent {}

class SearchLoadingEvent extends SearchEvent {
  SearchLoadingEvent();
}

class SearchPatient extends SearchEvent {
  String text;
  String patientFilter;

  SearchPatient({this.text = "", this.patientFilter});
}

class SearchDoctor extends SearchEvent {
  bool isMyDoctors;
  String paramSearch;
  String expertise;
  int clinicId;

  /// TODO pagination should be completed after api document

  SearchDoctor(
      {this.paramSearch,
      this.clinicId,
      this.expertise,
      this.isMyDoctors = false});
}

class ErrorEvent extends SearchEvent {}

class SearchVisit extends SearchEvent {
  String text;
  int acceptStatus;
  int visitType;

  SearchVisit({this.text, this.acceptStatus, this.visitType});
}

class SearchClinic extends SearchEvent {
  SearchClinic();
}

class SearchCountGet extends SearchEvent {
  String text;
  int acceptStatus;
  int visitType;

  SearchCountGet({this.text = '', this.acceptStatus, this.visitType});
}

// states
abstract class SearchState {
  SearchResult result;
  int count;

  SearchState({this.result, this.count = 0});
}

class SearchError extends SearchState {
  SearchError({result, count = 0}) : super(result: result, count: count);
}

class SearchLoaded extends SearchState {
  SearchLoaded({result, count = 0}) : super(result: result, count: count);
}

class SearchLoading extends SearchState {
  SearchLoading({result, count = 0}) : super(result: result, count: count);
}

class SearchUnloaded extends SearchState {}
