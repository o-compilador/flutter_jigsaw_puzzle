import 'package:flutter/material.dart';

import '../lib/jigsaw_puzzle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final puzzleKey = GlobalKey<JigsawWidgetState>();

    return MaterialApp(
      title: 'Jigsaw',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          primaryColorDark: Colors.blueGrey.shade700,
          backgroundColor: Colors.blueGrey.shade100,
          cardColor: Colors.yellow,
          errorColor: Colors.orange,
          brightness: Brightness.light,
        ),
        textTheme: Typography.englishLike2018,
      ).copyWith(
        splashFactory: InkRipple.splashFactory,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await puzzleKey.currentState.generate();
                        },
                        child: Text("Generate"),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await puzzleKey.currentState.reset();
                        },
                        child: Text("Clear"),
                      ),
                    ],
                  ),
                ),
                JigsawPuzzle(
                  gridSize: 5,
                  image: AssetImage("./assets/Jigsaw.jpg"),
                  onFinished: () {
                    print("finished!");
                  },
                  puzzleKey: puzzleKey,
                  onBlockSuccess: () {
                    print("block success!");
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
