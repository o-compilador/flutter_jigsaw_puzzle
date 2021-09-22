# flutter_jigsaw_puzzle

A Flutter jigsaw puzzle view that supports custom grids of varying sizes.

<img src="https://user-images.githubusercontent.com/8173268/134375943-25c51a10-b4d1-4d00-af1d-d306ce0bf2e8.mp4" height="400"/>

## Features

* Create a jigsaw puzzle from any `AssetImage`
* Configurable grid size (2x2, 3x3, 4x4, 5x5, 6x6, ...)
* Separate callbacks for when each block gets snapped and for when the puzzle is completed

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_jigsaw_puzzle: <latest_version>
```

In your library add the following import:

```dart
import 'package:flutter_jigsaw_puzzle/flutter_jigsaw_puzzle.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Example

### 3x3
<img src="https://user-images.githubusercontent.com/8173268/134377301-6d3ec05b-f932-47a5-9f33-65672a20c2dc.mp4" height="400"/>

### 5x5
<img src="https://user-images.githubusercontent.com/8173268/134375943-25c51a10-b4d1-4d00-af1d-d306ce0bf2e8.mp4" height="400"/>

### 10x10
<img src="https://user-images.githubusercontent.com/8173268/134377476-60d65364-2fb0-491c-a0e4-4b309db3b238.mp4" height="400"/>


```dart
final puzzleKey = GlobalKey<JigsawWidgetState>();

Column(
  children: [
    ElevatedButton(
      onPressed: () async {
        await puzzleKey.currentState.generate();
      },
      child: const Text('Generate'),
    ),
    JigsawPuzzle(
      gridSize: 10,
      image: const AssetImage('assets/Jigsaw.jpg'),
      onFinished: () {
        // ignore: avoid_print
        print('finished!');
      },
      snapSensitivity: .5, // Between 0 and 1
      puzzleKey: puzzleKey,
      onBlockSuccess: () {
        // ignore: avoid_print
        print('block success!');
      },
    )
  ],
),
```

You can find a working example in the [Example](https://github.com/o-compilador/flutter_jigsaw_puzzle/tree/master/example) project.

## Changelog

Please see the [Changelog](https://github.com/o-compilador/flutter_jigsaw_puzzle/blob/master/CHANGELOG.md) page to know what's recently changed.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/o-compilador/flutter_jigsaw_puzzle/issues).  
If you fixed a bug or implemented a new feature, please send a [pull request](https://github.com/o-compilador/flutter_jigsaw_puzzle/pulls).

## TODO
* Tests
* Animations