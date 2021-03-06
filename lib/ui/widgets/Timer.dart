import 'package:Neuronio/blocs/timer/TimerBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'AutoText.dart';

class Timer extends StatelessWidget {
  TextStyle style;

  Timer({this.style});

  @override
  Widget build(BuildContext context) {
    final TimerBloc _timerBloc = BlocProvider.of<TimerBloc>(context);
    return BlocBuilder(
      bloc: _timerBloc,
      builder: (context, state) {
        final String minutesStr =
            ((state.duration / 60) % 60).floor().toString().padLeft(2, '0');
        final String secondsStr =
            (state.duration % 60).floor().toString().padLeft(2, '0');
        return AutoText(
          replaceFarsiNumber(' $minutesStr:$secondsStr '),
          style: style ??
              TextStyle(
                fontSize: 14,
                color: IColors.themeColor,
                fontFamily: 'iransans',
              ),
        );
      },
    );
  }
}
