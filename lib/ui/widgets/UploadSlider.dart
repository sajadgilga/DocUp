import 'dart:convert';

import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UploadSlider extends StatefulWidget {
  int listId;

  UploadSlider({Key key, @required this.listId}) : super(key: key);

  @override
  UploadSliderState createState() {
    return UploadSliderState();
  }
}

class UploadSliderState extends State<UploadSlider> {
  PictureEntity picture =
      PictureEntity(picture: null, title: '', description: '');
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    BlocProvider.of<PictureBloc>(context).listen((data) {
      if (data is PictureUploaded) {
        showPicUploadedDialog(context, () {
          BlocProvider.of<PictureBloc>(context)
              .add(PictureListGet(listId: widget.listId));
          Navigator.of(context).maybePop();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var newPicture = PictureEntity(
        picture: Image.file(
          image,
          fit: BoxFit.cover,
        ),
        description: '',
        title: image.path.split('/').last,
        base64: base64Encode(image.readAsBytesSync()),
        imagePath: image.path);
    setState(() {
      picture = newPicture;
//      _controller.text = newPicture.title;
    });
  }

  void _onDescriptionSubmit() {
    setState(() {
      picture.description = _controller.text;
    });
    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  Widget _pictureHolder(width, height) {
    return Container(
      constraints: BoxConstraints.expand(
        width: width,
        height: (height * .3 < 200 ? height * .3 : 200),
      ),
      child: GestureDetector(
        child: (picture.image != null
            ? picture.image
            : Image(
                image: AssetImage('assets/uploadpic.png'),
                fit: BoxFit.fitHeight,
              )),
        onTap: () {
          _getImage();
        },
      ),
    );
  }

  Widget _descriptionTextField() => TextField(
        controller: _controller,
        onSubmitted: (text) {
          _onDescriptionSubmit();
        },
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
//          border: InputBorder.none,
          hintText: Strings.uploadPicTextFieldHint,
        ),
      );

  Widget _date() => Container();

  Widget _description() => Container(
        margin: EdgeInsets.only(left: 40, right: 40, top: 40),
        child: Column(
          children: <Widget>[
            Align(alignment: Alignment.centerRight, child: Text('توضیحات')),
            _descriptionTextField(),
            _date()
          ],
        ),
      );

  void _uploadPic() {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text(
//              "منتظر ما باشید",
//              textAlign: TextAlign.center,
//              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//            ),
//            content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
//                textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
//          );
//        });
    if (picture.picture == null) {
      showAlertDialog(context, 'تصویری انتخاب نشده است', () {});
      return;
    }
    picture.description = _controller.text;
    BlocProvider.of<PictureBloc>(context)
        .add(PictureUpload(listId: widget.listId, picture: picture));
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
              child: Text(
                'ذخیره',
                textAlign: TextAlign.center,
              ),
            )),
      ));

  Widget _listDescriptionSubmit(height) => Container(
      constraints: BoxConstraints(maxHeight: height * .35),
      child: ListView(
        children: <Widget>[_description(), _submit()],
      ));

  Widget _panel(width, height) => Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _pictureHolder(width, height),
          _listDescriptionSubmit(height)
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: _panel(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      defaultPanelState: PanelState.OPEN,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    );
  }
}
