import 'dart:async';

import 'package:client_chat/backend/actions/join_channel_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class CreateChannelAction extends ReduxAction<AppState> {
  CreateChannelAction({required this.channel});

  final Channel channel;

  @override
  Future<AppState?> reduce() async {
    final channelList = state.channelList;
    channelList.add(channel);

    return state.copy(channelList: channelList);
  }
}
