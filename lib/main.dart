import 'package:flutter/material.dart';
import 'package:smsbuddy/analyse.dart';
import 'package:smsbuddy/initialize.dart';
import 'package:smsbuddy/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smsbuddy/send.dart';

import 'home.dart';
import 'list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default home.
  Widget _defaultHome = Initialise();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String _name = prefs.getString("deviceName");
  print(_name);
  if (_name != null) {
    _defaultHome = Home();
    // _defaultHome = SendSMS();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _defaultHome,
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        "home": (context) => Home(),
        "init": (context) => Initialise(),
        "send": (context) => SendSMS(routeArgs: settings.arguments),
        "list": (context) => ListContacts(),
        "analyse": (context) => Analyse(),
      };
      WidgetBuilder builder = routes[settings.name];
      return MaterialPageRoute(builder: (ctx) => builder(ctx));
    },
    // routes: {'/home': (context) => Home(), '/init': (context) => Initialise(),'/send':(context) => SendSMS()},
    theme: ThemeData(
      fontFamily: 'Roboto',
    ),
  ));
}

// class _MyAppState extends State<MyApp> {
//   var name;
//   @override
//   void initState(){
//     // this.name = getDeviceName();
//     // if(this.name==null)
//     //   print("null hai");
//     // print("name is");
//     // print("name"+this.name);
//     super.initState();
//   }

//   getName(){
//     print(this.name);
//     return this.name;
//   }
//   getDeviceName() {
//     SharedPreferences.getInstance().then((pref){
//       String name = pref.getString('deviceName');
//       print(name);
//       return name;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: _defaultHome,
//       routes: {
//         '/home':(context) => Home(),
//         '/init':(context) => Initialise()
//       },
//       theme: ThemeData(
//         fontFamily: 'Roboto',
//       ),
//       );
//   }
// }
