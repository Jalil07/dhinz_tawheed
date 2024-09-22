import 'dart:convert';
import 'package:dhinz_tawheed/pages/reading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _data = [];
  Set<String> _bookmarkedTitles = <String>{};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBookmarks();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    setState(() {
      _data = data;
    });
  }

  Future<void> _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedTitles =
          prefs.getStringList('bookmarks')?.toSet() ?? <String>{};
    });
  }

  Future<void> _toggleBookmark(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedTitles.contains(title)) {
        _bookmarkedTitles.remove(title);
      } else {
        _bookmarkedTitles.add(title);
      }
      prefs.setStringList('bookmarks', _bookmarkedTitles.toList());
    });
  }

  bool _isBookmarked(String title) {
    return _bookmarkedTitles.contains(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/tawhid cover.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _data[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Image.asset('assets/images/bullet.png', height: 25,),
                      trailing: IconButton(
                        icon: Icon(
                          _isBookmarked(item['title'])
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _isBookmarked(item['title'])
                              ? const Color(0xFF272854)
                              : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleBookmark(item['title']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingPage(
                              title: item['title'],
                              content: item['content'],
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
              childCount: _data.length,
            ),
          ),
        ],
      ),
    );
  }
}
