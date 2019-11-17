import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

// 未使用
class Browser extends InAppBrowser {
  
  @override
  void onBrowserCreated() async {
    print("\n\nBrowser Ready!\n\n");
  }
  
  @override
  void onLoadStart(String url) {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  void shouldOverrideUrlLoading(String url) {
    print("\n\n override $url\n\n");
    this.webViewController.loadUrl(url);
  }

  @override
  void onLoadResource(WebResourceResponse response, WebResourceRequest request) {
    // print("Started at: " + response.startTime.toString() + "ms ---> duration: " + response.duration.toString() + "ms " + response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    // print("""
    // console output:
    //   sourceURL: ${consoleMessage.sourceURL}
    //   lineNumber: ${consoleMessage.lineNumber}
    //   message: ${consoleMessage.message}
    //   messageLevel: ${consoleMessage.messageLevel}
    // """);
  }

}