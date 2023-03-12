import 'dart:async';

import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';

class SetAppSignalStateAction extends ReduxAction<AppState> {
  SetAppSignalStateAction({
    required this.isOn,
  });

  final bool isOn;

  @override
  Future<AppState?> reduce() async {
    return state.copy(appOn: isOn);
  }
}
