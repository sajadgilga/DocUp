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
    if (state is FileUploading) return;
    if (state is FilesLoaded)
      yield FileUploading(section: (state as FilesLoaded).section);
    if (state is FileLoading)
      yield FileUploading(section: (state as FileLoading).section);
    try {
      final response = await _repository.uploadFile(event.file, event.listId,event.partnerId);
      yield FileUploaded();
      yield FilesLoaded(section: (state as FileUploading).section);
    } catch (e) {
      yield FileError(section: (this.state as FileUploading).section,errorCode: e.getCode(),errorMessage: e.message);
      print(e.toString());
    }
  }

  Stream<FileState> _deleteFile(FileDelete event) async* {
    if (state is FileUploading) return;
    if (state is FilesLoaded)
      yield FileDeleting(section: (state as FilesLoaded).section);
    if (state is FileLoading)
      yield FileDeleting(section: (state as FileLoading).section);
    try {
      final FileResponseDelete response =
          await _repository.deleteFile(event.fileId, event.listId);
      if (response.success) {
        final response = await _repository.get(event.listId);
        yield FilesLoaded(section: response);
      } else {
        throw Exception("Deleting image was unsuccessful.");
      }
    } catch (e) {
      yield FileError(section: (this.state as FileUploading).section);
      print(e.toString());
    }
  }

  @override
  Stream<FileState> mapEventToState(FileEvent event) async* {
    if (event is FileListGet) {
      yield* _get(event);
    } else if (event is FileUpload) {
      yield* _upload(event);
    } else if (event is FileDelete) {
      yield* _deleteFile(event);
    }
  }
}

// events
abstract class FileEvent {}

class FileUpload extends FileEvent {
  int listId;
  FileEntity file;
  int partnerId;

  FileUpload({this.listId, this.file,this.partnerId});
}

class FileDelete extends FileEvent {
  int listId;
  int fileId;

  FileDelete({this.listId, this.fileId});
}

class FileListGet extends FileEvent {
  int listId;

  FileListGet({this.listId});
}

// states

abstract class FileState {}

class FileUnloaded extends FileState {}

class FileError extends FileState {
  PanelSection section;
  int errorCode;
  String errorMessage;

  FileError({this.section,this.errorCode,this.errorMessage});
}

class FileLoading extends FileState {
  PanelSection section;

  FileLoading({this.section});
}

class FilesLoaded extends FileState {
  PanelSection section;

  FilesLoaded({this.section});
}

class FileUploaded extends FileState {}

class FileUploading extends FileState {
  PanelSection section;

  FileUploading({this.section});
}

class FileDeleting extends FileState {
  PanelSection section;

  FileDeleting({this.section});
}

class FileResponseDelete {
  bool success;

  FileResponseDelete.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
}
