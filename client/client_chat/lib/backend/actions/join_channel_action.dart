import 'dart:async';

import 'package:client_chat/backend/actions/append_socket_message_list_action.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/message_type.dart';
import 'package:client_chat/helpers/socket_service.dart';

class JoinChannelAction extends ReduxAction<AppState> {
  JoinChannelAction({
    required this.channelName,
  });

  final String channelName;

  @override
  Future<AppState?> reduce() async {
    final currentSocket = state.currentSocket;
    currentSocket.joinChannel(channelName);

    return state.copy(currentSocket: currentSocket);
  }
}
