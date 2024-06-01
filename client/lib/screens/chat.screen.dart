import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/message.model.dart';
import 'package:deafconnect/models/transcript.model.dart';
import 'package:deafconnect/providers/shortcuts.provider.dart';
import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/providers/transcript.provider.dart';
import 'package:deafconnect/screens/shortcuts.screen.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/date_utils.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/widgets/chat/chatbox.dart';
import 'package:deafconnect/widgets/common/inkwell_with_opacity.dart';
import 'package:deafconnect/widgets/dialogs/transcript_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool isShortcutVisible = false;
  bool isListening = false;
  bool isLoadingMore = false;

  String recognizedText = '';

  Future speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();

    // Listen for changes in scroll position
    _scrollController.addListener(_scrollListener);

    // Fetch transcript data

    // Initialize text-to-speech functionality
    initTts();

    // Add a post frame callback to ensure that the widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Perform scroll operation after the first frame is drawn
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  Future _scrollListener() async {
    if (getTranscript() == null) {
      return;
    }
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      setState(() {
        isLoadingMore = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        TranscriptProvider transcriptProvider =
            Provider.of<TranscriptProvider>(context, listen: false);
        await transcriptProvider
            .loadMoreMessages(getTranscript()!.transcriptId);
      }
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    speechToText.cancel();
    _scrollController.dispose();
  }

  initTts() async {
    await flutterTts.awaitSpeakCompletion(true);

    if (Platform.isAndroid) {
      await flutterTts.getDefaultEngine;
      await flutterTts.getDefaultVoice;
      flutterTts.setInitHandler(() => setState(() {}));
    } else if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
          ],
          IosTextToSpeechAudioMode.defaultMode);
    }
  }

  sendMessage(String text, {required bool isReceived}) async {
    TranscriptProvider transcriptProvider =
        Provider.of<TranscriptProvider>(context, listen: false);

    // close keyboard
    _messageFocusNode.unfocus();
    // create new message
    transcriptProvider.addMessageToTranscript(
      message: text,
      transcriptId: getTranscript()!.transcriptId,
      isReceived: isReceived,
    );
    if (!isReceived) {
      speak(text);
      // clear message
      _messageController.text = '';
    }
    // scroll to the bottom
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  TranscriptDTO? getTranscript() {
    TranscriptProvider transcriptProvider =
        Provider.of<TranscriptProvider>(context, listen: false);
    StoreProvider storeProvider =
        Provider.of<StoreProvider>(context, listen: false);

    TranscriptDTO? transcript = transcriptProvider
        .getTranscriptById(storeProvider.selectedTranscriptId);

    // if transcript was not inirialized, we try to reinitialize it
    if (transcript == null && transcriptProvider.transcripts.isNotEmpty) {
      transcript = transcriptProvider.transcripts.last;
    }
    return transcript;
  }

  Future onTranscriptCreated(String text) async {
    if (text.isEmpty) return;
    TranscriptProvider transcriptProvider =
        Provider.of<TranscriptProvider>(context, listen: false);
    int id = await transcriptProvider.addTranscript(
      Transcript(
        transcriptId: 99, // anything, wont be stored in the db
        transcriptName: text,
        dateCreated: DateTime.now(),
      ),
    );
    // open it
    if (mounted) {
      StoreProvider storeProvider = Provider.of(context, listen: false);
      storeProvider.updateSelectedTranscriptId(id);
    }
    // transcript = getTranscript();
    if (!mounted) return;
    NavigationUtils.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          // to dismiss the keyboard when user presses on the screen
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            isShortcutVisible = false;
            setState(() {});
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: secondaryColor,
            appBar: AppBar(
              title: Column(
                children: [
                  const Text(
                    'Real-time Chat',
                  ),
                  if (getTranscript()?.transcriptName.isNotEmpty ?? false)
                    Column(
                      children: [
                        const SizedBox(height: 5),
                        Consumer<TranscriptProvider>(
                            builder: (context, transcriptProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              getTranscript()?.transcriptName ?? '',
                              style: TextStyle(
                                  color: Colors.grey[300], fontSize: 14),
                            ),
                          );
                        })
                      ],
                    ),
                ],
              ),
              actions: [
                InkwellWithOpacity(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return TranscriptDialog(onPressed: (text) async {
                          await onTranscriptCreated(text);
                        });
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.add,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Consumer<TranscriptProvider>(
                builder: (context, transcriptProvider, child) {
                  return getTranscript() == null
                      ? const Center(
                          child: Text('Create a transcript to start chatting.'),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child:
                                        _buildMessagesList(transcriptProvider),
                                  ),
                                ),
                              ),
                            ),
                            if (isListening && recognizedText.isNotEmpty)
                              Container(
                                height: 150,
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                color: Colors.white,
                                child: SingleChildScrollView(
                                    child: Text(recognizedText)),
                              ),
                            _buildMessageInput(),
                            AnimatedContainer(
                              height: isShortcutVisible ? 200 : 0,
                              width: double.infinity,
                              color: Colors.white,
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                children: [
                                  if (isShortcutVisible)
                                    Expanded(
                                      child: Consumer<ShortcutsProvider>(
                                        builder: (context, shortcutsProvider,
                                            child) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 11 / 2,
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 5,
                                              ),
                                              itemCount: shortcutsProvider
                                                  .shortcuts.length,
                                              itemBuilder: (context, index) {
                                                return InkwellWithOpacity(
                                                  onTap: () {
                                                    sendMessage(
                                                      shortcutsProvider
                                                          .shortcuts[index]
                                                          .shortcutName,
                                                      isReceived: false,
                                                    );
                                                  },
                                                  child: Text(
                                                    shortcutsProvider
                                                        .shortcuts[index]
                                                        .shortcutName,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  if (isShortcutVisible)
                                    InkwellWithOpacity(
                                      onTap: () {
                                        NavigationUtils.push(
                                          context,
                                          const ShortcutsScreen(),
                                        );
                                      },
                                      child: const Text(
                                        'Customize Shortcuts',
                                        style: TextStyle(color: mainColor),
                                      ),
                                    ),
                                  if (isShortcutVisible)
                                    const SizedBox(height: 2)
                                ],
                              ),
                            )
                          ],
                        );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(TranscriptProvider transcriptProvider) {
    if (getTranscript()!.messages.isEmpty) {
      return Container();
    }

    Map<DateTime, List<Message>> groupedMessages =
        groupMessagesByDate(getTranscript()!.messages);

    return Column(
      children: [
        if (isLoadingMore) const CupertinoActivityIndicator(color: mainColor),
        Column(
          children: groupedMessages.entries.map((entry) {
            DateTime date = entry.key;
            List<Message> transcripts = entry.value;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(formatDateTimeByDay(date)),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: transcripts.length,
                  itemBuilder: (context, index) {
                    return ChatBox(
                      text: transcripts[index].messageContent,
                      time:
                          DateFormat('hh:mm a').format(transcripts[index].date),
                      onPlay: () async {
                        await speak(transcripts[index].messageContent);
                      },
                      received: transcripts[index].isReceived,
                      showTail:
                          // if is last message
                          index == transcripts.length - 1
                              ? true // show tail always
                              :
                              // else, we check if it has a different isReceived than the next message, we show the tail
                              transcripts[index + 1].isReceived !=
                                  transcripts[index].isReceived,
                    );
                  },
                )
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return isListening
        ? Container(
            // height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: lightGray),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text('Press to'),
                    ),
                  ),
                ),
                Center(
                  child: AvatarGlow(
                    animate: isListening,
                    glowColor: mainColor,
                    repeat: true,
                    duration: const Duration(milliseconds: 2000),
                    child: _buildRoundedButton(
                      icon: Icons.mic,
                      size: 30,
                      isLarge: true,
                      onSubmit: () {
                        if (recognizedText.isNotEmpty) {
                          sendMessage(recognizedText, isReceived: true);
                        }
                        setState(() {
                          recognizedText = '';
                          isListening = false;
                        });
                        speechToText.stop();
                      },
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('stop recording'),
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: lightGray),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isShortcutVisible = !isShortcutVisible;
                      _messageFocusNode.unfocus();
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/icons/chat/shortcut.svg',
                    width: 30,
                    colorFilter: ColorFilter.mode(
                      isShortcutVisible ? mainColor : lightGray,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: _messageFocusNode,
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message here',
                      hintStyle: TextStyle(
                        color: lightGray,
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                _messageController.text.isEmpty
                    ? AvatarGlow(
                        animate: isListening,
                        duration: const Duration(milliseconds: 2000),
                        glowColor: mainColor,
                        repeat: true,
                        child: _buildRoundedButton(
                          icon: Icons.mic,
                          size: 25,
                          onSubmit: () async {
                            if (!isListening) {
                              var available = await speechToText.initialize();
                              if (available) {
                                setState(() {
                                  isListening = true;
                                });
                                speechToText.listen(
                                    listenFor: const Duration(days: 1),
                                    onResult: (result) {
                                      setState(() {
                                        recognizedText = result.recognizedWords;
                                      });
                                    });
                              }
                            }
                          },
                        ),
                      )
                    : _buildRoundedButton(
                        icon: Icons.send,
                        size: 20,
                        onSubmit: () async {
                          sendMessage(
                            _messageController.text,
                            isReceived: false,
                          );
                        },
                      )
              ],
            ),
          );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    required double size,
    required Function onSubmit,
    bool isLarge = false,
  }) {
    return InkwellWithOpacity(
      onTap: () {
        onSubmit();
      },
      child: Container(
        width: isLarge ? 45 : 35,
        height: isLarge ? 45 : 35,
        decoration: const BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: whiteColor,
          size: size,
        ),
      ),
    );
  }
}
