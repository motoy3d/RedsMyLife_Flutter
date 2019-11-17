import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:redsmylife/utils.dart';

/*
 * ニュースタブ
 */
class NewsTab extends StatefulWidget {
  @override
  NewsTabState createState() => NewsTabState();
}

class NewsTabState extends State<NewsTab> with AutomaticKeepAliveClientMixin<NewsTab> {
  @override
  bool get wantKeepAlive => true;
  List feeds = List();
  dynamic selectedFeed;
  int newestItemTimestamp = 0;
  int oldestItemTimestamp = 0;
  bool isLoading = false;

  // APIからニュースデータ取得
  Future<String> getNews(String kind) async {
    log(DateTime.now().toIso8601String() + " getNews started. kind=" + kind.toString());
    if (isLoading) {
      log(DateTime.now().toIso8601String() + " データ読込中のためブロック");
      return "Now Loading";
    }
    isLoading = true;
    try {
      // 古いデータ・最新データの読み込み条件
      var condition = "";
      if('older' == kind) {
        condition = "&max=" + oldestItemTimestamp.toString();
      } else if('newer' == kind) {
        condition = "&min=" + newestItemTimestamp.toString();
      }
      var url = Uri.encodeFull(GlobalConfiguration().getString("feedUrlBase"))
        + "?teamId=" + GlobalConfiguration().getString("teamId")
        + "&count=" + GlobalConfiguration().getString("newsEntriesPerPage")
        + condition;
      log("url=" + url);
      var response = await http.get(url, headers: {"Accept": "application/json"});
      log(response.body);
      setState(() {
        var feedsFromApi = json.decode(response.body);
        if (feedsFromApi == null) {
          return;
        }
        log(DateTime.now().toIso8601String() + " kind ==== " + kind.toString());
        if (kind == null) { //初回
          feeds.addAll(feedsFromApi);
          log(feeds.length.toString() + "件");
          newestItemTimestamp = feedsFromApi[0]["published_date_num"];
          oldestItemTimestamp = feedsFromApi[feedsFromApi.length-1]["published_date_num"];
        } else if (kind == "older") { //load more
          feeds.addAll(feedsFromApi);
          log(feeds.length.toString() + "件");
          oldestItemTimestamp = feedsFromApi[feedsFromApi.length-1]["published_date_num"];
        } else if (kind == "newer") { //pull to refresh
          feeds.insertAll(0, feedsFromApi);
          log(feeds.length.toString() + "件");
          newestItemTimestamp = feedsFromApi[0]["published_date_num"];
        }
        log("newestItemTimestamp==" + newestItemTimestamp.toString());
        log("oldestItemTimestamp==" + oldestItemTimestamp.toString());
        // // 最新、最古のタイムスタンプを設定
        // int newestItemTimestamp2 = 0;
        // int oldestItemTimestamp2 = 0;
        // for (var entry in feeds) {
        //   if (newestItemTimestamp2 < entry["published_date_num"]) {
        //     newestItemTimestamp2 = entry["published_date_num"];
        //   }
        //   if (oldestItemTimestamp2 == 0 || entry["published_date_num"] < oldestItemTimestamp2) {
        //     oldestItemTimestamp2 = entry["published_date_num"];
        //   }
        //   if (newestItemTimestamp < newestItemTimestamp2) {
        //     newestItemTimestamp = newestItemTimestamp2;
        //   }
        //   if (oldestItemTimestamp2 < oldestItemTimestamp) {
        //     oldestItemTimestamp = oldestItemTimestamp2;
        //   }
        // }
      });
    } finally {
      isLoading = false;
    }
    return "Successfull";
  }

  // Pull to refresh
  Future<void> _refresh() {
    return Future.sync(() {
      setState(() {
        log("refresh");
        getNews('newer');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var container = Container(
      color: Colors.black,
      child: RefreshIndicator(
        child: new NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification value) {
            if (value.metrics.extentAfter == 0.0) {
              getNews('older');
            }
          },
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              var feed = feeds[index];
              var pubDate = DateFormat("yyyy/MM/dd HH:mm").format(
                DateTime.parse(feed["published_date"].replaceAll("/", "-")));

              // log('---------------------');
              // log(feed["image_url"] + "  " + feed["image_width"].toString() + "/" + feed["image_height"].toString());
              return ListTile(
                contentPadding: EdgeInsets.all(8.0),
                selected: feed == selectedFeed,
                title: Row(
                  children: [
                    // イメージ
                    feed["image_width"] !=0? 
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
                    selectedFeed = feed;
                    Utils.openWeb(feed["entry_url"]);
                  });
                });
            })
        )
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
        actions: [Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), child: Icon(Icons.settings))]
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
    this.getNews(null);
  }
}

/*
 * 記事詳細用ルート
 */
class DetailRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  DetailRoute({@required WidgetBuilder this.builder, RouteSettings settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [
      OverlayEntry(builder: (context) {
        return Positioned(
          left: 0,
          top: 0,
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: builder(context)
          ));
      })
    ];
  }

  @override
  void install(OverlayEntry insertionPoint) {
    super.install(insertionPoint);
  }

  @override
  bool didPop(T result) {
    final bool returnValue = super.didPop(result);
    assert(returnValue);
    if (finishedWhenPopped) {
      navigator.finalizeRoute(this);
    }
    return returnValue;
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}
