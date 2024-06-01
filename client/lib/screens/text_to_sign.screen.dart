import 'dart:developer';
import 'package:deafconnect/daos/avatar_messages.dao.dart';
import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/screens/avatar_history.screen.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/utils.dart';
import 'package:deafconnect/widgets/dialogs/avatar_background_dialog.dart';
import 'package:deafconnect/widgets/dialogs/choose_avatar_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../utils/animation_durations.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final Flutter3DController _avatarController = Flutter3DController();
  final TextEditingController _textfieldController = TextEditingController();
  final FocusNode _textfieldFocusNode = FocusNode();
  List<String> animations = [];
  String textToTranslate = '';
  int indexBeingTranslated = -1;
  bool _isAnimationPlaying = false;

  final SpeechToText speechToText = SpeechToText();
  String recognizedText = '';
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    initIdle();
  }

  initIdle() async {
    await Future.delayed(const Duration(seconds: 10));
    idle();
  }

  idle() {
    log('playing idle');
    _avatarController.playAnimation(animationName: 'Idle');
  }

  void translate() async {
    _isAnimationPlaying = true;
    // insert it to
    AvatarMessagesDAO.insertMessage(textToTranslate);

    getTextWidgets();
    if (animations.isEmpty) {
      animations = await _avatarController.getAvailableAnimations();
    }
    _textfieldController.clear();
    List<String> words = textToTranslate.split(' ');
    for (String word in words) {
      if (animations.contains(capitalizeFirstLetter(word))) {
        setState(() {
          indexBeingTranslated++;
        });
        _avatarController.playAnimation(
            animationName: capitalizeFirstLetter(word));
        await Future.delayed(
          animationsDurations[capitalizeFirstLetter(word)] ??
              const Duration(seconds: 2),
        );
      } else {
        // If animation for the entire word is not found, check each letter
        List<String> letters = word.split('');
        for (String letter in letters) {
          if (animations.contains(letter.toUpperCase())) {
            setState(() {
              indexBeingTranslated++;
            });
            _avatarController.playAnimation(
                animationName: letter.toUpperCase());
            await Future.delayed(
              animationsDurations[capitalizeFirstLetter(word)] ??
                  const Duration(seconds: 2),
            );
          } else {
            log('Animation for $letter not found');
          }
        }
      }
      _isAnimationPlaying = false;
    }
    setState(() {
      textToTranslate = '';
      indexBeingTranslated = -1;
    });
    _avatarController.pauseAnimation();
    idle();
  }

  List<Text> getTextWidgets() {
    List<Text> wordWidgets = [];
    List<String> words = textToTranslate.split(' ');
    int wordIndex = -1;
    for (var word in words) {
      if (animations.contains(capitalizeFirstLetter(word))) {
        wordIndex++;
        wordWidgets.add(customText(word, wordIndex));
      } else {
        List<String> letters = word.split('');
        for (String letter in letters) {
          wordIndex++;
          wordWidgets.add(customText(letter, wordIndex));
        }
      }
      wordWidgets.add(customText(' ', -1));
    }
    // remove last space because it was unnecessary
    wordWidgets.removeLast();
    return wordWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            'Text to Sign Language',
          ),
        ),
        body: Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: storeProvider.selectedBgImage.isEmpty
                          ? null
                          : DecorationImage(
                              image: AssetImage(
                                getPathFromValue(storeProvider.selectedBgImage),
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: 50,
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildWordsWidgets(),
                          ),
                        ),
                      ),
                      Consumer<StoreProvider>(
                        builder: (context, storeProvider, child) {
                          return Expanded(
                              child: Transform.scale(
                            scale: 1.8,
                            alignment: Alignment.topCenter,
                            child: Consumer<StoreProvider>(
                              builder: (context, storeProvider, child) {
                                return storeProvider.isFemale
                                    ? Flutter3DViewer(
                                        progressBarColor: mainColor,
                                        controller: _avatarController,
                                        src: 'assets/avatars/girl.glb',
                                      )
                                    : SizedBox(
                                        child: Flutter3DViewer(
                                          progressBarColor: mainColor,
                                          controller: _avatarController,
                                          src: 'assets/avatars/boy.glb',
                                        ),
                                      );
                              },
                            ),
                          )
                              // : Text('test')),
                              );
                        },
                      ),
                      Container(
                        color: secondaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Translate',
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextField(
                                    controller: _textfieldController,
                                    focusNode: _textfieldFocusNode,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.blue,
                                      suffixIconColor: Colors.blue,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: 'Type to translate...',
                                      hintStyle: TextStyle(
                                        color: lightGray,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (!isListening) {
                                      var available =
                                          await speechToText.initialize();
                                      if (available) {
                                        setState(() {
                                          isListening = true;
                                        });
                                        speechToText.listen(
                                            listenFor: const Duration(days: 1),
                                            onResult: (result) {
                                              setState(() {
                                                textToTranslate =
                                                    result.recognizedWords;
                                              });
                                            });
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mainColor,
                                    ),
                                    child: const Icon(
                                      Icons.mic,
                                      size: 25,
                                      color: Colors.white,
                                    ), // Send icon
                                  ),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    if (_textfieldController.text.isEmpty ||
                                        _isAnimationPlaying) return;
                                    _textfieldFocusNode.unfocus();
                                    setState(() {
                                      textToTranslate =
                                          _textfieldController.text;
                                    });
                                    translate();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mainColor,
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      size: 25,
                                      color: Colors.white,
                                    ), // Send icon
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, top: 10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showChooseAvatarDialog(context,
                                  onChange: () async {
                                await Future.delayed(
                                    const Duration(seconds: 3));
                                idle();
                              });
                            },
                            child: const Icon(
                              Icons.account_circle,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              showBackgroundsDialog(
                                context: context,
                                onChange: (value) {
                                  storeProvider.setBgImage(value);
                                },
                                bgImage: storeProvider.selectedBgImage,
                              );
                            },
                            child: const Icon(
                              Icons.image,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              String? message = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AvatarHistory(),
                                ),
                              );
                              if (message != null) {
                                setState(() {
                                  textToTranslate = message;
                                });
                                translate();
                              }
                            },
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Text> _buildWordsWidgets() {
    return getTextWidgets();
  }

  Text customText(String text, int index) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 21,
        color: index == indexBeingTranslated ? Colors.blue : Colors.black,
      ),
    );
  }
}
