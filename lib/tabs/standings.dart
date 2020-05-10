import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'dart:convert';
import 'package:redsmylife/standings_table.dart';

/// 順位表タブ
class StandingsTab extends StatefulWidget {
  @override
  _StandingsTabState createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> with AutomaticKeepAliveClientMixin<StandingsTab> {
  @override
  bool get wantKeepAlive => true;
  List standings = List();

  // APIからデータ取得
  Future<String> getStandings(compe) async {
    var season = DateTime.now().month == 1? DateTime.now().year-1 : DateTime.now().year;
    var url = Uri.encodeFull(GlobalConfiguration().getString("standingsUrl"))
      + "?teamId=" + GlobalConfiguration().getString("teamId")
      + "&season=" + season.toString();
    if (compe == null) {
        compe = "J";
    }
    url += "&compe=" + compe;
    
    log("url=" + url);
    var response = await http.get(url, headers: {"Accept": "application/json"});
    log(response.body);
    setState(() {
      standings = json.decode(response.body);
    });
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 18);
    // final BoxDecoration decoration = BoxDecoration(
    //   border: Border(bottom: Divider.createBorderSide(context, width: 1.0)),
    // );
    final dataTable = StandingsTable(
      dataRowHeight: 36.0,
      horizontalMargin: 2.0,
      columnSpacing: 4.0,
      columns: [
        StandingsDataColumn(label: Text("位", style: textStyle), numeric: true, alignment: Alignment.center),
        StandingsDataColumn(label: Text("チーム", style: textStyle), numeric: false),
        StandingsDataColumn(label: Text("点", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("勝", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("分", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("敗", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("得", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("失", style: textStyle), numeric: true),
        StandingsDataColumn(label: Text("差", style: textStyle), numeric: true),
      ],
      rows: standings.map(
        (standing) => StandingsDataRow(
          cells: [
            StandingsDataCell(Text(standing["rank"].toString(), style: textStyle), alignment: Alignment.center),
            StandingsDataCell(Text(standing["team_name"], style: textStyle)),
            StandingsDataCell(Text(standing["point"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["win"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["draw"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["lose"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["got_goal"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["lost_goal"].toString(), style: textStyle)),
            StandingsDataCell(Text(standing["diff"].toString(), style: textStyle)),
          ],
          selected: GlobalConfiguration().getString("teamName") == standing["team_name"],
          ),
        ).toList()
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(GlobalConfiguration().getString("mainColor"))),
        // Set the TabBar view as the body of the Scaffold
        title: Text('順位表', 
          style: TextStyle(color: Color(int.parse(GlobalConfiguration().getString("mainFontColor"))))),
        leading: Icon(Icons.sort),
        actions: [Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), 
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              
            })
          )]
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.black, 
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: dataTable
          )
        )
      )
    );
  }
  
  @override
  void initState() {
    super.initState();
    this.getStandings('J');
  }
}