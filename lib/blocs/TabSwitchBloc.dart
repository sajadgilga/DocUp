import 'package:bloc/bloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/panel/Panel.dart';

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
    yield event;
  }
}

class SubTab {
  String text;
  String id;

  SubTab({this.text, this.id});
}

abstract class PanelTabState {
  List<SubTab> subtabs;
  String text;
  int index;

  PanelTabState({this.subtabs, this.index = 0, this.text}) {
    if (text == null) text = subtabs[index].text;
  }
}

class FirstTab extends PanelTabState {
  FirstTab(
      {List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool operator ==(other) {
    return (other is FirstTab);
  }
}

class SecondTab extends PanelTabState {
  SecondTab({List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool operator ==(other) {
    return (other is SecondTab);
  }
}

class ThirdTab extends PanelTabState {
  ThirdTab({List<SubTab> subtabs = const <SubTab>[], int index = 0, String text})
      : super(subtabs: subtabs, index: index, text: text);

  bool operator ==(other) {
    return (other is ThirdTab);
  }
}

Map<String, PanelTabState> tabs = {
  "info": FirstTab(text: Strings.panelIllnessInfoLabel),
  "chat": SecondTab(text: Strings.panelChatLabel),
//  "call": ThirdTab(text: Strings.panelVideoCallLabel),
  "call": ThirdTab(subtabs: [
    SubTab(id: 'video', text: 'تصویری'),
    SubTab(id: 'voice', text: 'صوتی')
  ], index: 0),
  //
  'calendar': FirstTab(subtabs: [
    SubTab(id: 'calendar', text: 'تقویم'),
    SubTab(id: 'time', text: 'ساعت')
  ], index: 0),
  'events': SecondTab(text: Strings.panelEventPageLabel),
  'reminders': ThirdTab(text: Strings.panelReminderPageLabel),
  //
  'documents': FirstTab(text: Strings.panelDocumentsPicLabel),
  'medicines': SecondTab(text: Strings.panelPrescriptionsPicLabel),
  'results': ThirdTab(text: Strings.panelTestResultsPicLabel)
};
