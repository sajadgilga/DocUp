import 'package:bloc/bloc.dart';
import 'package:docup/models/Panel.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/repository/PictureRepository.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  PictureRepository _repository = PictureRepository();

  @override
  PictureState get initialState => PictureUnloaded();

  Stream<PictureState> _get(PictureListGet event) async* {
    if (state is PicturesLoaded)
      yield PictureLoading(section: (state as PicturesLoaded).section);
    else
      yield PictureLoading();

    try {
      final response = await _repository.get(event.listId);
      yield PicturesLoaded(section: response);
    } catch (e) {
      yield PictureError();
    }
  }


  Stream<PictureState> _upload(PictureUpload event) async* {
    if (state is PictureUploading)
      return;
    if (state is PicturesLoaded)
      yield PictureUploading(section: (state as PicturesLoaded).section);
    if (state is PictureLoading)
      yield PictureUploading(section: (state as PictureLoading).section);
    try {
      final response = await _repository.uploadPicture(
          event.picture, event.listId);
      yield PictureUploaded();
      yield PicturesLoaded(section: (state as PictureUploading).section);
    } catch (e) {
//      yield PictureError();
    print(e.toString());
    }
  }


  @override
  Stream<PictureState> mapEventToState(PictureEvent event) async* {
    if (event is PictureListGet)
      yield* _get(event);
    else if (event is PictureUpload)
      yield* _upload(event);

  }
}

// events
abstract class PictureEvent {}

class PictureUpload extends PictureEvent {
  int listId;
  PictureEntity picture;

  PictureUpload({this.listId, this.picture});
}

class PictureListGet extends PictureEvent {
  int listId;

  PictureListGet({this.listId});
}

// states

abstract class PictureState {}

class PictureUnloaded extends PictureState {}

class PictureError extends PictureState {}

class PictureLoading extends PictureState {
  PanelSection section;

  PictureLoading({this.section});
}

class PicturesLoaded extends PictureState {
  PanelSection section;

  PicturesLoaded({this.section});
}

class PictureUploaded extends PictureState {}

class PictureUploading extends PictureState {
  PanelSection section;

  PictureUploading({this.section});
}
