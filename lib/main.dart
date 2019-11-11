import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:redsmylife/tabs/news.dart';
import 'package:redsmylife/tabs/results.dart';
import 'package:redsmylife/tabs/standings.dart';
import 'package:redsmylife/tabs/twitter.dart';
import 'package:redsmylife/tabs/players.dart';
import 'package:global_configuration/global_configuration.dart';

void main() async {
  await GlobalConfiguration().loadFromAsset("config");
  await initializeDateFormatting('ja_JP');
  runApp(MaterialApp(
    title: GlobalConfiguration().getString("appName"),
    home: Main(),
    theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        accentColor: Colors.cyan[600],
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        // textTheme: TextTheme(
        //   headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        //   body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        // ),
      )
    )
  );
}

class Main extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

// SingleTickerProviderStateMixin is used for animation
class MainState extends State<Main> with SingleTickerProviderStateMixin {
  TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
    controller.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the TabBar view as the body of the Scaffold
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[NewsTab(), ResultsTab(), StandingsTab(), 
          TwitterTab(), PlayersTab()],
        // set the controller
        controller: controller,
      ),
      // Set the bottom navigation bar
      bottomNavigationBar: Container(
        // color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))),
        color: Colors.black,
        child:SafeArea(
          top: false,
          bottom: true,
          child: Material(
            // set the color of the bottom navigation bar
            color: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
            // set the tab bar as the child of bottom navigation bar
            child: TabBar(
              tabs: <Tab>[
                Tab(
                  // set icon to the tab
                  icon: controller.index == 0? 
                    Image.asset("assets/images/news_white.png", width: 24,) :
                    Image.asset("assets/images/news_grey.png", width: 24,),
                  text: "NEWS"
                ),
                Tab(
                  icon: controller.index == 1? 
                    Image.asset("assets/images/game_white.png", width: 24,) :
                    Image.asset("assets/images/game_grey.png", width: 24,),
                  text: "日程"
                ),
                Tab(
                  icon: controller.index == 2? 
                    Image.asset("assets/images/standings_white.png", width: 24,) :
                    Image.asset("assets/images/standings_grey.png", width: 24,),
                  text: "順位表"
                ),
                Tab(
                  icon: controller.index == 3? 
                    Image.asset("assets/images/twitter_white.png", width: 24,) :
                    Image.asset("assets/images/twitter_grey.png", width: 24,),
                  text: "twitter"
                ),
                Tab(
                  icon: controller.index == 4? 
                    Image.asset("assets/images/players_white.png", width: 24,) :
                    Image.asset("assets/images/players_grey.png", width: 24,),
                  text: "選手+α"
                ),
              ],
              // setup the controller
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
