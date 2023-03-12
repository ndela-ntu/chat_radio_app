import 'dart:async';

import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';

class LoadingAction extends ReduxAction<AppState> {
  LoadingAction({
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Future<AppState?> reduce() async {
    return state.copy(isLoading: isLoading);
  }
}
