import 'package:client_chat/backend/actions/disconnect_to_socket_action.dart';
import 'package:client_chat/backend/actions/leave_channel_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/helpers/socket_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      onInitialBuild: (context, store, vm) {},
      builder: (context, vm) => _buildScaffold(context, vm),
    );
  }

  Scaffold _buildScaffold(BuildContext context, ViewModel vm) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _onChannelExit(context, vm).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        vm.currentChannel.title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  maxRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChannelPlayer(),
          ),
          Expanded(
            child: ChannelChat(),
          ),
        ],
      ),
    );
  }
}

class Factory extends VmFactory<AppState, ChannelDetails> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        channelList: state.channelList,
        currentChannel: state.currentChannel,
        currentSocket: state.currentSocket,
        onChannelLeave: handleLeaveChannel,
      );

  void handleLeaveChannel(String channelTitle) {
    dispatch(LeaveChannelAction(channelName: channelTitle));
  }
}

class ViewModel extends Vm {
  final List<Channel> channelList;
  final Channel currentChannel;
  final SocketService currentSocket;

  final Function(String) onChannelLeave;

  ViewModel({
    required this.channelList,
    required this.currentChannel,
    required this.currentSocket,
    required this.onChannelLeave,
  }) : super(equals: [
          channelList,
          currentChannel,
          currentSocket,
        ]);
}
