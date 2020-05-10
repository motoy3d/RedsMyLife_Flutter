import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:redsmylife/utils.dart';
import 'package:share/share.dart';

/// 日程タブ
class SettingsPage extends StatelessWidget {
  final titles = ["アプリをシェア", "友達にメールですすめる!", "評価する・レビューを書く（お願い🙏）",
    "開発元にメールする", "利用規約", ""];//ボーダー用に最後はダミー
  @override
  Widget build(BuildContext context) {
    final appUrl = GlobalConfiguration().getString(Platform.isIOS? "iOSAppUrl" : "androidUrl");
    final appName = GlobalConfiguration().getString("appName");
    final appNameEnc = Uri.encodeComponent(appName);
    final developerMail = Uri.encodeComponent(GlobalConfiguration().getString("developerMail"));
    ListView _listView = ListView.separated(
      separatorBuilder: (context, index) => Divider(color: Colors.grey),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.all(8.0),
          title: Text(titles[index]),
          trailing: index < 5? Icon(Icons.keyboard_arrow_right) : null,
          enabled: index < 5,
          onTap: () {
            switch(index) {
              case 0: //LINE
                Share.share(appUrl, subject: appName);
                break;
              case 1: //メール
                var url = "mailto:" + "?subject=" + appNameEnc + "&body=" + appUrl;
                Utils.launchUrl(url);
                break;
              case 2: //評価・レビュー
                Utils.launchUrl(appUrl);
                break;
              case 3: //開発元にメール
                var url = "mailto:" + developerMail + "?subject=" + appNameEnc;
                Utils.launchUrl(url);
                break;
              case 4: //利用規約
                var url = GlobalConfiguration().getString("rulesUrl") 
                  + appNameEnc;
                Utils.openWeb(url);
                break;
            }
          }
        );
      }
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        title: Text('設定', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _listView,
      )
    );
  }
}
