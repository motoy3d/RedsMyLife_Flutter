import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

/**
 * ニュースタブ
 */
class NewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        // Set the TabBar view as the body of the Scaffold
        middle: Text('ニュース', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("fontColor"))))),
        leading: Icon(CupertinoIcons.search),
        trailing: Icon(CupertinoIcons.settings)
      ),
      child: SafeArea(
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
  final items = List<String>.generate(10000, (i) => "Item $i");
  String selectedItem;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Master'),
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            selected: items[index] == selectedItem,
            title: Text(items[index]),
            onTap: () {
              setState(() {
                selectedItem = items[index];
                log("selected = " + selectedItem);

                // To remove the previously selected detail page
                // while (Navigator.of(context).canPop()) {
                //   Navigator.of(context).pop();
                // }

                // Navigator.of(context)
                //     .push(DetailRoute(builder: (context) {
                //   return DetailPage(item: selectedItem);
                // }));
              });
            });
        })
      );
  }
}
