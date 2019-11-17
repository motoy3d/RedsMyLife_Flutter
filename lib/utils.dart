import 'dart:developer';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class Utils {
  static void openWeb(String url) {
    log('url=' + url);
    MyChromeSafariBrowser browser = new MyChromeSafariBrowser(InAppBrowser());
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
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {

  MyChromeSafariBrowser(browserFallback) : super(browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}
