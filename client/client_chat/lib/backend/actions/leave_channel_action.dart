import 'dart:async';

import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class LeaveChannelAction extends ReduxAction<AppState> {
  LeaveChannelAction({required this.channelName});

  final String channelName;

  @override
  Future<AppState?> reduce() async {
    final currentSocket = state.currentSocket;
    currentSocket.leaveChannel(channelName);

    return state.copy(currentSocket: currentSocket, socketMessages: []);
  }
}
