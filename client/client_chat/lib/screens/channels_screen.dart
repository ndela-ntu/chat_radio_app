import 'package:client_chat/backend/actions/connect_to_socket_action.dart';
import 'package:client_chat/backend/actions/leave_channel_action.dart';
import 'package:client_chat/backend/actions/select_current_channel_action.dart';
import 'package:client_chat/backend/actions/test_count_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/encounted_error_model.dart';
import 'package:client_chat/backend/states/app_state.dart';

import 'package:async_redux/async_redux.dart';
import 'package:client_chat/screens/create_channel_screen.dart';
import 'package:client_chat/widgets/loading_indicator.dart';
import 'package:client_chat/widgets/app_template.dart';
import 'package:client_chat/widgets/channel_details.dart';
import 'package:flutter/material.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  Future<void> _onChannelTap(
      BuildContext context, ViewModel vm, String title) async {
    vm.onChannelSelect(title);
  }

  void _oninitialBuild(BuildContext context, ViewModel vm, String url) {
    vm.connectToSocket(url);
  }

  void _onDeleteChannel(
      BuildContext context, ViewModel vm, String channelTitle) {
    vm.deleteChannel(channelTitle);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      distinct: true,
      onInitialBuild: (context, store, vm) {
        _oninitialBuild(this.context, vm, 'http://localhost:3000');
      },
      builder: (context, vm) => _buildScaffold(context, vm),
    );
  }

  Widget _buildScaffold(BuildContext context, ViewModel vm) {
    return AppTemplate(
      isLoading: vm.isLoading,
      encountedError: vm.encountedError,
      appOn: vm.appOn,
      testCounter: vm.testCounter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _channelHeading(),

          ///  _searchChannel(),
          Expanded(child: _channelList(vm)),
        ],
      ),
    );
  }

  SafeArea _channelHeading() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Channels",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateChannelScreen();
                }));
              },
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.pink[50],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.pink,
                      size: 20,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "Create New Channel",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _channelList(ViewModel vm) {
    return vm.channelList.isEmpty
        ? Center(
            child: Text('No Channels'),
          )
        : ListView.builder(
            controller: ScrollController(),
            itemCount: vm.channelList.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16),
            itemBuilder: (context, index) {
              return _listItem(context, vm, vm.channelList[index]);
            },
          );
  }

  Padding _searchChannel() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Channel..",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100)),
        ),
      ),
    );
  }

  GestureDetector _listItem(
      BuildContext context, ViewModel vm, Channel channel) {
    return GestureDetector(
      onTap: () async {
        _onChannelTap(context, vm, channel.title).then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChannelDetails(title: channel.title);
              },
            ),
          );
        });
      },
      onLongPress: () {
        _showChannelSettingsDialog(channelTitle: channel.title, vm: vm);
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      channel.imageURL,
                    ),
                    backgroundColor: Colors.grey,
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Text(
                        channel.title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Text(
                channel.activeUsers.toString(),
              ),
            ),
            IconButton(
                onPressed: () {
                  _showChannelSettingsDialog(
                    channelTitle: channel.title,
                    vm: vm,
                  );
                },
                icon: Icon(Icons.more_vert))
          ],
        ),
      ),
    );
  }

  void _showChannelSettingsDialog({
    required String channelTitle,
    required ViewModel vm,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(channelTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogItem(
                label: 'Edit',
                iconData: Icons.edit,
                onPressed: () {},
              ),
              SizedBox(
                height: 12.5,
              ),
              _dialogItem(
                label: 'Leave',
                iconData: Icons.delete,
                onPressed: () {
                  vm.deleteChannel(channelTitle);
                },
              ),
            ],
          )),
    );
  }

  Widget _dialogItem({
    required String label,
    required IconData iconData,
    required Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Icon(iconData),
          ],
        ),
      ),
    );
  }
}

class Factory extends VmFactory<AppState, ChannelsScreen> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        channelList: state.channelList,
        isLoading: state.isLoading,
        appOn: state.appOn,
        encountedError: state.encountedError,
        testCounter: state.testCounter,
        onChannelSelect: handleOnChannelSelect,
        connectToSocket: handleOnConnectToSocket,
        deleteChannel: handleOnDeleteChannel,
      );

  void handleOnConnectToSocket(String url) async {
    // await dispatch(TestCountAction());
    await dispatch(ConnectToSocketAction(url: url));
  }

  void handleOnChannelSelect(String title) async {
    await dispatch(SelectCurrentChannelAction(title: title));
  }

  void handleOnDeleteChannel(String channelTitle) async {}
}

class ViewModel extends Vm {
  final List<Channel> channelList;
  final bool isLoading;
  final bool appOn;
  final EncountedError encountedError;
  final int testCounter;

  final Function(String) onChannelSelect;
  final Function(String) connectToSocket;
  final Function(String) deleteChannel;

  ViewModel({
    required this.channelList,
    required this.isLoading,
    required this.appOn,
    required this.encountedError,
    required this.onChannelSelect,
    required this.connectToSocket,
    required this.testCounter,
    required this.deleteChannel,
  }) : super(equals: [
          isLoading,
          appOn,
          encountedError,
          channelList,
          channelList.length,
          testCounter,
        ]);
}
