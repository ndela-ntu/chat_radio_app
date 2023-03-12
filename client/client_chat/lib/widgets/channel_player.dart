import 'package:flutter/material.dart';

class ChannelPlayer extends StatefulWidget {
  const ChannelPlayer({Key? key}) : super(key: key);

  @override
  State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
  bool _isPlay = false;

  void _onAvatarPressed() {
    setState(() {
      _isPlay = !_isPlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        //Avatar
        Container(
            alignment: Alignment.center,
            width: _size.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: _size.width * 0.15,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            )),
        IconButton(
          onPressed: _onAvatarPressed,
          icon: _isPlay
              ? Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                )
              : Icon(
                  Icons.pause,
                  color: Colors.black,
                ),
        )
      ],
    );
  }
}
