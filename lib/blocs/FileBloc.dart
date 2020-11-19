import 'package:bloc/bloc.dart';
import 'package:docup/models/Panel.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/repository/PictureRepository.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  FileRepository _repository = FileRepository();

  @override
  FileState get initialState => FileUnloaded();

  Stream<FileState> _get(FileListGet event) async* {
    if (state is FilesLoaded)
      yield FileLoading();
    else
      yield FileLoading();

    try {
      final response = await _repository.get(event.listId);
      yield FilesLoaded(section: response);
    } catch (e) {
//      yield PictureError();
    }
  }


  Stream<FileState> _upload(FileUpload event) async* {
    if (state is PictureUploading)
      return;
    if (state is FilesLoaded)
      yield PictureUploading(section: (state as FilesLoaded).section);
    if (state is FileLoading)
      yield PictureUploading(section: (state as FileLoading).section);
    try {
      final response = await _repository.uploadFile(
          event.file, event.listId);
      yield PictureUploaded();
      yield FilesLoaded(section: (state as PictureUploading).section);
    } catch (e) {
      yield PictureError();
    print(e.toString());
    }
  }


  @override
  Stream<FileState> mapEventToState(FileEvent event) async* {
    if (event is FileListGet)
      yield* _get(event);
    else if (event is FileUpload)
      yield* _upload(event);

  }
}

// events
abstract class FileEvent {}

class FileUpload extends FileEvent {
  int listId;
  FileEntity file;

  FileUpload({this.listId, this.file});
}

class FileListGet extends FileEvent {
  int listId;

  FileListGet({this.listId});
}

// states

abstract class FileState {}

class FileUnloaded extends FileState {}

class PictureError extends FileState {}

class FileLoading extends FileState {
  PanelSection section;

  FileLoading({this.section});
}

class FilesLoaded extends FileState {
  PanelSection section;

  FilesLoaded({this.section});
}

class PictureUploaded extends FileState {}

class PictureUploading extends FileState {
  PanelSection section;

  PictureUploading({this.section});
}
