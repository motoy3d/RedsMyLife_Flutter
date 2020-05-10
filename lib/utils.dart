import 'dart:developer';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  /// InAppBrowserでURLを開く
  static void openWeb(String url) {
    ChromeSafariBrowser browser = new ChromeSafariBrowser(InAppBrowser());
    browser.open(url, options: {
      "addShareButton": true,
      "barCollapsingEnabled": true,
      "toolbarBackgroundColor": "#" + GlobalConfiguration().getString("mainColor").replaceAll("0xff", ""),
      "dismissButtonStyle": 1, //close
      "preferredBarTintColor": "#" + GlobalConfiguration().getString("mainColor").replaceAll("0xff", ""),
      "preferredControlTintColor": "#" + GlobalConfiguration().getString("mainFontColor").replaceAll("0xff", ""),
      "transitionStyle": 1 //flipHorizontal
    },
    optionsFallback: {
      "toolbarTopBackgroundColor": "#" + GlobalConfiguration().getString("mainColor").replaceAll("0xff", ""),
      "closeButtonCaption": "閉じる"
    });
  }

  static void launchUrl(String url) async {
    log('launchUrl. $url');
    if (await canLaunch(url)) {
      var result = await launch(url);
      log('result=$result');
    } else {
      throw 'Could not launch $url';
    }
  }
}
