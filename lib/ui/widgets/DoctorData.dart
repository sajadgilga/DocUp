import 'package:DocUp/models/DoctorEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorData extends StatelessWidget {
  final DoctorEntity doctorEntity;
  final double width;

  const DoctorData({
    Key key, this.doctorEntity, this.width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      child: Column(
        children: <Widget>[
          Text(
              "دکتر ${doctorEntity.user.firstName} ${doctorEntity.user.lastName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("کلینیک ${doctorEntity.clinic.clinicName}",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Image.asset("assets/location.png"),
              SizedBox(width: 5),
              Flexible(
                child: Text("${doctorEntity.expert}",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                overflow: TextOverflow.ellipsis,),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "کد نظام پزشکی :‌ ${doctorEntity.councilCode}",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.end,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.info_outline,
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
    );
  }
}
