import 'package:async_redux/async_redux.dart';
import 'package:client_chat/backend/actions/create_channel_action.dart';
import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/screens/channels_screen.dart';
import 'package:client_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({Key? key}) : super(key: key);

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  @override
  void initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  Future<void> _onCreateTap(
      BuildContext context, ViewModel vm, Channel channel) async {
    await vm.onCreateChannel(channel);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      onInitialBuild: (context, store, vm) {},
      builder: (context, vm) => _buildForm(context, vm),
    );
  }

  Form _buildForm(BuildContext context, ViewModel vm) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
              child: Container(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: Text('Create New Channel'),
                )
              ],
            ),
          )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 1.5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    label: Text('Channel Title'),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter channel name';
                    }

                    if (vm.channelList
                        .any((element) => element.title == value)) {
                      return 'Channel name already taken';
                    }

                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      width: 75,
                      height: 75,
                      child: Text('Avatar'),
                    ),
                    SizedBox(
                      width: 7.5,
                    ),
                    ElevatedButton(onPressed: () {}, child: Text('Upload')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text('Private'),
                    Checkbox(value: false, onChanged: (value) {}),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final channel = Channel(
                            id: '',
                            title: _titleController.text,
                            activeUsers: 0,
                            imageURL: '');
                        _onCreateTap(context, vm, channel).then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen();
                              },
                            ),
                          );
                        });
                      }
                    },
                    child: Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: Text('Create'),
        // ),
      ),
    );
  }
}

class Factory extends VmFactory<AppState, CreateChannelScreen> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        channelList: state.channelList,
        currentChannel: state.currentChannel,
        onCreateChannel: handleChannelCreate,
      );

  void handleChannelCreate(Channel channel) {}
}

class ViewModel extends Vm {
  final List<Channel> channelList;
  final Channel currentChannel;

  final Function(Channel) onCreateChannel;

  ViewModel({
    required this.channelList,
    required this.currentChannel,
    required this.onCreateChannel,
  }) : super(equals: [
          channelList,
          channelList.length,
          currentChannel,
        ]);
}
