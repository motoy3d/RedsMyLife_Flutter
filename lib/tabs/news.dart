import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:redsmylife/utils.dart';

/*
 * ニュースタブ
 */
class NewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        titleSpacing: 0.0,
        // Set the TabBar view as the body of the Scaffold
        title: Text('ニュース', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        leading: Icon(Icons.search),
        actions: [Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0), child: Icon(Icons.settings))]
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: MasterDetailContainer()
      )
    );
  }
}

/*
 * コンテナ
 */
class MasterDetailContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: MasterPage())
        ],
      ));
  }
}

class MasterPage extends StatefulWidget {
  @override
  MasterPageState createState() => MasterPageState();
}

class MasterPageState extends State<MasterPage> with AutomaticKeepAliveClientMixin<MasterPage> {
  @override
  bool get wantKeepAlive => true;
  List feeds = List();
  dynamic selectedFeed;

  // APIからニュースデータ取得
  Future<String> getNews() async {
    var url = Uri.encodeFull(GlobalConfiguration().getString("feedUrlBase"))
      + "?teamId=" + GlobalConfiguration().getString("teamId")
      + "&count=" + GlobalConfiguration().getString("newsEntriesPerPage");
    // log("url=" + url);
    var response = await http.get(url, headers: {"Accept": "application/json"});
    // log(response.body);
    setState(() {
      feeds = json.decode(response.body);
    });
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.black,
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
    );
  }
  
  @override
  void initState() {
    super.initState();
    this.getNews();
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
