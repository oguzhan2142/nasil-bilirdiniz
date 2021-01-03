import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;
import 'package:kpss_tercih/firebase/firestore.dart';
import 'package:kpss_tercih/search_page/search_tile_item.dart';
import 'package:kpss_tercih/search_result.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Color _mainColor = Colors.grey[850];
  Color _borderRadiusColor = Colors.white54;
  TextEditingController _textEditController;
  bool _deleteBtnVisible = false;

  FocusNode _focusNode = FocusNode();

  List<Widget> _searchResults = List();

  @override
  void initState() {
    super.initState();
    _textEditController = TextEditingController();
    _textEditController.addListener(() {
      if (_textEditController.text.length > 0)
        setState(() {
          if (!_deleteBtnVisible) _deleteBtnVisible = true;
        });
      else
        setState(() {
          if (_deleteBtnVisible) _deleteBtnVisible = false;
        });
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus)
        setState(() {
          _borderRadiusColor = Colors.amber;
        });
      else
        setState(() {
          _borderRadiusColor = Colors.white54;
        });
    });
  }

  void search(String query) async {
    List<Widget> results = List();

    Map<dynamic, dynamic> users = await db.fetchAllUsers();
    String authId = FirebaseAuth.instance.currentUser.uid;

    if (users == null) {
      return;
    }
    List<SearchResult> searchResults = List();

    users.forEach((key, value) {
      searchResults.add(SearchResult(key, value, query));
    });

    searchResults.sort();

    searchResults.forEach((element) {
      if (authId != element.itemKey) {
        Future profileImageLink = getDownloadLink(uid: element.itemKey);
        results.add(_createTileItem(element, profileImageLink));
      }
    });

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainColor,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 60, 30, 20),
            decoration: BoxDecoration(
                border: Border.all(color: _borderRadiusColor, width: 2),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                SizedBox(width: 13),
                Icon(
                  Icons.search,
                  color: Colors.amber,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    child: TextField(
                      focusNode: _focusNode,
                      onSubmitted: (text) {
                        search(text);
                      },
                      controller: _textEditController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Kullanıcı ara...',
                          hintStyle: TextStyle(color: Colors.white60)),
                    ),
                  ),
                ),
                if (_deleteBtnVisible)
                  FlatButton(
                    child: Icon(
                      Icons.delete,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      _textEditController.text = '';
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(10.0),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: _searchResults,
            ),
          )
        ],
      ),
    );
  }

  Widget _createTileItem(SearchResult searchResult, Future futureProfileImage) {
    return SearchTileItem(
      userKey: searchResult.itemKey,
      userData: searchResult.itemValue,
      futureProfileImage: futureProfileImage,
    );
  }
}
