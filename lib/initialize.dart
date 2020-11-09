import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Initialise extends StatefulWidget {
  @override
  _InitialiseState createState() => _InitialiseState();
}

class _InitialiseState extends State<Initialise> {
  final nameController = TextEditingController();
  String name;
  bool isNameEmpty;
  @override
  void initState() {
  this.name = nameController.text;
  this.isNameEmpty = true;
  super.initState();
  }
  
  void updateName(value){
    setState(() {
      this.name = value;
      this.isNameEmpty = (this.name == null || this.name.length == 0);
    });
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    super.dispose();
  }
  addNameToSharedPreference(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_sent_date", DateTime.now().toString());
    await prefs.setInt("sent_total", 1223);
    await prefs.setInt("sent_total_by_me", 344);
    await prefs.setInt("total", 2000);
    await prefs.setInt('last_sent', 99);
    return prefs.setString('deviceName', name);
  }
  void next() async{
    print("pressed");
    print("currentValue"+this.name);
    await addNameToSharedPreference(name);
    Navigator.pushReplacementNamed(context, 'home');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Buddy"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blueGrey),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Padding(
                child: Center(
                  child: Text(
                    "What should we name this phone? This will help identifing sender phone.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextField(
                  onChanged: updateName,
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                    hintText: "e.g. Umang's phone",
                    filled: true,
                    fillColor: Colors.white12,
                    
                  ),
                  style: TextStyle(fontSize: 30),
                  showCursor: true,
                  autofocus: true,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: RawMaterialButton(
                  onPressed:(this.isNameEmpty) ? null : next,
                  child: new Icon(
                    Icons.navigate_next,
                    color:  Colors.blue,
                    size: 50.0,
                    
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  padding: const EdgeInsets.all(15.0),
                  fillColor: (this.isNameEmpty ) ? Colors.white12 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
