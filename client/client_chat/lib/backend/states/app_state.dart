import 'package:client_chat/backend/models/channel_model.dart';
import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:client_chat/backend/models/encounted_error_model.dart';
import 'package:client_chat/backend/models/track_info_model.dart';
import 'package:client_chat/backend/models/user_model.dart';
import 'package:client_chat/helpers/socket_service.dart';

class AppState {
  final List<Channel> channelList;
  final Channel currentChannel;
  final bool isLoading;
  final SocketService currentSocket;
  final List<ChatMessage> socketMessages;
  final int testCounter;
  final EncountedError encountedError;
  final bool appOn;
  final User user;

  const AppState({
    required this.channelList,
    required this.currentChannel,
    required this.isLoading,
    required this.currentSocket,
    required this.socketMessages,
    required this.testCounter,
    required this.encountedError,
    required this.appOn,
    required this.user,
  });

  static AppState init() => AppState(
        channelList: [
          Channel(
            id: '',
            title: 'Amapiano',
            activeUsers: 12,
            imageURL: '',
            currentTrack: TrackInfo.invalid(),
          ),
          Channel(
            id: '',
            title: 'HipHop',
            activeUsers: 12,
            imageURL: '',
            currentTrack: TrackInfo.invalid(),
          )
        ],
        currentChannel: Channel.invalid(),
        isLoading: false,
        currentSocket: SocketService(''),
        socketMessages: [],
        testCounter: 0,
        encountedError: EncountedError.none(),
        appOn: false,
        user: User(name: 'User123', imageURL: ''),
      );

  AppState copy(
          {List<Channel>? channelList,
          Channel? currentChannel,
          bool? isLoading,
          SocketService? currentSocket,
          List<ChatMessage>? socketMessages,
          int? testCounter,
          EncountedError? encountedError,
          bool? appOn,
          User? user}) =>
      AppState(
        channelList: channelList ?? this.channelList,
        currentChannel: currentChannel ?? this.currentChannel,
        isLoading: isLoading ?? this.isLoading,
        currentSocket: currentSocket ?? this.currentSocket,
        socketMessages: socketMessages ?? this.socketMessages,
        testCounter: testCounter ?? this.testCounter,
        encountedError: encountedError ?? this.encountedError,
        appOn: appOn ?? this.appOn,
        user: user ?? this.user,
      );
}
