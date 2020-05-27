import 'package:bloc/bloc.dart';
import 'package:DocUp/constants/colors.dart';
import 'package:DocUp/models/ChatMessage.dart';
import 'package:DocUp/repository/ChatMessageRepository.dart';
import 'package:DocUp/ui/start/RoleType.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  ChatMessageRepository _chatMessageRepository = ChatMessageRepository();

  @override
  get initialState => ChatMessageEmpty();

  Stream<ChatMessageState> _get(ChatMessageGet event) async* {
    if (state is ChatMessageLoaded)
      yield ChatMessageLoading(
          chatMessages: (state as ChatMessageLoaded).chatMessages);
    else
      yield ChatMessageLoading(chatMessages: []);
    try {
      List<ChatMessage> messages = await _chatMessageRepository.getMessages(
          panel: event.panelId,
          size: event.size,
          up: 1,
          down: 1,
          messageId: event.messageId,
          isPatient: event.isPatient);
      yield ChatMessageLoaded(chatMessages: messages);
    } catch (e) {
      yield ChatMessageError(error: e);
    }
  }

  Stream<ChatMessageState> _send(ChatMessageSend event) async* {
    if (state is ChatMessageLoading) {
      var msgs = (state as ChatMessageLoading).chatMessages;
      msgs.add(event.msg);
      yield ChatMessageLoading(
          chatMessages: msgs);
    }
    if (state is ChatMessageLoaded) {
      var msgs = (state as ChatMessageLoaded).chatMessages;
      msgs.add(event.msg);
      yield ChatMessageLoaded(
          chatMessages: msgs);
    }
    try {
      await _chatMessageRepository.send(
          panel: event.panelId, message: event.msg);
    } catch (e) {
      print(e);
    }
  }
  Stream<ChatMessageState> _addToList(ChatMessageAddToList event) async* {
    if (state is ChatMessageLoading) {
      var msgs = (state as ChatMessageLoading).chatMessages;
      msgs.add(event.msg);
      yield ChatMessageLoading(
          chatMessages: msgs);
    }
    if (state is ChatMessageLoaded) {
      var msgs = (state as ChatMessageLoaded).chatMessages;
      msgs.add(event.msg);
      yield ChatMessageLoaded(
          chatMessages: msgs);
    }
  }

  @override
  Stream<ChatMessageState> mapEventToState(event) async* {
    if (event is ChatMessageGet) {
      yield* _get(event);
    } else if (event is ChatMessageUpdate) {
    } else if (event is ChatMessageSend) {
      yield* _send(event);
    }else if (event is ChatMessageAddToList) {
      yield* _addToList(event);
    }
  }
}

//events
abstract class ChatMessageEvent {}

class ChatMessageGet extends ChatMessageEvent {
  int panelId;
  int messageId;
  int up;
  int down;
  int size;
  bool isPatient;

  ChatMessageGet(
      {this.panelId,
      this.messageId,
      this.up,
      this.down,
      this.size,
      this.isPatient});
}

class ChatMessageSend extends ChatMessageEvent {
  final ChatMessage msg;
  int panelId;

  ChatMessageSend({@required this.msg, this.panelId});
}

class ChatMessageAdd extends ChatMessageEvent {
  final ChatMessage msg;
  int panelId;

  ChatMessageAdd({@required this.msg, this.panelId});
}

class ChatMessageAddToList extends ChatMessageEvent {
  final ChatMessage msg;

  ChatMessageAddToList({@required this.msg});
}

class ChatMessageUpdate extends ChatMessageEvent {}

//states
abstract class ChatMessageState extends Equatable {
  ChatMessageState();

  @override
  List<Object> get props => [];
}

class ChatMessageLoading extends ChatMessageState {
  final List<ChatMessage> chatMessages;

  ChatMessageLoading({this.chatMessages});

  @override
  List<Object> get props => [chatMessages];
}

class ChatMessageEmpty extends ChatMessageState {}

class ChatMessageLoaded extends ChatMessageState {
  final List<ChatMessage> chatMessages;

  ChatMessageLoaded({@required this.chatMessages});

  @override
  List<Object> get props => [chatMessages];
}

class ChatMessageError extends ChatMessageState {
  final String error;

  ChatMessageError({this.error});

  @override
  List<Object> get props => [error];
}
