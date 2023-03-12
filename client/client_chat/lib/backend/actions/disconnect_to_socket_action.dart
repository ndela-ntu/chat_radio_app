import 'dart:async';

import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DisconnectToSocketAction extends ReduxAction<AppState> {
  DisconnectToSocketAction();

  @override
  Future<AppState?> reduce() async {
    state.currentSocket.disconnect();

    return state.copy(
      currentSocket: null,
      socketMessages: [],
      currentChannel: null,
    );
  }
}
