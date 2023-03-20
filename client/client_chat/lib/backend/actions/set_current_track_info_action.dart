import 'dart:async';

import 'package:client_chat/backend/models/track_info_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:async_redux/async_redux.dart';

class SetCurrentTrackInfoAction extends ReduxAction<AppState> {
  SetCurrentTrackInfoAction({this.currentTrack});

  final TrackInfo? currentTrack;

  @override
  Future<AppState?> reduce() async {
    return state.copy(
      currentChannel: state.currentChannel.copy(currentTrack: currentTrack),
    );
  }
}
