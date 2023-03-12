import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/screens/channels_screen.dart';
import 'package:client_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:async_redux/async_redux.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  Main({Key? key}) : super(key: key);

  final Store<AppState> store = Store<AppState>(initialState: AppState.init());

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(primarySwatch: Colors.grey),
        debugShowCheckedModeBanner: false,
        home: const ChannelsScreen(),
      ),
    );
  }
}
