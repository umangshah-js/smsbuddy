import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';

class SendSMS extends StatefulWidget {
  final Map routeArgs;
  const SendSMS({this.routeArgs}) : super();
  @override
  _SendSMSState createState() => _SendSMSState();
}

class _SendSMSState extends State<SendSMS> {
  // initState(){
  //   getContacts(20);
  // }
  List<dynamic> contacts;
  List<dynamic> canceledContacts;
  SmsSender sender;
  int smsCount;
  int simNumber;
  List<dynamic> doneContacts;
  List<dynamic> failedContacts;
  int delivery;
  bool hasSent;
  String deviceName;
  @override
  initState() {
    super.initState();
    contacts = [];
    canceledContacts = [];
    doneContacts = [];
    delivery = null;
    smsCount = widget.routeArgs["smsCount"];
    simNumber = widget.routeArgs["simNumber"];
    hasSent = false;
    print("smsCount in send" + smsCount.toString());
    print("simNumber in send" + simNumber.toString());
    sender = new SmsSender();
    // sender.onSmsDelivered.listen((SmsMessage message) {
    //   print('${message.address} received your message.');
    // });

    getContacts(smsCount);
  }

  Widget contactList() {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        var contact = contacts[index];
        return Column(
          children: <Widget>[
            Card(
                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.blueGrey.shade600,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      // borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      isThreeLine: true,
                      title: Text(
                        contact["name"],
                        style: TextStyle(
                            fontSize: 30, color: Colors.blueGrey.shade100),
                      ),
                      subtitle: Text(contact["_id"],
                          style: TextStyle(color: Colors.blueGrey.shade200)),
                      trailing: (!hasSent)
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.blueGrey.shade700,
                              ),
                              onPressed: () {
                                setState(() {
                                  canceledContacts.add(contacts[index]);
                                  contacts.removeAt(index);
                                });
                              },
                            )
                          : (contact["status"] == null)
                              ? Text("Sending")
                              : Text(contact["status"]),
                    )))
          ],
        );
      },
    );
  }

  getContacts(count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("deviceName");
    setState(() {
      deviceName = name;
    });
    var params = {'name': deviceName, 'count': count.toString()};
    print("calling api with params:" + params.toString());
    http
        .get(Uri.http("192.168.0.106:5000", '/queue_messages', params))
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("response" + response.body);
        setState(() {
          contacts = json.decode(response.body);
        });
      }
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacementNamed(context, 'home');
    return new Future.value(false);
  }

  send() async {
    var contactsLength = contacts.length;
    SimCardsProvider provider = new SimCardsProvider();
    List<SimCard> card = await provider.getSimCards();
    setState(() {
      hasSent = true;
    });
    contacts.asMap().forEach((i, contact) {
      print(contact["_id"]);
      //  setState(() {
      //       contacts.remove(contact);
      //     });
      SmsMessage message = new SmsMessage(contact["_id"], contact["message"]);
      message.onStateChanged.listen((state) {
        if (state == SmsMessageState.Sent) {
          setState(() {
            contacts[i]["status"] = "Sent";
          });

          // checkIfDone(message.address,contactsLength);
        } else if (state == SmsMessageState.Delivered) {
          setState(() {
            contacts[i]["status"] = "Delivered";
          });
          var params = {
            "_id": message.address,
            "status": "delivered",
            "name": deviceName
          };
          http.get(Uri.http("192.168.0.106:5000", '/set_status', params));
          doneContacts.add({"id": message.address, "status": "sent"});
          checkIfDone(message.address, contactsLength);
          print("SMS is delivered to " + message.address);
        } else if (state == SmsMessageState.Fail) {
          setState(() {
            contacts[i]["status"] = "Failed";
          });
          doneContacts.add({"id": message.address, "status": "failed"});
          checkIfDone(message.address, contactsLength);
          var params = {
            "_id": message.address,
            "status": "Failed",
            "name": deviceName
          };
          http.get(Uri.http("192.168.0.106:5000", '/set_status', params));
          print("SMS sending failed");
        }
      });
      sender.sendSms(message, simCard: card[simNumber]);
      var params = {
        "_id": message.address,
        "status": "Sent",
        "name": deviceName
      };
      http.get(Uri.http("192.168.0.106:5000", '/set_status', params));
    });
  }

  checkIfDone(address, total) {
    if (doneContacts.length == total) {
      List<dynamic> failedContacts = doneContacts
          .where((element) => element["status"] == "Failed")
          .toList();
      if (failedContacts.length == 0)
        Navigator.pushReplacementNamed(context, 'home');
      else {
        List<Widget> failedList = [];
        failedContacts.forEach((contact) {
          failedList.add(Text(contact["_id"]));
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Folowing sms failed to send."),
                content: Column(children: failedList),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // getContacts(20);
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
      child: Scaffold(
          appBar: appBar,
          body: Container(
              color: Colors.blueGrey.shade600,
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 50),
                      child: contactList(),
                    ),
                  ),
                  Positioned.fill(
                    bottom: 10,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: RawMaterialButton(
                          onPressed: contacts.length > 0 ? send : null,
                          child: (!hasSent)
                              ? Icon(
                                  Icons.send,
                                  color: Colors.blueGrey,
                                  size: 50.0,
                                )
                              : CircularProgressIndicator(strokeWidth: 7),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          padding: const EdgeInsets.all(10.0),
                          fillColor: Colors.white),
                    ),
                  ),
                ],
              ))),
      onWillPop: _onBackPressed,
    );
  }
}
