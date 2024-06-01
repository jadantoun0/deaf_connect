import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:deafconnect/main.dart';
import 'package:deafconnect/utils/handlandmarks_painter.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoSignScreen extends StatefulWidget {
  final String letter;
  const DoSignScreen({super.key, required this.letter});

  @override
  State<DoSignScreen> createState() => _DoSignScreenState();
}

class _DoSignScreenState extends State<DoSignScreen> {
  bool _isLoading = true;
  CameraController? _controller;
  Future? _initializeControllerFuture;
  String prediction = '';
  double confidence = 0.0;
  Timer? timer;
  String predictedText = '';
  List<dynamic> handLandmarks = [];
  bool sending = false;
  bool moveToNextPage = false;

  final GlobalKey _alertKey = GlobalKey();

  late CameraDescription selfieCamera;
  late CameraDescription backCamera;
  late CameraDescription selectedCamera;

  @override
  void initState() {
    super.initState();

    selfieCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    selectedCamera = selfieCamera;
    _initializeCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAvatarDialog();
    });
  }

  Future _initializeCamera() async {
    log('INITIALIZING CAMERA IN NEW PAGE');
    _controller?.dispose();
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _controller!.initialize();
    await _initializeControllerFuture;
    sending = false;
    _startSendingFrames();
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleCamera() {
    setState(() {
      selectedCamera =
          selectedCamera == selfieCamera ? backCamera : selfieCamera;
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    log('CAMERA DISPOSED');
    _controller?.dispose();
    timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letter ${widget.letter} in ASL'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      if (_controller != null)
                        SizedBox(
                          height: double.infinity,
                          child: CameraPreview(
                            _controller!,
                          ),
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CustomPaint(
                          painter: HandLandmarksPainter(
                            handLandmarks: handLandmarks,
                            prediction: prediction,
                            confidence: confidence,
                            drawLandmarks: false,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton(
                          onPressed: _toggleCamera,
                          child: const Icon(Icons.switch_camera),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: InkWell(
                              onTap: () => showAvatarDialog(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Text(
                                    "Show Sign",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            // moveToNextPage = true;
                            _controller?.dispose();
                            NavigationUtils.pushReplacement(
                              context,
                              DoSignScreen(
                                letter: getNextLetterForLetter(widget.letter),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10.0, bottom: 15),
                            child: Icon(
                              Icons.keyboard_double_arrow_right_sharp,
                              color: Colors.blue,
                              size: 45,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future _startSendingFrames() async {
    // Start a timer to send frames periodically
    timer =
        Timer.periodic(const Duration(milliseconds: 10), (Timer timer) async {
      await _sendFrameToServer();
    });
  }

  Future<void> _sendFrameToServer() async {
    if (sending) return;

    sending = true;
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      XFile imageFile = await _controller!.takePicture();

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      Uri uri = Uri.parse(flaskUrl);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': base64Image}),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      log('response is $data');

      // Apply autocorrection to the predicted text
      setState(() {
        prediction = data['prediction'] ?? '';
        confidence = double.tryParse(data['confidence'].toString()) ?? 0;
        predictedText += prediction;
        handLandmarks = data['hand_landmarks'] ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        prediction = '';
        confidence = 0;
        handLandmarks = [];
      });
      log('Error sending frame to server: $e');
    } finally {
      if (moveToNextPage && mounted) {
        _controller?.dispose();
        NavigationUtils.pop(context);
        NavigationUtils.push(
          context,
          DoSignScreen(
            letter: getNextLetterForLetter(widget.letter),
          ),
        );
      } else {
        sending = false;
      }
    }
  }

  void showAvatarDialog() async {
    log('started');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: _alertKey,
          contentPadding: EdgeInsets.zero,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                'Letter ${widget.letter} in ASL',
                style: const TextStyle(fontSize: 18),
              ),
              GestureDetector(
                onTap: () {
                  NavigationUtils.pop(context);
                },
                child: const Icon(Icons.close),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.only(top: 10),
            width: double.infinity,
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.asset(
                    'assets/gifs/${widget.letter.toUpperCase()}.gif')),
          ),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 5));
    log('5s passed');
    if (!mounted) return;
    if (_alertKey.currentContext != null) {
      log('poppping');
      NavigationUtils.pop(context);
    }
  }
}
