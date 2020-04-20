import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID-19 Totals',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.light,
      ),
      home: MyHomePage(title: 'COVID-19 Totals'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> apiUrls = [
    "https://api.covid19api.com/summary",
    "https://api.covid19api.com/total/country/united-states"
  ];
  Future<bool> fetchComplete;
  Map<String, dynamic> _worldData;
  List<dynamic> _usData;
  Map<int, Widget> locations = const <int, Widget>{
    0: Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        "World",
      ),
    ),
    1: Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        "US",
      ),
    ),
  };
  int _locationIndex = 0; // defaut to World

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    await Future.wait(apiUrls.map((url) async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        if (url == apiUrls[1]) {
          setState(() {
            _usData = convert.jsonDecode(response.body);
          });
        } else {
          setState(() {
            _worldData = convert.jsonDecode(response.body);
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    }));
    fetchComplete = Future.value(true);
  }

  Widget dataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Confirmed cases"),
        SizedBox(height: 30),
        Text(
          _locationIndex == 0
              ? _worldData["Global"]["TotalConfirmed"].toString()
              : _usData.last["Confirmed"].toString(),
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        SizedBox(height: 30),
        Text("Total deaths"),
        SizedBox(height: 30),
        Text(
          _locationIndex == 0
              ? _worldData["Global"]["TotalDeaths"].toString()
              : _usData.last["Deaths"].toString(),
          style: TextStyle(
            fontSize: 24,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 30),
        Text("Total recovered"),
        SizedBox(height: 30),
        Text(
          _locationIndex == 0
              ? _worldData["Global"]["TotalRecovered"].toString()
              : _usData.last["Recovered"].toString(),
          style: TextStyle(
            fontSize: 24,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: CupertinoSegmentedControl(
            children: locations,
            onValueChanged: (int val) {
              setState(() {
                _locationIndex = val;
              });
            },
            selectedColor: Colors.white,
            unselectedColor: Colors.grey,
            groupValue: _locationIndex,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(20),
        child: FutureBuilder(
          future: fetchComplete,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return dataSection();
            } else if (snapshot.hasError) {
              return Text("An error has occurred.");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
