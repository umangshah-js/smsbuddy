import 'package:flutter/material.dart';
import 'package:diagonal/diagonal.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sms/sms.dart';
// import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _sent_today;
  int _sent_total_by_me;
  int _sent_total;
  int _total;
  int _simSelected;
  String deviceName;
  SmsSender sender;
  void initState() {
    super.initState();

    _sent_today = 0;
    _sent_total_by_me = 0;
    _sent_total = 0;
    _total = 0;
    sender = new SmsSender();
    // sender.onSmsDelivered.listen((SmsMessage message) {
    //   print('${message.address} received your message from ${message.body}');
    // });
    getStats();
  }
  // didUpdateWidget(Widget oldWidget){
  //   _init();
  // }

  getStats() async {
    print("getting stats");
    SharedPreferences pref = await SharedPreferences.getInstance();
    String deviceName = pref.getString("deviceName").toString();
    print(deviceName);
    http
        .get(Uri.http("192.168.0.106:5000", "/get_stats", {"name": deviceName}))
        .then((response) {
      print(response.body);
      var res = json.decode(response.body);
      setState(() {
        _sent_today = res["this_device_todays_messages"];
        _sent_total = res["total_sent_so_far"];
        _sent_total_by_me = res["this_device_total_messages"];
        _total = res["total_contacts"];
      });
    });
  }

  send() async {
    // SimCardsProvider provider = new SimCardsProvider();
    // List<SimCard> cards = await provider.getSimCards();

    // for (int i = 0; i < cards.length; i++) {
    //   SmsMessage message =
    //       new SmsMessage("9409247150", "sim" + (i + 1).toString());
    //   message.onStateChanged.listen((state) {
    //     if (state == SmsMessageState.Sent) {
    //       Toast.show("SMS sent via " + message.body, context,
    //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //     } else if (state == SmsMessageState.Delivered) {
    //       Toast.show("SMS delivered via " + message.body, context,
    //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //     }
    //   });
    //   sender.sendSms(message, simCard: cards[i]);
    // }
    var options = showDialog(
        context: context, builder: (BuildContext context) => SendDialog());
    options.then((data) {
      print("sms count" + data[0].toString());
      print("sim" + data[1].toString());
      Navigator.pushReplacementNamed(context, 'send',
          arguments: {"smsCount": data[0], "simNumber": data[1]});
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text("SMS Buddy"),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
      elevation: 0,
    );
    return Scaffold(
        appBar: appBar,
        body: Container(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                child: Diagonal(
                  clipHeight: 90,
                  child: Container(
                    height: (MediaQuery.of(context).size.height -
                                appBar.preferredSize.height) /
                            2 +
                        45,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blueGrey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _sent_today.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey.shade100,
                                          fontSize: 40),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _sent_total_by_me.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey.shade100,
                                          fontSize: 40),
                                    ))
                              ]),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Sent Today',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey.shade100,
                                          fontSize: 20),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Sent Total',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey.shade100,
                                          fontSize: 20),
                                    ))
                              ]),
                        ),
                        Expanded(
                          flex: 14,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: RawMaterialButton(
                                  onPressed: send,
                                  child: new Icon(
                                    Icons.send,
                                    color: Colors.blueGrey,
                                    size: 80.0,
                                  ),
                                  shape: new CircleBorder(),
                                  elevation: 2.0,
                                  padding: const EdgeInsets.all(20.0),
                                  fillColor: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: ((MediaQuery.of(context).size.height -
                            appBar.preferredSize.height) /
                        2) -
                    45,
                child: Diagonal(
                  position: Position.TOP_RIGHT,
                  clipHeight: 90,
                  child: Container(
                    height: ((MediaQuery.of(context).size.height -
                                appBar.preferredSize.height) /
                            2) +
                        45,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blueGrey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 14,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  RawMaterialButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, 'list');
                                    },
                                    child: new Icon(
                                      Icons.view_list,
                                      color: Colors.blueGrey.shade100,
                                      size: 80.0,
                                    ),
                                    shape: new CircleBorder(),
                                    elevation: 2.0,
                                    padding: const EdgeInsets.all(20.0),
                                    fillColor: Colors.blueGrey.shade900,
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, 'analyse');
                                    },
                                    child: new Icon(
                                      Icons.playlist_add_check,
                                      color: Colors.blueGrey.shade100,
                                      size: 80.0,
                                    ),
                                    shape: new CircleBorder(),
                                    elevation: 2.0,
                                    padding: const EdgeInsets.all(20.0),
                                    fillColor: Colors.blueGrey.shade900,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _sent_total.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 40),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _total.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 40),
                                    ))
                              ]),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      'SMS Sent',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 20),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Total Contacts',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 20),
                                    ))
                              ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class SendDialog extends StatefulWidget {
  @override
  _SendDialogState createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  int _selectedSim = 0;
  int _smsCount = 20;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Please enter message count and sim details'),
      children: <Widget>[
        Container(
          // height: 300,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      _smsCount = int.parse(val);
                    });
                  },
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  initialValue: "20",
                  decoration: InputDecoration(
                    hintText: 'Number of sms to be sent',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    groupValue: _selectedSim,
                    onChanged: (val) {
                      setState(() {
                        _selectedSim = val;
                      });
                    },
                    value: 0,
                  ),
                  Text("Sim 1"),
                  Radio(
                    groupValue: _selectedSim,
                    onChanged: (val) {
                      setState(() {
                        _selectedSim = val;
                      });
                    },
                    value: 1,
                  ),
                  Text("Sim 2"),
                  // RadioListTile(
                  //   onChanged: (val){
                  //     setState(() {
                  //       _selectedSim = val;
                  //     });
                  //   },
                  //   title: Text("Sim2"),
                  //   value: 1,
                  // ),
                ],
              ),
              FlatButton(
                color: Colors.blueGrey,
                child: new Text("Next"),
                onPressed: () {
                  print(_smsCount);
                  print(_selectedSim);
                  Navigator.pop(context, [_smsCount, _selectedSim]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
