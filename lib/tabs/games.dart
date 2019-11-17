import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:redsmylife/utils.dart';
import 'dart:convert';

/*
 * 日程タブ
 */
class GamesTab extends StatefulWidget {
  @override
  GamesTabState createState() => GamesTabState();
}

const double _ROW_HEIGHT = 165.0;
class GamesTabState extends State<GamesTab> with AutomaticKeepAliveClientMixin<GamesTab> {
  @override
  bool get wantKeepAlive => true;
  List games = List();
  dynamic selectedGame;
  ScrollController controller;
  ListView listView;
  int lastGameIndex = 0;

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
      log("setState... games.length=" + games.length.toString());
      for (var idx=0; idx<games.length; idx++) {
        if (games[idx]["score"] == null) {
          lastGameIndex = idx;
        }
      }
      controller.animateTo(lastGameIndex * _ROW_HEIGHT, 
        duration: new Duration(seconds: 1), curve: Curves.ease);
    });
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    controller = ScrollController();
    log("build ------- ");
    listView = ListView.separated(
      separatorBuilder: (context, index) => Divider(color: Colors.grey),
      itemCount: games.length,
      controller: controller,
      itemBuilder: (context, index) {
        var game = games[index];
        var resultImage;
        if (game["score"] != null) {
          if("○" == game["result"] || "◯" == game["result"]) {
            resultImage = "win.png";
          } else if("△" == game["result"]) {
            resultImage = "draw.png";
          } else {
            resultImage = "lose.png";
          }
        } else {
          lastGameIndex = index;
        }
        // 各試合のボタン
        var buttons = <Widget>[];
        if (game["ticket_url"] != null) {
          buttons.add(ButtonTheme(
            minWidth: 100.0,
            height: 44.0,
            child: FlatButton(
              color: Colors.white30,
              child: Text("チケット"),
              onPressed: () {
                Utils.openWeb(game["ticket_url"]);
              },
              ),
            ),
          );
        }
        buttons.add(ButtonTheme(
          minWidth: 100.0,
          height: 44.0,
          child: FlatButton(
            color: Colors.white30,
            child: Text("試合詳細"),
            onPressed: () {
              if (game["detail_url"] != null) {
                Utils.openWeb(game["detail_url"]);
              }
            },),
          ),
        );
        buttons.add(ButtonTheme(
          minWidth: 100.0,
          height: 44.0,
          child: FlatButton(
            color: Colors.white30,
            child: Text("動画検索"),
            onPressed: () {
              if (game["detail_url"] != null) {
              }
            },
            ),
          ),
        );
        //　スコア
        var scoreLabel = Align();
        if (game["score"] != null) {
          scoreLabel = Align(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 6, 0),
                  child: Image.asset("assets/images/" + resultImage, width: 28,)
                ),
                Text(game["score"], 
                  style: TextStyle(color: Colors.white, fontSize: 28),
                  textAlign: TextAlign.end,
                )
              ],)
            );
        }

        return Container(
          padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
          height: _ROW_HEIGHT,
          child: Column(
            children: [
              // 日時・大会・スタジアム
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  game["game_date2"] + "  " + game["kickoff_time"] + " " + game["stadium"], 
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.start,),
              ),
              // 試合名
              Align(
                alignment: Alignment.centerLeft,
                child: Text(game["compe"], 
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
                  scoreLabel,
                ]
              ),
              // 試合詳細ボタン、動画検索ボタン
              Align(
                alignment: Alignment.centerRight,
                child: ButtonBar(
                  children: buttons,
                  )
                ),
            ]),
          );
      });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        title: Text('日程', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        actions: [Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), 
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getGames();
            })
          )]
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(color: Colors.black, child: listView),
      )
    );
  }
  
  @override
  void initState() {
    super.initState();
    log("initState-----");
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
    return Container();
  }
}
