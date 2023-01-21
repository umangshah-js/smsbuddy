import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sms_maintained/sms.dart';

class Analyse extends StatefulWidget {
  @override
  _AnalyseState createState() => _AnalyseState();
}

class _AnalyseState extends State<Analyse> {
  SmsQuery query;
  List<SmsMessage> messages;
  String deviceName;
  String statusMessage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    query = new SmsQuery();

    readSms();
  }

  readSms() async {
    setState(() {
      statusMessage = "Fetching Device Name";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tempDeviceName = prefs.getString("deviceName");

    setState(() {
      deviceName = tempDeviceName;
    });
    setState(() {
      statusMessage = "Fetching queued contacts";
    });
    var queuedRequest = await http.get(Uri.http("192.168.0.106:5000", '/get',
        {"status": "queued", "name": deviceName}));
    print(queuedRequest.body);
    List<dynamic> queued = json.decode(queuedRequest.body);
    setState(() {
      statusMessage = "Fetched " + queued.length.toString() + " contacts Name";
    });
    int checked = 0;
    int found = 0;
    for (dynamic contact in queued) {
      var sms = await query.querySms(
          address: contact["_id"],
          kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent]);
      setState(() {
        statusMessage = "Checked " +
            (++checked).toString() +
            " contacts out of " +
            queued.length.toString();
      });
      print(contact["_id"]);
      if (sms.length > 0) {
        var params = {
          "_id": contact["_id"].toString(),
          "status": "sent",
          "name": deviceName
        };
        found++;
        http.get(Uri.http("192.168.0.106:5000", '/set_status', params));
      }
    }
    setState(() {
      statusMessage = "Found " + (found).toString() + " sent contacts";
    });
    sleep(Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, 'home');
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacementNamed(context, 'home');
    return new Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
        title: Text("SMS Buddy"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: appBar,
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(statusMessage),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
