import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Picture.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UploadSlider extends StatefulWidget {
  @override
  UploadSliderState createState() {
    return UploadSliderState();
  }
}

class UploadSliderState extends State<UploadSlider> {
  Picture picture = Picture(null, '', '');
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var newPicture = Picture(
        Image.file(
          image,
          fit: BoxFit.cover,
        ),
        image.path,
        '');
    setState(() {
      picture = newPicture;
      _controller.text = newPicture.name;
    });
  }

  void _onDescriptionSubmit() {}

  Widget _pictureHolder(width, height) {
    return Container(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: (height * .4 < 250 ? height * .4 : 250),
        maxHeight: (height * .4 < 250 ? height * .4 : 250),
      ),
      child: GestureDetector(
        child: (picture.picture != null
            ? picture.picture
            : Image(
                image: AssetImage('assets/uploadPicTestImage.png'),
                fit: BoxFit.cover,
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

  Widget _submit() => Container(
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
      );

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
