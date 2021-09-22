import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/flutter_jigsaw_puzzle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        ),
        textTheme: Typography.englishLike2018,
      ).copyWith(
        splashFactory: InkRipple.splashFactory,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await puzzleKey.currentState!.generate();
                      },
                      child: const Text('Generate'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        puzzleKey.currentState!.reset();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                JigsawPuzzle(
                  gridSize: 10,
                  image: const AssetImage('assets/Jigsaw.jpg'),
                  onFinished: () {
                    // ignore: avoid_print
                    print('finished!');
                  },
                  puzzleKey: puzzleKey,
                  onBlockSuccess: () {
                    // ignore: avoid_print
                    print('block success!');
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
