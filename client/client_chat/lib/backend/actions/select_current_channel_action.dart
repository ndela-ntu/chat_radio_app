import 'dart:async';

import 'package:client_chat/backend/actions/connect_to_socket_action.dart';
import 'package:client_chat/backend/actions/join_channel_action.dart';
import 'package:client_chat/backend/actions/loading_action.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

class SelectCurrentChannelAction extends ReduxAction<AppState> {
  SelectCurrentChannelAction({required this.title});

  final String title;

  @override
  Future before() async => await dispatch(LoadingAction(isLoading: true));

  @override
  Future after() async => await dispatch(LoadingAction(isLoading: false));

  @override
  Future<AppState?> reduce() async {
    final currentChannel =
        state.channelList.firstWhere((element) => element.title == title);

    await dispatch(JoinChannelAction(channelName: currentChannel.title));

    return state.copy(currentChannel: currentChannel);
  }
}
