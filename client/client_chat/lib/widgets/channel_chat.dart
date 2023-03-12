import 'package:async_redux/async_redux.dart';
import 'package:client_chat/backend/actions/send_channel_message_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/models/user_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/helpers/message_type.dart';
import 'package:client_chat/helpers/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChannelChat extends StatefulWidget {
  const ChannelChat({Key? key}) : super(key: key);

  @override
  State<ChannelChat> createState() => _ChannelChatState();
}

class _ChannelChatState extends State<ChannelChat> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late DateFormat _dateFormatter;

  @override
  void initState() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _dateFormatter = DateFormat('dd/MM HH:mm');

    super.initState();
  }

  void _scrollChatDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _onSendTap(BuildContext context, ViewModel vm, String message) {
    vm.onSendMessage(
      ChatMessage(
        user: vm.user,
        channelTitle: vm.currentChannel.title,
        messageContent: message,
        messageType: MessageType.sender,
        time: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      onDidChange: (context, store, vm) {
        _scrollChatDown();
      },
      builder: (context, vm) => _buildChat(context, vm),
    );
  }

  Column _buildChat(BuildContext context, ViewModel vm) {
    return Column(
      children: <Widget>[
        // Text(vm.testCounter.toString()),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: vm.socketMessages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              final message = vm.socketMessages[index];
              return Container(
                padding:
                    EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: (message.messageType == MessageType.recipient
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (message.messageType == MessageType.recipient
                          ? Colors.grey.shade200
                          : Colors.blue[200]),
                    ),
                    padding: EdgeInsets.all(16),
                    child: message.messageType == MessageType.recipient
                        ? Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(vm.user.name),
                                  Text(_dateFormatter.format(message.time)),
                                ],
                              ),
                              Text(
                                message.messageContent,
                              )
                            ],
                          )
                        : Text(
                            message.messageContent,
                            style: TextStyle(fontSize: 15),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            height: 60,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FloatingActionButton(
                  onPressed: () {
                    _onSendTap(context, vm, _messageController.text);
                    _messageController.clear();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Factory extends VmFactory<AppState, ChannelChat> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        user: state.user,
        currentSocket: state.currentSocket,
        currentChannel: state.currentChannel,
        socketMessages: state.socketMessages,
        onSendMessage: handleOnSendMessage,
      );

  void handleOnSendMessage(ChatMessage message) async {
    await dispatch(SendChannelMessageAction(message: message));
  }
}

class ViewModel extends Vm {
  final User user;
  final SocketService currentSocket;
  final Channel currentChannel;
  final List<ChatMessage> socketMessages;

  final Function(ChatMessage) onSendMessage;

  ViewModel({
    required this.user,
    required this.currentSocket,
    required this.currentChannel,
    required this.socketMessages,
    required this.onSendMessage,
  }) : super(equals: [
          user,
          currentSocket,
          currentChannel,
          socketMessages,
          socketMessages.length,
        ]);
}
