library jigsaw_puzzle;

import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'dart:math' as math;

class JigsawPuzzle extends StatefulWidget {
  final int gridSize;
  final Function() onFinished;
  final Function() onBlockSuccess;
  final AssetImage image;
  final Color backgroundColor;
  final bool autoStart;
  final bool outlineCanvas;
  final double sensitivity;
  final GlobalKey<JigsawWidgetState> puzzleKey;

  JigsawPuzzle({
    Key key,
    @required this.gridSize,
    @required this.image,
    @required this.puzzleKey,
    this.backgroundColor,
    this.onFinished,
    this.onBlockSuccess,
    this.outlineCanvas,
    this.autoStart = false,
    this.sensitivity = .5,
  }) : super(key: key);

  @override
  _JigsawPuzzleState createState() => _JigsawPuzzleState();
}

class _JigsawPuzzleState extends State<JigsawPuzzle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16),
        Container(
          child: JigsawWidget(
            callbackFinish: () {
              if (widget.onFinished != null) {
                widget.onFinished();
              }
            },
            callbackSuccess: () {
              if (widget.onBlockSuccess != null) {
                widget.onBlockSuccess();
              }
            },
            key: widget.puzzleKey,
            gridSize: widget.gridSize,
            sensitivity: widget.sensitivity,
            outlineCanvas: widget.outlineCanvas,
            child: Image(
              fit: BoxFit.contain,
              image: widget.image,
            ),
          ),
        ),
      ],
    );
  }
}

class JigsawWidget extends StatefulWidget {
  final Widget child;
  final Function() callbackSuccess;
  final Function() callbackFinish;
  final int gridSize;
  final bool outlineCanvas;
  final double sensitivity;

  JigsawWidget({
    Key key,
    @required this.gridSize,
    @required this.sensitivity,
    @required this.child,
    this.callbackFinish,
    this.callbackSuccess,
    this.outlineCanvas,
  }) : super(key: key);

  @override
  JigsawWidgetState createState() => JigsawWidgetState();
}

class JigsawWidgetState extends State<JigsawWidget> {
  GlobalKey _globalKey = GlobalKey();
  ui.Image fullImage;
  Size size;

  List<List<BlockClass>> images = <List<BlockClass>>[];
  ValueNotifier<List<BlockClass>> blocksNotifier =
      new ValueNotifier<List<BlockClass>>(<BlockClass>[]);
  CarouselController _carouselController;

  Offset _pos = Offset.zero;
  int _index;

  _getImageFromWidget() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();

    size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    return ui.decodeImage(pngBytes);
  }

  reset() {
    images.clear();
    blocksNotifier = new ValueNotifier<List<BlockClass>>(<BlockClass>[]);
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  Future<void> generate() async {
    images = [[]];

    if (fullImage == null) fullImage = await _getImageFromWidget();

    int xSplitCount = widget.gridSize;
    int ySplitCount = widget.gridSize;

    double widthPerBlock = fullImage.width / xSplitCount;
    double heightPerBlock = fullImage.height / ySplitCount;

    for (var y = 0; y < ySplitCount; y++) {
      List tempImages = <BlockClass>[];

      images.add(tempImages);
      for (var x = 0; x < xSplitCount; x++) {
        int randomPosRow = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;
        int randomPosCol = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;

        Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

        ClassJigsawPos jigsawPosSide = new ClassJigsawPos(
          bottom: y == ySplitCount - 1 ? 0 : randomPosCol,
          left: x == 0
              ? 0
              : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
          right: x == xSplitCount - 1 ? 0 : randomPosRow,
          top: y == 0
              ? 0
              : -images[y - 1][x].jigsawBlockWidget.imageBox.posSide.bottom,
        );

        double xAxis = widthPerBlock * x;
        double yAxis = heightPerBlock * y;

        double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

        offsetCenter = Offset(
          (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
          (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
        );

        xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
        yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

        double widthPerBlockTemp = widthPerBlock +
            (jigsawPosSide.left == 1 ? minSize : 0) +
            (jigsawPosSide.right == 1 ? minSize : 0);
        double heightPerBlockTemp = heightPerBlock +
            (jigsawPosSide.top == 1 ? minSize : 0) +
            (jigsawPosSide.bottom == 1 ? minSize : 0);

        ui.Image temp = ui.copyCrop(
          fullImage,
          xAxis.round(),
          yAxis.round(),
          widthPerBlockTemp.round(),
          heightPerBlockTemp.round(),
        );

        Offset offset = Offset(size.width / 2 - widthPerBlockTemp / 2,
            size.height / 2 - heightPerBlockTemp / 2);

        ImageBox imageBox = new ImageBox(
          image: Image.memory(
            ui.encodePng(temp),
            fit: BoxFit.contain,
          ),
          isDone: false,
          offsetCenter: offsetCenter,
          posSide: jigsawPosSide,
          radiusPoint: minSize,
          size: Size(widthPerBlockTemp, heightPerBlockTemp),
        );

        images[y].add(
          new BlockClass(
              jigsawBlockWidget: JigsawBlockWidget(
                imageBox: imageBox,
              ),
              offset: offset,
              offsetDefault: Offset(xAxis, yAxis)),
        );
      }
    }

    blocksNotifier.value = images.expand((image) => image).toList();
    blocksNotifier.value.shuffle();
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  @override
  void initState() {
    _index = 0;
    _carouselController = new CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeBox = MediaQuery.of(context).size;

    return ValueListenableBuilder(
        valueListenable: blocksNotifier,
        builder: (context, List<BlockClass> blocks, child) {
          List<BlockClass> blockNotDone = blocks
              .where((block) => !block.jigsawBlockWidget.imageBox.isDone)
              .toList();
          List<BlockClass> blockDone = blocks
              .where((block) => block.jigsawBlockWidget.imageBox.isDone)
              .toList();

          return Container(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.infinity,
                      child: Listener(
                        onPointerUp: (event) {
                          if (blockNotDone.length == 0) {
                            reset();
                            widget.callbackFinish.call();
                          }

                          if (_index == null) {
                            _carouselController.nextPage(
                                duration: Duration(microseconds: 600));
                            setState(() {});
                          }
                        },
                        onPointerMove: (event) {
                          if (_index == null) return;
                          if (blockNotDone.length == 0) return;

                          Offset offset = event.localPosition - _pos;

                          blockNotDone[_index].offset = offset;

                          final minSensitivity = 0;
                          final maxSensitivity = 1;
                          final maxDistanceThreshold = 20;
                          final minDistanceThreshold = 1;

                          final sensitivity = widget.sensitivity;
                          final distanceThreshold = sensitivity *
                                  (maxSensitivity - minSensitivity) *
                                  (maxDistanceThreshold -
                                      minDistanceThreshold) +
                              minDistanceThreshold;

                          if ((blockNotDone[_index].offset -
                                      blockNotDone[_index].offsetDefault)
                                  .distance <
                              distanceThreshold) {
                            blockNotDone[_index]
                                .jigsawBlockWidget
                                .imageBox
                                .isDone = true;

                            blockNotDone[_index].offset =
                                blockNotDone[_index].offsetDefault;

                            _index = null;

                            blocksNotifier.notifyListeners();

                            widget.callbackSuccess.call();
                          }

                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            if (blocks.length == 0) ...[
                              RepaintBoundary(
                                key: _globalKey,
                                child: Container(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: widget.child,
                                ),
                              )
                            ],
                            Offstage(
                              offstage: !(blocks.length > 0),
                              child: Container(
                                color: Colors.white,
                                width: size?.width,
                                height: size?.height,
                                child: CustomPaint(
                                  painter: JigsawPainterBackground(
                                    blocks,
                                    widget.outlineCanvas != null
                                        ? widget.outlineCanvas
                                        : true,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (blockDone.length > 0)
                                        ...blockDone.map(
                                          (map) {
                                            return Positioned(
                                              left: map.offset.dx,
                                              top: map.offset.dy,
                                              child: Container(
                                                child: map.jigsawBlockWidget,
                                              ),
                                            );
                                          },
                                        ),
                                      if (blockNotDone.length > 0)
                                        ...blockNotDone.asMap().entries.map(
                                          (map) {
                                            return Positioned(
                                              left: map.value.offset.dx,
                                              top: map.value.offset.dy,
                                              child: Offstage(
                                                offstage: !(_index == map.key),
                                                child: GestureDetector(
                                                  onTapDown: (details) {
                                                    if (map
                                                        .value
                                                        .jigsawBlockWidget
                                                        .imageBox
                                                        .isDone) return;

                                                    setState(() {
                                                      _pos =
                                                          details.localPosition;
                                                      _index = map.key;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: map.value
                                                        .jigsawBlockWidget,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      height: 120,
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          initialPage: _index,
                          height: 80,
                          aspectRatio: 1,
                          viewportFraction: 0.3,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          disableCenter: false,
                          onPageChanged: (index, reason) {
                            _index = index;
                            setState(() {});
                          },
                        ),
                        items: blockNotDone.map((block) {
                          Size sizeBlock =
                              block.jigsawBlockWidget.imageBox.size;
                          return FittedBox(
                            child: Container(
                              width: sizeBlock.width,
                              height: sizeBlock.height,
                              child: block.jigsawBlockWidget,
                            ),
                          );
                        }).toList(),
                      ))
                ],
              ),
            ),
          );
        });
  }
}

class JigsawPainterBackground extends CustomPainter {
  List<BlockClass> blocks;
  bool outlineCanvas;

  JigsawPainterBackground(this.blocks, [this.outlineCanvas = true]);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..style = outlineCanvas ? PaintingStyle.stroke : PaintingStyle.fill
      ..color = Colors.black12
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    Path path = new Path();

    this.blocks.forEach((element) {
      Path pathTemp = getPiecePath(
        element.jigsawBlockWidget.imageBox.size,
        element.jigsawBlockWidget.imageBox.radiusPoint,
        element.jigsawBlockWidget.imageBox.offsetCenter,
        element.jigsawBlockWidget.imageBox.posSide,
      );

      path.addPath(pathTemp, element.offsetDefault);
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BlockClass {
  Offset offset;
  Offset offsetDefault;
  JigsawBlockWidget jigsawBlockWidget;

  BlockClass({
    this.offset,
    this.jigsawBlockWidget,
    this.offsetDefault,
  });
}

class ImageBox {
  Widget image;
  ClassJigsawPos posSide;
  Offset offsetCenter;
  Size size;
  double radiusPoint;
  bool isDone;

  ImageBox({
    this.image,
    this.posSide,
    this.isDone,
    this.offsetCenter,
    this.radiusPoint,
    this.size,
  });
}

class ClassJigsawPos {
  int top, bottom, left, right;

  ClassJigsawPos({this.top, this.bottom, this.left, this.right});
}

class JigsawBlockWidget extends StatefulWidget {
  final ImageBox imageBox;
  JigsawBlockWidget({Key key, this.imageBox}) : super(key: key);

  @override
  _JigsawBlockWidgetState createState() => _JigsawBlockWidgetState();
}

class _JigsawBlockWidgetState extends State<JigsawBlockWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PuzzlePieceClipper(imageBox: widget.imageBox),
      child: CustomPaint(
        foregroundPainter: JigsawBlokPainter(imageBox: widget.imageBox),
        child: widget.imageBox.image,
      ),
    );
  }
}

class JigsawBlokPainter extends CustomPainter {
  ImageBox imageBox;

  JigsawBlokPainter({
    this.imageBox,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color =
          this.imageBox.isDone ? Colors.white.withOpacity(0.2) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
        getPiecePath(size, this.imageBox.radiusPoint,
            this.imageBox.offsetCenter, this.imageBox.posSide),
        paint);

    if (this.imageBox.isDone) {
      Paint paintDone = new Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      canvas.drawPath(
          getPiecePath(size, this.imageBox.radiusPoint,
              this.imageBox.offsetCenter, this.imageBox.posSide),
          paintDone);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PuzzlePieceClipper extends CustomClipper<Path> {
  ImageBox imageBox;
  PuzzlePieceClipper({
    this.imageBox,
  });
  @override
  Path getClip(Size size) {
    return getPiecePath(size, this.imageBox.radiusPoint,
        this.imageBox.offsetCenter, this.imageBox.posSide);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

getPiecePath(
  Size size,
  double radiusPoint,
  Offset offsetCenter,
  ClassJigsawPos posSide,
) {
  Path path = new Path();

  Offset topLeft = Offset(0, 0);
  Offset topRight = Offset(size.width, 0);
  Offset bottomLeft = Offset(0, size.height);
  Offset bottomRight = Offset(size.width, size.height);

  topLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topLeft;
  topRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topRight;
  bottomRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomRight;
  bottomLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomLeft;

  double topMiddle = posSide.top == 0
      ? topRight.dy
      : (posSide.top > 0
          ? topRight.dy - radiusPoint
          : topRight.dy + radiusPoint);
  double bottomMiddle = posSide.bottom == 0
      ? bottomRight.dy
      : (posSide.bottom > 0
          ? bottomRight.dy + radiusPoint
          : bottomRight.dy - radiusPoint);
  double leftMiddle = posSide.left == 0
      ? topLeft.dx
      : (posSide.left > 0
          ? topLeft.dx - radiusPoint
          : topLeft.dx + radiusPoint);
  double rightMiddle = posSide.right == 0
      ? topRight.dx
      : (posSide.right > 0
          ? topRight.dx + radiusPoint
          : topRight.dx - radiusPoint);

  path.moveTo(topLeft.dx, topLeft.dy);

  if (posSide.top != 0)
    path.extendWithPath(
        calculatePoint(Axis.horizontal, topLeft.dy,
            Offset(offsetCenter.dx, topMiddle), radiusPoint),
        Offset.zero);
  path.lineTo(topRight.dx, topRight.dy);

  if (posSide.right != 0)
    path.extendWithPath(
        calculatePoint(Axis.vertical, topRight.dx,
            Offset(rightMiddle, offsetCenter.dy), radiusPoint),
        Offset.zero);
  path.lineTo(bottomRight.dx, bottomRight.dy);

  if (posSide.bottom != 0)
    path.extendWithPath(
        calculatePoint(Axis.horizontal, bottomRight.dy,
            Offset(offsetCenter.dx, bottomMiddle), -radiusPoint),
        Offset.zero);
  path.lineTo(bottomLeft.dx, bottomLeft.dy);

  if (posSide.left != 0)
    path.extendWithPath(
        calculatePoint(Axis.vertical, bottomLeft.dx,
            Offset(leftMiddle, offsetCenter.dy), -radiusPoint),
        Offset.zero);
  path.lineTo(topLeft.dx, topLeft.dy);

  path.close();

  return path;
}

calculatePoint(Axis axis, double fromPoint, Offset point, double radiusPoint) {
  Path path = new Path();

  if (axis == Axis.horizontal) {
    path.moveTo(point.dx - radiusPoint / 2, fromPoint);
    path.lineTo(point.dx - radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, fromPoint);
  } else if (axis == Axis.vertical) {
    path.moveTo(fromPoint, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy + radiusPoint / 2);
    path.lineTo(fromPoint, point.dy + radiusPoint / 2);
  }

  return path;
}
