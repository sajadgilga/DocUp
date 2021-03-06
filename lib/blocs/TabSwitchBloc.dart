import 'package:Neuronio/constants/strings.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

//
//class TabSwitchBloc extends Bloc<PanelTabState, PanelTabState> {
//  @override
//  PanelTabState get initialState => PanelTabState.SecondTab;
//
//  @override
//  Stream<PanelTabState> mapEventToState(PanelTabState event) async* {
//    yield event;
//  }
//}

class TabSwitchBloc extends Bloc<PanelTabState, PanelTabState> {
  @override
  PanelTabState get initialState => tabs['chat'];

  @override
  Stream<PanelTabState> mapEventToState(PanelTabState event) async* {
    if (event is FirstTab)
      yield FirstTab(
          subtabs: event.subtabs, index: event.index, text: event.text);
    else if (event is SecondTab)
      yield SecondTab(
          subtabs: event.subtabs, index: event.index, text: event.text);
    else if (event is ThirdTab)
      yield ThirdTab(
          subtabs: event.subtabs, index: event.index, text: event.text);
//    yield event;
  }
}

class SubTab {
  String text;
  String id;
  IconData widget;

  SubTab({this.text, this.id, this.widget});
}

abstract class PanelTabState extends Object {
  List<SubTab> subtabs;
  String text;
  int index;

  bool isSame(PanelTabState other) {
    return false;
  }

  PanelTabState({this.subtabs, this.index = 0, this.text}) {
    if (text == null) text = subtabs[index].text;
  }
}

class LoadingTab extends PanelTabState {
  bool isSame(PanelTabState other) {
    return false;
  }
}

class FirstTab extends PanelTabState {
  FirstTab(
      {List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool isSame(PanelTabState other) {
    return (other is FirstTab);
  }

  bool operator ==(other) {
    return (other is FirstTab && other.index == index);
  }
}

class SecondTab extends PanelTabState {
  SecondTab(
      {List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool isSame(PanelTabState other) {
    return (other is SecondTab);
  }

  bool operator ==(other) {
    return (other is SecondTab && other.index == index);
  }
}

class ThirdTab extends PanelTabState {
  ThirdTab(
      {List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool isSame(PanelTabState other) {
    return (other is ThirdTab && other.index == index);
  }

  bool operator ==(other) {
    return (other is ThirdTab && other.index == index);
  }
}

Map<String, PanelTabState> tabs = {
  "info": FirstTab(text: InAppStrings.panelIllnessInfoLabel),
  "chat": SecondTab(text: InAppStrings.panelChatLabel),
  "call": ThirdTab(
      text: InAppStrings.panelVideoCallLabel,
      subtabs: [
        SubTab(id: 'video', text: 'تصویری', widget: Icons.video_call),
        SubTab(id: 'voice', text: 'صوتی', widget: Icons.record_voice_over)
      ],
      index: 0),
  //
  'calendar': FirstTab(subtabs: [
    SubTab(id: 'calendar', text: 'تقویم', widget: Icons.calendar_today),
    SubTab(id: 'time', text: 'ساعت', widget: Icons.access_time)
  ], index: 0),
  'events': SecondTab(text: InAppStrings.panelEventPageLabel),
  'reminders': ThirdTab(text: InAppStrings.panelReminderPageLabel),
  //
  'documents': FirstTab(text: InAppStrings.panelDoctorAdvicePicLabel),
  'medicines': SecondTab(text: InAppStrings.panelPrescriptionsPicLabel),
  'results': ThirdTab(text: InAppStrings.panelTestResultsPicLabel)
};
