import 'package:cam_flutter_challenge/data.dart';
import 'package:cam_flutter_challenge/user.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double opacity = 1.0;
  double containerTop = -180.0;
  bool isFrontCamara = false;

  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        isFrontCamara ? widget.cameras[1] : widget.cameras[0],
        ResolutionPreset.high,
      );
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  void toggleCamera() {
    _controller = CameraController(
      isFrontCamara ? widget.cameras[1] : widget.cameras[0],
      ResolutionPreset.high,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Stack(
        children: [
          Positioned(
            top: containerTop,
            left: 80,
            right: 80,
            child: Container(
              width: 180.0,
              height: 180.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  color: Colors.yellow,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CameraPreview(_controller),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 120.0),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity,
                child: const Text(
                  'Pull down to reveal the camara',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity,
                child: SvgPicture.asset(
                  'images/arrow.svg',
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                height: 180.0,
                child: ListView.builder(
                  itemCount: listUser.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 100.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Center(
                          child: Draggable(
                            onDraggableCanceled: (velocity, offset) {
                              setState(() {
                                opacity = 1.0;
                                containerTop = -180.0;
                                isFrontCamara = false;
                                toggleCamera();
                              });
                            },
                            onDragUpdate: (details) {
                              setState(() {
                                double newValor =
                                    opacity * (1.0 - details.delta.dy);
                                if (newValor < 0.0) {
                                  opacity = 0.0;
                                } else {
                                  opacity = newValor;
                                }

                                containerTop = containerTop + details.delta.dy;
                              });
                              if (details.delta.dy.isNegative &&
                                  !isFrontCamara) {
                                setState(() {
                                  isFrontCamara = true;
                                  toggleCamera();
                                });
                              }
                            },
                            childWhenDragging: const SizedBox(
                              width: 80.0,
                              height: 80.0,
                            ),
                            axis: Axis.vertical,
                            maxSimultaneousDrags: 1,
                            feedback: CircleUserWidget(user: listUser[index]),
                            data: index,
                            child: CircleUserWidget(user: listUser[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircleUserWidget extends StatelessWidget {
  final User user;
  const CircleUserWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: Image(
            image: AssetImage(user.image),
            fit: BoxFit.cover,
            height: 80.0,
            width: 80.0,
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
