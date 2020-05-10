import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';

/// 選手タブ
class PlayersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoNavigationBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        // Set the TabBar view as the body of the Scaffold
        middle: Text('選手',
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor")))))
        )
      );
  }
}