import 'package:client_chat/backend/actions/connect_to_socket_action.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/screens/channels_screen.dart';
import 'package:client_chat/screens/create_channel_screen.dart';
import 'package:client_chat/widgets/loading_indicator.dart';
import 'package:client_chat/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [
    ChannelsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _oninitialBuild(BuildContext context, ViewModel vm, String url) {
    vm.connectToSocket(url);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(widget),
      onInitialBuild: (context, store, vm) {
        _oninitialBuild(this.context, vm, 'http://localhost:5000');
      },
      builder: (context, vm) => _buildScaffold(context, vm),
    );
  }

  Scaffold _buildScaffold(BuildContext context, ViewModel vm) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: "Channels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class Factory extends VmFactory<AppState, HomeScreen> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        isLoading: state.isLoading,
        connectToSocket: handleOnConnectToSocket,
      );

  void handleOnConnectToSocket(String url) async {
    await dispatch(ConnectToSocketAction(url: url));
  }
}

class ViewModel extends Vm {
  final bool isLoading;

  final Function(String) connectToSocket;

  ViewModel({
    required this.isLoading,
    required this.connectToSocket,
  }) : super(equals: [
          isLoading,
        ]);
}
