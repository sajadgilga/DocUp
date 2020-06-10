import 'package:bloc/bloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/panel/Panel.dart';
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
      yield FirstTab(subtabs: event.subtabs, index: event.index, text: event.text);
    else if (event is SecondTab)
      yield SecondTab(subtabs: event.subtabs, index: event.index, text: event.text);
    else if (event is ThirdTab)
      yield ThirdTab(subtabs: event.subtabs, index: event.index, text: event.text);
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
  SecondTab({List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);


  bool isSame(PanelTabState other) {
    return (other is SecondTab);
  }

  bool operator ==(other) {
    return (other is SecondTab && other.index == index);
  }
}

class ThirdTab extends PanelTabState {
  ThirdTab({List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool isSame(PanelTabState other) {
    return (other is ThirdTab && other.index == index);
  }

  bool operator ==(other) {
    return (other is ThirdTab);
  }
}

Map<String, PanelTabState> tabs = {
  "info": FirstTab(text: Strings.panelIllnessInfoLabel),
  "chat": SecondTab(text: Strings.panelChatLabel),
  "call": ThirdTab(text: Strings.panelVideoCallLabel),
//  "call": ThirdTab(subtabs: [
//    SubTab(id: 'video', text: 'تصویری'),
//    SubTab(id: 'voice', text: 'صوتی')
//  ], index: 0),
  //
  'calendar': FirstTab(subtabs: [
    SubTab(id: 'calendar', text: 'تقویم', widget: Icons.calendar_today),
    SubTab(id: 'time', text: 'ساعت', widget: Icons.access_time)
  ], index: 0),
  'events': SecondTab(text: Strings.panelEventPageLabel),
  'reminders': ThirdTab(text: Strings.panelReminderPageLabel),
  //
  'documents': FirstTab(text: Strings.panelDocumentsPicLabel),
  'medicines': SecondTab(text: Strings.panelPrescriptionsPicLabel),
  'results': ThirdTab(text: Strings.panelTestResultsPicLabel)
};
