import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'package:redsmylife/pages/settings.dart';
import 'dart:convert';
import 'package:redsmylife/utils.dart';

/// ニュースタブ
class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> with AutomaticKeepAliveClientMixin<NewsTab> {
  /// AutomaticKeepAliveClientMixinとwantKeepAliveで、タブ移動時に状態を維持させる
  @override
  bool get wantKeepAlive => true;
  List _feeds = List();
  ListView _listView;
  dynamic _selectedFeed;
  int _newestItemTimestamp = 0;
  int _oldestItemTimestamp = 0;
  bool _isLoading = false;
  ScrollController _scrollController;

  /// APIからニュースデータ取得
  Future<void> getNews(String kind) async {
    if (_isLoading) {
      log(DateTime.now().toString() + " データ読込中のためブロック kind=" + kind.toString());
      return;
    }
    log(DateTime.now().toString() + " getNews started. kind=" + kind.toString());
    _isLoading = true;
    // await Future.delayed(Duration(seconds: 3)); //non blocking
    try {
      // 古いデータ・最新データの読み込み条件
      var condition = "";
      if('older' == kind) {
        condition = "&max=" + _oldestItemTimestamp.toString();
      } else if('newer' == kind) {
        condition = "&min=" + _newestItemTimestamp.toString();
      }
      var url = Uri.encodeFull(GlobalConfiguration().getString("feedUrlBase"))
        + "?teamId=" + GlobalConfiguration().getString("teamId")
        + "&count=" + GlobalConfiguration().getString("newsEntriesPerPage")
        + condition;
      // log("url=" + url);
      var response = await http.get(url, headers: {"Accept": "application/json"});
      // log("★response.body=" + response.body);
      if (response.body != null && response.body != "[{\"json\":\"no data\"}]") {
        setState(() {
          var feedsFromApi = json.decode(response.body);
          log(DateTime.now().toString() + " kind ==== " + kind.toString());
          if (kind == null) { //初回
            _feeds.addAll(feedsFromApi);
            _newestItemTimestamp = feedsFromApi[0]["published_date_num"];
            _oldestItemTimestamp = feedsFromApi[feedsFromApi.length-1]["published_date_num"];
          } else if (kind == "older") { //load more
            _feeds.addAll(feedsFromApi);
            _oldestItemTimestamp = feedsFromApi[feedsFromApi.length-1]["published_date_num"];
          } else if (kind == "newer") { //pull to refresh
            _feeds.insertAll(0, feedsFromApi);
            _newestItemTimestamp = feedsFromApi[0]["published_date_num"];
          }
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Pull to refresh
  Future<void> _refresh() {
    return getNews('newer');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log('>>>>>>>>>>>>>>>>>>>>>>> news build');
    _listView = ListView.separated(
      separatorBuilder: (context, index) => Divider(color: Colors.grey),
      controller: _scrollController,
      itemCount: 0 < _feeds.length? _feeds.length + 1 : 0,
      itemBuilder: (context, index) {
        // log("index=" + index.toString() + ", feeds.length=" + feeds.length.toString());
        // 最後の行はインジケータ
        if (index == _feeds.length) {
          return new Center(
            child: new Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            ),
          );
        } else {
          var feed = _feeds[index];
          var pubDate = feed["published_date"] != null? DateFormat("yyyy/MM/dd HH:mm").format(
            DateTime.parse(feed["published_date"].replaceAll("/", "-"))) : "";

          // log('---------------------');
          // log(feed["image_url"].toString() + ("  ") + feed["image_width"].toString() + ("/") + feed["image_height"].toString());
          // log("entry=" + feed.toString());
          return ListTile(
            contentPadding: EdgeInsets.all(8.0),
            selected: feed == _selectedFeed,
            title: Row(
              children: [
                // イメージ
                feed["image_url"] != ""? 
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Image.network(
                      feed["image_url"], 
                      width: 240.0,
                      fit: BoxFit.fitWidth)
                    ) : Container(),
                // タイトル
                Flexible( //テキスト折返し用
                  child: Text(
                    feed["entry_title"], 
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ]),
            // サブタイトル(サイト名、公開日時)
            subtitle: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                feed["site_name"] + "  " + pubDate,
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.right,),
            ),
            onTap: () {
              setState(() {
                _selectedFeed = feed;
                Utils.openWeb(feed["entry_url"]);
              });
            });
        }
      });
    var container = Container(
      color: Colors.black,
      child: RefreshIndicator(
        child: _listView
        ,onRefresh: _refresh,
      )
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        titleSpacing: 0.0,
        title: Text('ニュース', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        leading: Icon(Icons.search),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0), 
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              ),
          )
        ]
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: container
      )
    );
  }
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // Infinite loading
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentPosition = _scrollController.position.pixels;
      if (maxScrollExtent > 0 &&
          (maxScrollExtent - 200.0) <= currentPosition) {
        getNews('older');
      }
    });
    this.getNews(null);
  }
}
