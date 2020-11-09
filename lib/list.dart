import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListContacts extends StatefulWidget {
  @override
  _ListContactsState createState() => _ListContactsState();
}

class _ListContactsState extends State<ListContacts> {
  List<dynamic> contacts;
  List<dynamic> filteredContacts;
  initState() {
    contacts = [];
    filteredContacts = [];
    super.initState();
    getContacts();
  }

  getSubtitle(contact) {
    List<Widget> content = [];
    content.add(Text(contact["_id"],
        style: TextStyle(color: Colors.blueGrey.shade200)));
    if (contact["status"] != null) {
      content.add(Text(contact["status"],
          style: TextStyle(color: Colors.blueGrey.shade200)));
      if (contact["status_by"] != null) {
        content.add(Text("by " + contact["status_by"],
            style: TextStyle(color: Colors.blueGrey.shade200)));
      }
      if (contact["status_on"] != null) {
        content.add(Text("at " + contact["status_on"],
            style: TextStyle(color: Colors.blueGrey.shade200)));
      }
    }

    return content;
  }

  Widget contactList() {
    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        var contact = filteredContacts[index];
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
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getSubtitle(contact)),
                        trailing: (contact["status"] != null)
                            ? Text(contact["status"])
                            : null)))
          ],
        );
      },
    );
  }

  filterContacts(String string) {
    print(string);
    List<dynamic> temp = contacts.where((contact) {
      //  if(contact.toString().toLowerCase().contains(string.toLowerCase()))
      // print(contact.toString());
      return contact.toString().toLowerCase().contains(string.toLowerCase());
    }).toList();
    setState(() {
      filteredContacts = temp;
    });
  }

  getContacts() {
    print("test");
    print("calling api");
    http.get(Uri.http("192.168.0.106:5000", '/get')).then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("response" + response.body);
        setState(() {
          contacts = json.decode(response.body);
          filteredContacts = json.decode(response.body);
        });
      }
    });
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
              color: Colors.blueGrey.shade600,
              child: Column(
                children: <Widget>[
                  Container(
                      child: TextField(onChanged: filterContacts), height: 50),
                  Expanded(child: Container(child: contactList())),
                ],
              ))),
    );
  }
}
