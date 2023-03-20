import 'package:client_chat/backend/actions/disconnect_to_socket_action.dart';
import 'package:client_chat/backend/actions/set_current_track_info_action.dart';
import 'package:client_chat/backend/actions/leave_channel_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/models/encounted_error_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:client_chat/widgets/app_template.dart';
import 'package:client_chat/widgets/channel_chat.dart';
import 'package:client_chat/widgets/channel_player.dart';
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

class ChannelDetails extends StatefulWidget {
  const ChannelDetails({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _ChannelDetailsState createState() => _ChannelDetailsState();
}

class _ChannelDetailsState extends State<ChannelDetails> {
  Future<void> _onChannelExit(BuildContext context, ViewModel vm) async {
    vm.onChannelLeave(vm.currentChannel.title);
  }

  Future<void> _onChannelInit(BuildContext context, ViewModel vm) async {
    vm.onChannelInit();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      onInitialBuild: (context, store, vm) {
        _onChannelInit(this.context, vm);
      },
      builder: (context, vm) => _buildScaffold(context, vm),
    );
  }

  Widget _buildScaffold(BuildContext context, ViewModel vm) {
    final _size = MediaQuery.of(context).size;

    return AppTemplate(
      isLoading: vm.isLoading,
      appOn: true,
      encountedError: vm.encountedError,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(7.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _onChannelExit(context, vm).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    vm.currentChannel.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: _size.height * 0.175,
                maxHeight: _size.height * 0.3,
              ),
              child: ChannelPlayer(track: vm.currentChannel.currentTrack),
            ),
            SizedBox(
              height: 5,
            ),
            const Expanded(
              child: ChannelChat(),
            ),
          ],
        ),
      ),
    );
  }
}

class Factory extends VmFactory<AppState, ChannelDetails> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        isLoading: state.isLoading,
        channelList: state.channelList,
        currentChannel: state.currentChannel,
        currentSocket: state.currentSocket,
        encountedError: state.encountedError,
        onChannelLeave: handleLeaveChannel,
        onChannelInit: handleInitChannel,
      );

  void handleLeaveChannel(String channelTitle) {
    dispatch(LeaveChannelAction(channelName: channelTitle));
  }

  void handleInitChannel() {}
}

class ViewModel extends Vm {
  final bool isLoading;
  final List<Channel> channelList;
  final Channel currentChannel;
  final SocketService currentSocket;
  final EncountedError encountedError;

  final Function(String) onChannelLeave;
  final Function() onChannelInit;

  ViewModel({
    required this.isLoading,
    required this.channelList,
    required this.currentChannel,
    required this.currentSocket,
    required this.encountedError,
    required this.onChannelLeave,
    required this.onChannelInit,
  }) : super(equals: [
          isLoading,
          channelList,
          currentChannel,
          currentChannel.currentTrack,
          currentSocket,
          encountedError,
        ]);
}
