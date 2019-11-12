import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

/*
 * 日程タブ
 */
class GamesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        // Set the TabBar view as the body of the Scaffold
        title: Text('日程', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        actions: [Icon(Icons.refresh)]
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
  List games = List();
  dynamic selectedGame;

  // APIから日程データ取得
  Future<String> getGames() async {
    var season = DateTime.now().month == 1? DateTime.now().year-1 : DateTime.now().year;
    var url = Uri.encodeFull(GlobalConfiguration().getString("gamesUrl"))
      + "?teamId=" + GlobalConfiguration().getString("teamId")
      + "&season=" + season.toString();
    // log("url=" + url);
    var response = await http.get(url, headers: {"Accept": "application/json"});
    // log(response.body);
    setState(() {
      games = json.decode(response.body);
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
        itemCount: games.length,
        itemBuilder: (context, index) {
          var game = games[index];
          return Container(
            padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
            child: Column(
              children: [
                // 日時・大会・スタジアム
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    game["game_date2"] + "  " + game["kickoff_time"] + " " + game["stadium"], 
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.start,),
                ),
                // 試合名
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(game["compe"], 
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.start,),
                ),                
                // 対戦相手、スコア
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("vs " + game["vs_team"], 
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                        )
                    ),
                    Align(
                      child: Row(
                        children: <Widget>[
                          Image.asset("assets/images/win.png", width: 28,),
                          Text(game["score"], 
                            style: TextStyle(color: Colors.white, fontSize: 28),
                            textAlign: TextAlign.end,
                          )

                        ]
                        ,)
                      ),
                  ]
                ),
                // 試合詳細ボタン、動画検索ボタン
                Align(
                  alignment: Alignment.centerRight,
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        color: Colors.white30,
                        child: Text("試合詳細"),
                        onPressed: () {
                        },
                        ),
                      FlatButton(
                        color: Colors.white30,
                        child: Text("動画検索"),
                        onPressed: () {
                        },
                        ),
                    ],
                  )
                  ),
              ]),
            // onTap: () {
            //   setState(() {
            //     selectedGame = game;
            //     log("selected = " + selectedGame.toString());

            //     // To remove the previously selected detail page
            //     while (Navigator.of(context).canPop()) {
            //       Navigator.of(context).pop();
            //     }
            //     Navigator.of(context)
            //         .push(DetailRoute(builder: (context) {
            //       return DetailPage(feed: selectedGame);
            //     }));
            //   });
            // }
            );
        })
    );
  }
  
  @override
  void initState() {
    super.initState();
    this.getGames();
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

/*
 * 記事詳細画面
 */
class DetailPage extends StatelessWidget {
  DetailPage({Key key, @required this.feed}) : super(key: key);

  final dynamic feed;

  @override
  Widget build(BuildContext context) {
    log("url=" + feed["entry_url"]);
    return Scaffold(
      appBar: AppBar(
        title: Text(feed["entry_url"]),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      body: WebView(
        initialUrl: feed["entry_url"],
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print("Created!");
        },
      ),
    );
  }
}
