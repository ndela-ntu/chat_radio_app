import 'dart:async';

import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AppendSocketMessageListAction extends ReduxAction<AppState> {
  AppendSocketMessageListAction({required this.message});

  final ChatMessage message;

  @override
  Future<AppState?> reduce() async {
    final socketMessages = state.socketMessages;
    socketMessages.add(message);

    return state.copy(socketMessages: socketMessages);
  }
}
