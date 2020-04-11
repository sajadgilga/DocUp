import 'dart:async';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import '../../constants/colors.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailPage({Key key, this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorInfoBloc _bloc;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _bloc = DoctorInfoBloc();
    _bloc.sendTicketStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('درخواست شما با موفقیت ثبت شد'),
          duration: Duration(seconds: 3),
        ));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getDoctor(widget.doctor.id);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctor.id),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return Center(
                      child:
                      _doctorInfoWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => _bloc.getDoctor(widget.doctor.id),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  _doctorInfoWidget(DoctorEntity doctorEntity) =>
      Column(
        children: <Widget>[
          SvgPicture.asset(
            "assets/down_arrow.svg",
            color: IColors.themeColor,
            width: 24,
            height: 24,
          ),
          SizedBox(height: 30),
          Container(
            width: 100,
            child: ClipPolygon(
              sides: 6,
              rotate: 90,
              boxShadows: [
                PolygonBoxShadow(color: Colors.black, elevation: 1.0),
                PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
              ],
              child: Image.network(doctorEntity.user.avatar),
            ),
          ),
          SizedBox(height: 10),
          Text(doctorEntity.user.firstName + " " + doctorEntity.user.lastName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(doctorEntity.expert,
              style: TextStyle(
                fontSize: 16,
              )),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                doctorEntity.clinic.clinicName,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 20),
              Icon(
                Icons.info_outline,
                color: Colors.black,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
              width: 200,
              height: 150,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(doctorEntity.clinic.latitude,
                      doctorEntity.clinic.longitude),
                  zoom: 12.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ActionButton(
            color: IColors.themeColor,
            title: Strings.requestAction,
            icon: Icon(
              Icons.send,
              size: 18.0,
            ),
            callBack: () => {_bloc.sendTicket(doctorEntity.id)},
          )
        ],
      );


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: IColors.themeColor,
            child: Text('Retry', style: TextStyle(color: Colors.black)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: IColors.themeColor,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(IColors.themeColor),
          ),
        ],
      ),
    );
  }
}
