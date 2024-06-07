import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:latihan_playlist_audio/model/model_audio.dart';
import 'package:latihan_playlist_audio/screen_page/page_favorit.dart';

enum PlayerState { stopped, playing, paused }

class PageHome extends StatefulWidget {
  final List<Datum> favoriteAudioList;
  final Function(List<Datum>) onFavoriteListChanged;

  const PageHome({
    Key? key,
    required this.favoriteAudioList,
    required this.onFavoriteListChanged,
  }) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  List<Datum> _audioList = [];
  bool _isLoading = true;
  final List<AudioPlayer> _audioPlayers = [];
  final List<PlayerState> _playerStates = [];
  final Set<int> _favoriteIndexes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchAudioData();
    _initializeFavoriteIndexes();
  }

  void _initializeFavoriteIndexes() {
    for (int i = 0; i < _audioList.length; i++) {
      if (widget.favoriteAudioList.contains(_audioList[i])) {
        _favoriteIndexes.add(i);
      }
    }
  }

  Future<void> _fetchAudioData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.100.110/latihan_playlist_audio/getAudio.php'));

      if (response.statusCode == 200) {
        final modelAudio = modelAudioFromJson(response.body);
        if (modelAudio.isSuccess && modelAudio.data.isNotEmpty) {
          setState(() {
            _audioList = modelAudio.data;
            for (int i = 0; i < _audioList.length; i++) {
              _audioPlayers.add(AudioPlayer());
              _playerStates.add(PlayerState.stopped);
              if (widget.favoriteAudioList.contains(_audioList[i])) {
                _favoriteIndexes.add(i);
              }
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load audio data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _play(int index) async {
    final audioUrl = 'http://192.168.100.110/latihan_playlist_audio/audio/${_audioList[index].audioFile}';
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

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteIndexes.contains(index)) {
        _favoriteIndexes.remove(index);
        widget.favoriteAudioList.remove(_audioList[index]);
      } else {
        _favoriteIndexes.add(index);
        widget.favoriteAudioList.add(_audioList[index]);
      }
      widget.onFavoriteListChanged(widget.favoriteAudioList);
    });
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageFavorite(favoriteAudioList: widget.favoriteAudioList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Albums',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _audioList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(
                                'http://192.168.100.110/latihan_playlist_audio/gambar/${_audioList[index].gambar}',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _audioList[index].judulAudio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'For you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _audioList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        Icon(Icons.person, size: 50),
                        if (_favoriteIndexes.contains(index))
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.favorite, color: Colors.red),
                          ),
                      ],
                    ),
                    title: Text(_audioList[index].judulAudio),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _favoriteIndexes.contains(index)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _favoriteIndexes.contains(index)
                                ? Colors.red
                                : null,
                          ),
                          onPressed: () => _toggleFavorite(index),
                        ),
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
          ],
        ),
      ),
    );
  }
}
