import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:latihan_playlist_audio/model/model_audio.dart';

enum PlayerState { stopped, playing, paused }

class PageFavorite extends StatefulWidget {
  final List<Datum> favoriteAudioList;

  const PageFavorite({Key? key, required this.favoriteAudioList}) : super(key: key);

  @override
  _PageFavoriteState createState() => _PageFavoriteState();
}

class _PageFavoriteState extends State<PageFavorite> {
  final List<AudioPlayer> _audioPlayers = [];
  final List<PlayerState> _playerStates = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.favoriteAudioList.length; i++) {
      _audioPlayers.add(AudioPlayer());
      _playerStates.add(PlayerState.stopped);
    }
  }

  void _play(int index) async {
    final audioUrl = 'http://192.168.100.110/latihan_playlist_audio/audio/${widget.favoriteAudioList[index].audioFile}';
    try {
      final result = await _audioPlayers[index].play(audioUrl);
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.playing);
      } else {
        print('Error while playing audio: $result');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _pause(int index) async {
    try {
      final result = await _audioPlayers[index].pause();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.paused);
      } else {
        print('Error while pausing audio: $result');
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  void _stop(int index) async {
    try {
      final result = await _audioPlayers[index].stop();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.stopped);
      } else {
        print('Error while stopping audio: $result');
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Audios'),
      ),
      body: widget.favoriteAudioList.isEmpty
          ? Center(child: Text('No favorite audios'))
          : ListView.builder(
        itemCount: widget.favoriteAudioList.length,
        itemBuilder: (context, index) {
          final audio = widget.favoriteAudioList[index];
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: Icon(Icons.person, size: 50),
              title: Text(audio.judulAudio),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _playerStates[index] == PlayerState.playing ? null : () => _play(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: _playerStates[index] == PlayerState.playing ? () => _pause(index) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _playerStates[index] == PlayerState.playing || _playerStates[index] == PlayerState.paused ? () => _stop(index) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
