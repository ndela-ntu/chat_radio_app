import 'dart:async';

import 'package:client_chat/backend/actions/append_socket_message_list_action.dart';
import 'package:client_chat/backend/actions/loading_action.dart';
import 'package:client_chat/backend/actions/set_app_signal_state_action.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/models/encounted_error_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/message_type.dart';
import 'package:client_chat/helpers/socket_service.dart';

class ConnectToSocketAction extends ReduxAction<AppState> {
  ConnectToSocketAction({
    required this.url,
  });

  final String url;

  @override
  Future before() async => await dispatch(LoadingAction(isLoading: true));

  @override
  Future after() async => await dispatch(LoadingAction(isLoading: false));

  @override
  Future<AppState?> reduce() async {
    final currentSocket = SocketService(url);

    Future.delayed(const Duration(seconds: 10));

    await currentSocket.connect((connected) async {
      if (connected) {
        await dispatch(SetAppSignalStateAction(isOn: true));

        currentSocket.listenForMessages((message) async {
          await dispatch(AppendSocketMessageListAction(message: message));
        });
      } else {
        await dispatch(SetAppSignalStateAction(isOn: false));
      }
    });

    return state.copy(currentSocket: currentSocket);

    /*else {
        final error =
            EncountedError(description: 'Failed to connect to socket');

        return state.copy(
          encountedError: error,
        );
      }*/
  }
}
