import 'dart:convert';
import 'dart:io';

import 'package:Neuronio/blocs/FileBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/Picture.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'AutoText.dart';
import 'VerticalSpace.dart';

enum AllowedFileType { image, doc }

class AllowedFile {
  static final List<String> imageFormats = ['jpg', 'jpeg', 'png'];
  static final List<String> docs = ['pdf'];

  static String getFormatFromFilePath(String path) {
    return path.split(".").last;
  }

  static AllowedFileType getFileType(format) {
    if (AllowedFile.imageFormats.contains(format)) {
      return AllowedFileType.image;
    } else if (AllowedFile.docs.contains(format)) {
      return AllowedFileType.doc;
    } else {
      return null;
    }
  }
}

class UploadFileSlider extends StatefulWidget {
  int listId;
  int partnerId;
  final Widget body;

  UploadFileSlider({Key key, @required this.listId, this.body, this.partnerId})
      : super(key: key);

  @override
  UploadFileSliderState createState() {
    return UploadFileSliderState();
  }
}

class UploadFileSliderState extends State<UploadFileSlider> {
  FileEntity file = FileEntity(file: null, title: '', description: '');
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  AlertDialog _loading = getLoadingDialog();

  @override
  void initState() {
    BlocProvider.of<FileBloc>(context).listen((data) {
      if (data is FileUploaded) {
        showPicUploadedDialog(context, "فایل ارسال شد", () {
          BlocProvider.of<FileBloc>(context)
              .add(FileListGet(listId: widget.listId));
          Navigator.of(context).maybePop();
          Navigator.of(context, rootNavigator: true).maybePop();
        });
      } else if (data is FileError) {
        if (data.errorCode == 621) {
          showPicUploadedDialog(context,
              "برای اپلود فایل باید حداقل یک ویزیت تایید شده توسط پزشک برای اینده وجود داشته باشد.",
              () {
            Navigator.of(context, rootNavigator: true).maybePop();
          });
        } else {
          showPicUploadedDialog(context, "مشکلی پیش آمد. دوباره تلاش کنید", () {
            Navigator.of(context, rootNavigator: true).maybePop();
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    try {
      _titleController.dispose();
    } catch (e) {}
    super.dispose();
  }

  Future _getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AllowedFile.docs + AllowedFile.imageFormats,
    );
    File pickedFile = File(result.files.single.path);
    var newPicture = FileEntity(
        file: pickedFile,
        description: '',
        title: file.description,
        base64: base64Encode(pickedFile.readAsBytesSync()),
        filePath: pickedFile.path);
    setState(() {
      file = newPicture;
    });
  }

  Widget _pictureHolder(width, height) {
    return Column(
      children: [
        AutoText(
          "برای انتخاب فایل بر روی شکل زیر بزنید.",
          style: TextStyle(
              color: IColors.darkGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 40),
          constraints: BoxConstraints.expand(
            width: width,
            height: (height * .3 < 200 ? height * .3 : 200),
          ),
          child: GestureDetector(
            child: file.defaultFileWidget ??
                Image(
                  image: AssetImage('assets/uploadpic.png'),
                  fit: BoxFit.fitHeight,
                ),
            onTap: () {
              _getFile();
            },
          ),
        ),
      ],
    );
  }

  Widget _pullUp() {
    return Container(
      height: 70,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          AutoText(
            "برای ارسال به بالا بکشید.",
            style: TextStyle(
                color: IColors.darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }

  Widget _descriptionTextField() => Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _descriptionController,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          minLines: 1,
          maxLines: 15,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: new BorderSide(color: IColors.darkGrey, width: 1)),
            labelText: Strings.uploadPicTextFieldDescriptionHint,
          ),
        ),
      );

  Widget _titleTextField() => Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _titleController,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: new BorderSide(color: IColors.darkGrey, width: 1)),
            labelText: Strings.uploadPicTextFieldTitleHint,
          ),
        ),
      );

  Widget _date() => Container();

  Widget _descriptionAndTitle() => Container(
        margin: EdgeInsets.only(left: 40, right: 40, top: 40),
        child: Column(
          children: <Widget>[
            _titleTextField(),
            ALittleVerticalSpace(),
            _descriptionTextField(),
            _date()
          ],
        ),
      );

  void _uploadPic() {
    if (file != null &&
        file.file != null &&
        file.file.lengthSync() / (1000 * 1000) > 5) {
      showAlertDialog(
          context, 'حداکثر اندازه فایلی ارسالی ۵ ماگابایت است.', () {});
      return;
    }

    if (BlocProvider.of<FileBloc>(context).state is FileUploading) return;
    if (_titleController.text != '') file.title = _titleController.text;
    if (_descriptionController.text != '')
      file.description = _descriptionController.text;
    BlocProvider.of<FileBloc>(context).add(FileUpload(
        listId: widget.listId, file: file, partnerId: widget.partnerId));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _loading;
        });
  }

  Widget _submit() => GestureDetector(
      onTap: () {
        _uploadPic();
      },
      child: Container(
        margin: EdgeInsets.only(top: 30, bottom: 50),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 40),
              padding:
                  EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
              decoration: BoxDecoration(
                  color: IColors.themeColor,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: AutoText(
                'ذخیره',
                textAlign: TextAlign.center,
              ),
            )),
      ));

  Widget _listDescriptionSubmit(height) => Container(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _descriptionAndTitle(),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: _submit(),
          )
        ],
      ));

  Widget _close() => GestureDetector(
        child: Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(right: 20, top: 20),
          child: Icon(
            Icons.close,
            size: 30,
            color: IColors.black,
          ),
        ),
        onTap: () {
          Navigator.of(context).maybePop();
        },
      );

  Widget _panel(width, height) => SingleChildScrollView(
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _pullUp(),
            _close(),
            _pictureHolder(width, height),
            _listDescriptionSubmit(height)
          ],
        )),
      );

  Widget _body() {
    if (widget.body == null) return Container();
    return widget.body;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        reverse: true,
        child: SlidingUpPanel(
          backdropEnabled: true,
          padding: EdgeInsets.only(top: 0, bottom: bottom),
          backdropOpacity: .5,
          body: _body(),
          minHeight: 70,
          maxHeight: MediaQuery.of(context).size.height,
          panel: _panel(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          defaultPanelState: PanelState.OPEN,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ),
    );
  }
}
