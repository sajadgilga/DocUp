import 'package:DocUp/models/DoctorEntity.dart';
import 'package:flutter/widgets.dart';

import 'Avatar.dart';
import 'DoctorData.dart';

class DoctorSummaryWidget extends StatelessWidget {
  const DoctorSummaryWidget({
    Key key,
    @required this.doctorEntity,
  }) : super(key: key);

  final DoctorEntity doctorEntity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DoctorData(
            width: MediaQuery.of(context).size.width * 0.7,
            doctorEntity: doctorEntity),
        SizedBox(width: 10),
        Avatar(user: doctorEntity.user),
      ],
    );
  }
}