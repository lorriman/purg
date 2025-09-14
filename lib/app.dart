import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purg/schedule.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
//import 'package:http/http.dart' as http;
//import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';

import 'driftModel.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Catholic purgatory avoidal app'),
    );
  }
}

snackBar(context, msg, {bool error = false}) {
  final snackBar = SnackBar(
      content: LayoutBuilder(
    builder: (context, constraints) => Row(children: [
      if (error)
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 50,
        ),
      if (error) SizedBox(width: 49),
      Container(
        width: constraints.maxWidth,
        child: Text(
          msg,
          textScaleFactor: 1.4,
          maxLines: 2,
          softWrap: true,
        ),
      )
    ]),
  ));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int temp = 0;
  late Future googleFontsPending;
  bool _androidNotificationsPermission = false;
  final _prayerViewScrollController = ScrollController(keepScrollOffset: true);
  final _pageStorageBucket = PageStorageBucket();

  final todos = {
    'Judge others':
        'Jesus said "Do not judge and you will not be judged.". We can pray to become non-judgy.',
    'Judge yourself':
        'Jesus said "Do not judge and you will not be judged" We can pray to become non-judgy.',
    'Be unmerciful':
        'Jesus said "Do not judge and you will not be judged"  We can pray to become non-judgy.',
    'Unforgiveness':
        'Jesus said "Do notasasa judge and you will not be judged" We can pray to become non-judgy.',
    'Not ask forgiveness':
        'Jesus said "Do stuff not judge and you will not be judged"',
    'Don\'t Reconcile': 'Jesus said "Do n ot judge and you will not be judged"',
    'Grumble when you suffer':
        'Jesus said "Do not judge and you will not be judged"',
    'Don\'t get masses said for your dead parents':
        'Jesus said "Do not judge and you will not be judged"',
    'Don\'t pray for sinners': '"saving a soul covers a multitude of sins"',
    'Forget the souls in purgatory':
        'Jesus said "Do not judge and you will not be judged"',
    'Only do the penance after confession, Don\'t make amends.':
        'Jesus said "Do not judge and you will not be judged"',
    'Don\'t try to be grateful': 'Sins of ommission,',
    'Do not judge12':
        'Jesus s  aid "Do not  cjudge and you will not be judged"',
    'Do not judge13':
        'Jesus 1offsaid "Do  not judge and you  will not be judged"',
    'Do not judge14':
        'Jesus said  "Do n ot    sbb         wcddjudge and you will not be judged"',
    'Do not judge15': 'Jesus said "Do n ot   judge and you will not be judged"',
  };

  Future<bool> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      print('notifications permission:' + granted.toString());
      return granted;
    }
    return false;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _androidNotificationsPermission =
            grantedNotificationPermission ?? false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _isAndroidPermissionGranted().then((value) {
      setState(() {
        _androidNotificationsPermission = value;
        if (!_androidNotificationsPermission)
          WidgetsBinding.instance!
              .addPostFrameCallback((_) => _requestPermissions());
      });
    });

//https://github.com/antijingoist/open-dyslexic
    googleFontsPending = GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.montserrat(fontStyle: FontStyle.italic),
    ]);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoTitleTextStyle = GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );

    final PrayerBodyTextStyle = GoogleFonts.fondamento(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );

    final todoItemTitleTextStyle = GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );
    final todoItemTextStyle = GoogleFonts.lato(
      //fontStyle: FontStyle.italic,
      textStyle: Theme.of(context).textTheme.headlineSmall,
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Consumer(
      builder: (context, ref, child) {
        final todoList = ref.watch(getTodoItemsProvider);
        return PageStorage(
          bucket: _pageStorageBucket,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                    labelStyle:
                        TextStyle(overflow: TextOverflow.visible, fontSize: 20),
                    tabs: [
                      Tab(text: 'prayer'),
                      Tab(text: 'todo'),
                      //Tab(text: 'schedule'),
                      Tab(text: 'merch')
                    ]),
                // TRY THIS: Try changing the color here to a specific color (to
                // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
                // change color while the other colors stay the same.
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.title),
                leading: _androidNotificationsPermission
                    ? null
                    : Icon(Icons.warning_amber_rounded),
              ),
              body: FutureBuilder(
                future: googleFontsPending,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    children: [
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SingleChildScrollView(
                          controller: _prayerViewScrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Let us pray.',
                                  style: PrayerBodyTextStyle.copyWith(
                                      color: Colors.redAccent)),
                              Text(
                                  style: PrayerBodyTextStyle,
                                  textAlign: TextAlign.center,
                                  ''
                                  '"Lorem ipsum dolor sit sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."'
                                  ''),
                            ],
                          ),
                        ),
                      )),
                      Center(
                          child: ListView(children: [
                        ListTile(
                            title: Text(
                                'How to stay in purgatory for a long time',
                                textScaleFactor: 2,
                                style: todoTitleTextStyle)),
                        for (final todoKey in todos.keys)
                          Card(
                              margin: EdgeInsets.all(8),
                              elevation: 7,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(todoKey,
                                        style: todoItemTitleTextStyle.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(todos[todoKey]!,
                                        style: todoItemTextStyle),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CheckboxMenuButton(
                                          value: true,
                                          onChanged: (val) async {
                                            snackBar(context,
                                                'scheduled: prayer against "${todoKey}"');
                                            if (kDebugMode) {
                                              //experiment
                                              for (int i = 0; i < 16; i++)
                                                int v = await compute((val) {
                                                  while (true) val = 1;
                                                  return 1;
                                                }, 1);
                                            }
                                          },
                                          child: Text('schedule prayer')),
                                      IconButton(
                                          icon:
                                              Icon(Icons.edit_calendar_rounded),
                                          onPressed: () async {
                                            final result =
                                                await showModalBottomSheet(
                                              constraints:
                                                  BoxConstraints(maxWidth: 750),
                                              isDismissible: true,
                                              // enableDrag: true,
                                              showDragHandle: true,
                                              //anchorPoint: Offset(0, 50 ),
                                              context: context,
                                              isScrollControlled: true,
                                              useSafeArea: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(40.0),
                                                    topRight:
                                                        Radius.circular(40.0)),
                                              ),
                                              //isScrollControlled: true,
                                              builder: (context) {
                                                return EditScheduleView();
                                                //return EditScheduleView();
                                              },
                                            );
                                            snackBar(
                                                context, result.toString());
                                          }),
                                    ],
                                  ),
                                ],
                              ))
                      ])),
                      //Center(child: Text('text')),
                      Center(
                        // Center is a layout widget. It takes a single child and positions it
                        // in the middle of the parent.
                        child: Column(
                          // Column is also a layout widget. It takes a list of children and
                          // arranges them vertically. By default, it sizes itself to fit its
                          // children horizontally, and tries to be as tall as its parent.
                          //
                          // Column has various properties to control how it sizes itself and
                          // how it positions its children. Here we use mainAxisAlignment to
                          // center the children vertically; the main axis here is the vertical
                          // axis because Columns are vertical (the cross axis would be
                          // horizontal).
                          //
                          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                          // action in the IDE, or press "p" in the console), to see the
                          // wireframe for each widget.
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'How many years off purgatory:',
                            ),
                            Text(
                              '$_counter',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            ),
          ),
        );
      },
    );
  }
}
