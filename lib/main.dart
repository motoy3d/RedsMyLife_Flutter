import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:redsmylife/tabs/news.dart';
import 'package:redsmylife/tabs/games.dart';
import 'package:redsmylife/tabs/standings.dart';
import 'package:redsmylife/tabs/twitter.dart';
import 'package:redsmylife/tabs/players.dart';
import 'package:global_configuration/global_configuration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config");
  await initializeDateFormatting('ja_JP');
  Intl.defaultLocale = 'ja';
  // Dark mode対応 https://medium.com/@pmutisya/dark-mode-in-flutter-3742062f9f59
  runApp(MaterialApp(
    title: GlobalConfiguration().getString("appName"),
    home: Main(),
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
      accentColor: Colors.white,
    ),
    locale: Locale("ja"),
  ));
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

// SingleTickerProviderStateMixin is used for animation
class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
    _controller.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState((){});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: <Widget>[NewsTab(), GamesTab(), StandingsTab(), TwitterTab(), PlayersTab()],
        controller: _controller,
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Material(
            color: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
            child: TabBar(
              // アクティブ時と非アクティブ時でアイコン切り替え
              tabs: <Tab>[
                Tab(
                  icon: _controller.index == 0? 
                    Image.asset("assets/images/news_white.png", width: 24,) :
                    Image.asset("assets/images/news_grey.png", width: 24,),
                  text: "NEWS"
                ),
                Tab(
                  icon: _controller.index == 1? 
                    Image.asset("assets/images/game_white.png", width: 24,) :
                    Image.asset("assets/images/game_grey.png", width: 24,),
                  text: "日程"
                ),
                Tab(
                  icon: _controller.index == 2? 
                    Image.asset("assets/images/standings_white.png", width: 24,) :
                    Image.asset("assets/images/standings_grey.png", width: 24,),
                  text: "順位表"
                ),
                Tab(
                  icon: _controller.index == 3? 
                    Image.asset("assets/images/twitter_white.png", width: 24,) :
                    Image.asset("assets/images/twitter_grey.png", width: 24,),
                  text: "twitter"
                ),
                Tab(
                  icon: _controller.index == 4? 
                    Image.asset("assets/images/players_white.png", width: 24,) :
                    Image.asset("assets/images/players_grey.png", width: 24,),
                  text: "選手"
                ),
              ],
              controller: _controller,
            ),
          ),
        ),
      ),
    );
  }
}
