import 'dart:async';

import 'package:client_chat/backend/actions/append_socket_message_list_action.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class TestCountAction extends ReduxAction<AppState> {
  TestCountAction();

  @override
  Future<AppState?> reduce() async {
    return state.copy(testCounter: state.testCounter + 1);
  }
}
