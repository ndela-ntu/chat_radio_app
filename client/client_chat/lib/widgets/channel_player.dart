import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:client_chat/backend/models/track_info_model.dart';
import 'package:client_chat/helpers/converter.dart';
import 'package:client_chat/widgets/s3_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

const URL = 'http://localhost:5000/stream';

class ChannelPlayer extends StatefulWidget {
  const ChannelPlayer({
    Key? key,
    required this.track,
  }) : super(key: key);

  final TrackInfo track;

  @override
  State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
  final _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.STOPPED;
  late Timer _timer;
  int _duration = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _audioPlayer.release();
    _audioPlayer.dispose();
  }

  Future<void> _playAudioStream() async {
    int result = await _audioPlayer.play(URL, stayAwake: true);

    if (result == 1) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _setDuration();
      });
      setState(() {
        _playerState = PlayerState.PLAYING;
      });
    }
  }

  Future<void> _pauseAudioStream() async {
    int result = await _audioPlayer.pause();
    if (result == 1) {
      _timer.cancel();
      setState(() {
        _playerState = PlayerState.PAUSED;
      });
    }
  }

  void _onAvatarPressed() {
    setState(() {
      _playerState == PlayerState.PLAYING
          ? _pauseAudioStream()
          : _playAudioStream();
    });
  }

  void _setDuration() {
    setState(() {
      _duration = _duration + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _avatarWidget(_size),
              Expanded(child: _trackInformation(_size)),
            ],
          ),
          _durationWidget(context)
        ],
      ),
    );
  }

  Row _durationWidget(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5,
              ),
              trackHeight: 2.5,
            ),
            child: Slider(
              value: 1,
              onChanged: (value) {},
              activeColor: Colors.black54,
              thumbColor: Colors.black87,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(formatDurationInHhMmSs(_duration)),
        const SizedBox(
          width: 10,
        ),
        _playPauseIcon(_size),
      ],
    );
  }

  Column _trackInformation(Size _size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.track.title.length > 40
            ? SizedBox(
                height: _size.height * 0.025,
                child: Marquee(
                  text: widget.track.title,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w500,
                  ),
                  blankSpace: 70,
                  velocity: 30,
                ),
              )
            : Text(
                widget.track.title,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
        const SizedBox(
          height: 2.5,
        ),
        Text(
          widget.track.artist,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  Expanded _channelTrack(Size _size) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _playPauseIcon(_size),
        ],
      ),
    );
  }

  Container _avatarWidget(Size _size) {
    return Container(
      alignment: Alignment.center,
      width: _size.width * 0.35,
      height: _size.width * 0.35,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(5),
      ),
      child: S3ImageWidget(
        'amapiano/avatar/amapiano_avatar.jpeg',
      ),
    );
  }

  GestureDetector _playPauseIcon(Size _size) {
    return GestureDetector(
      onTap: () {
        //_onAvatarPressed();
      },
      child: AnimatedOpacity(
        opacity: (_playerState == PlayerState.PLAYING) ? 0.05 : 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        child: Container(
          alignment: Alignment.center,
          width: _size.width * 0.1,
          height: _size.width * 0.1,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: Icon(
            (_playerState == PlayerState.PLAYING)
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
            size: 17.5,
          ),
        ),
      ),
    );
  }
}
