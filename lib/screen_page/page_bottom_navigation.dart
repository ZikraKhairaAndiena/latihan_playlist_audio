import 'package:flutter/material.dart';
import 'package:latihan_playlist_audio/screen_page/page_favorit.dart';
import 'package:latihan_playlist_audio/screen_page/page_home.dart';

class PageBottomNavigationBar extends StatefulWidget {
  const PageBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<PageBottomNavigationBar> createState() =>
      _PageBottomNavigationBarState();
}

class _PageBottomNavigationBarState extends State<PageBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  //late SessionManager sessionManager;

  @override
  void initState() {
    super.initState();
    //sessionManager = SessionManager();
    //sessionManager.getSession();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: [
          PageHome(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabController.index,
        onTap: (index) {
          tabController.animateTo(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note), // Ikon untuk Berita
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), // Ikon untuk Profil
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}