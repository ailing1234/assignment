import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> activities = [
    "Any type",
    "education",
    "recreational",
    "social",
    "diy",
    "charity",
    "cooking",
    "relaxation",
    "music",
    "busywork"
  ];

  String? activity;
  String? actType;

  List<String> selectedActivities = [];
  String selectedActivity = '';

  String titleCase(String input) {
    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
    }
    return words.join(' ');
  }

  // ignore: prefer_final_fields
  GlobalKey _listViewKey = GlobalKey();
  BuildContext? selectedTile;

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchActivities(String type) async {
    String fullUrl = 'https://www.boredapi.com/api/activity?type=' + type;
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        actType = data["type"];
        activity = data["activity"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void scrollToSelectedIndex(int index, BuildContext context) {
    const double itemHeight = 50; // change this to your item height
    final double centerOffset =
        MediaQuery.of(context).size.height / 2 - itemHeight / 2;
    _scrollController.animateTo(
      index * itemHeight - centerOffset,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Bored API'),
            ),
            body: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'What I can do when I am bored?',
                ),
                const SizedBox(height: 8),
                actType != null
                    ? Card(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(activity ?? ""),
                              const SizedBox(height: 8),
                              Text(actType != null ? "Type: $actType" : ""),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 8),
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      return ListView.builder(
                        controller: _scrollController,
                        key: _listViewKey,
                        itemCount: activities.length,
                        itemBuilder: (BuildContext context, int index) {
                          String titleCaseActivity =
                              titleCase(activities[index]);
                          return ListTile(
                            title: Text(
                              titleCaseActivity,
                              style: selectedActivity == titleCaseActivity
                                  ? const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      decorationColor: Colors.blue,
                                      decorationThickness: 2.0,
                                      height: 1.5,
                                    )
                                  : const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      height: 1.2,
                                    ),
                            ),
                            selected: selectedActivity == titleCaseActivity,
                            selectedTileColor: Colors.blue.withOpacity(0.1),
                            onTap: () {
                              setState(() {
                                if (titleCaseActivity.toLowerCase() ==
                                    "any type") {
                                  titleCaseActivity = "";
                                }
                                fetchActivities(
                                    titleCaseActivity.toLowerCase());
                                selectedActivity = titleCaseActivity;
                                if (titleCaseActivity == "") {
                                  selectedActivity = "Any Type";
                                }
                                // scrollToSelectedIndex(index, context);
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          int randomIndex = Random().nextInt(activities.length);
                          String titleCaseActivity =
                              titleCase(activities[randomIndex]);
                          if (titleCaseActivity.toLowerCase() == "any type") {
                            titleCaseActivity = "";
                          }
                          fetchActivities(titleCaseActivity.toLowerCase());
                          selectedActivity = titleCaseActivity;
                          if (titleCaseActivity == "") {
                            selectedActivity = "Any Type";
                          }
                          scrollToSelectedIndex(randomIndex,
                              context); // Pass the BuildContext to the function
                        });
                      },
                      child: const Text("Random Activity"),
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}
