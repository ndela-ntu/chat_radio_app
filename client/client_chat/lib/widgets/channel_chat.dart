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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _dateFormatter = DateFormat('HH:mm');

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

  Widget _buildChat(BuildContext context, ViewModel vm) {
    final _size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: <Widget>[
            _chatListMessages(vm, _size),
            _messageWidget(context, vm),
          ],
        ),
      ),
    );
  }

  Expanded _chatListMessages(ViewModel vm, Size _size) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: vm.socketMessages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        itemBuilder: (context, index) {
          final message = vm.socketMessages[index];
          return Container(
            padding: const EdgeInsets.only(
              left: 2.5,
              right: 2.5,
              top: 10,
              bottom: 10,
            ),
            child: Align(
              alignment: (message.messageType == MessageType.recipient
                  ? Alignment.topLeft
                  : Alignment.topRight),
              child: _messageContainer(_size, message, vm),
            ),
          );
        },
      ),
    );
  }

  Container _messageContainer(Size _size, ChatMessage message, ViewModel vm) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _size.width * 0.65,
        // maxHeight: _size.height * 0.2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: (message.messageType == MessageType.recipient
            ? Colors.black87.withOpacity(0.3)
            : Colors.white70.withOpacity(0.3)),
        // : ),
      ),
      padding: const EdgeInsets.all(7.5),
      child: message.messageType == MessageType.recipient
          ? _receivedMessage(vm, message)
          : _textMessage(message),
    );
  }

  Text _textMessage(ChatMessage message) {
    return Text(
      message.messageContent,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black87,
      ),
    );
  }

  Column _receivedMessage(ViewModel vm, ChatMessage message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white70,
          ),
          child: Text(
            '${vm.user.name} - ${_dateFormatter.format(message.time)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 2.5, 2.5, 0),
          child: Text(
            message.messageContent,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Row _messageWidget(BuildContext context, ViewModel vm) {
    return Row(
      children: [
        _textMessageField(),
        const SizedBox(
          width: 5,
        ),
        _sendMessageButton(context, vm),
      ],
    );
  }

  Expanded _textMessageField() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        height: 40,
        width: double.infinity,
        child: Expanded(
          child: TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              isDense: true,
              hintText: "Message...",
              hintStyle: TextStyle(
                color: Colors.black38,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _sendMessageButton(BuildContext context, ViewModel vm) {
    final _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        if (_messageController.text != '') {
          FocusScope.of(context).unfocus();
          _onSendTap(context, vm, _messageController.text);
          _messageController.clear();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: _size.width * 0.1,
        height: _size.width * 0.1,
        decoration: const BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.fromLTRB(15, 10, 12.5, 12.5),
        child: const Icon(
          Icons.send,
          color: Colors.white,
          size: 14,
        ),
      ),
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
