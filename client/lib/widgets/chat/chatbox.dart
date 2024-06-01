import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_svg/svg.dart';

class ChatBox extends StatefulWidget {
  final String text;
  final bool received;
  final bool showTail;
  final String time;
  final Function onPlay;

  const ChatBox({
    super.key,
    required this.text,
    required this.showTail,
    required this.time,
    required this.onPlay,
    this.received = false,
  });

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.received) {
          isSpeakingNotifier.value = true;
          await widget.onPlay();
          isSpeakingNotifier.value = false;
        }
      },
      child: Row(
        mainAxisAlignment:
            widget.received ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 5, horizontal: widget.showTail ? 10 : 15),
            child: ChatBubble(
              backGroundColor: widget.received ? whiteColor : mainColor,
              clipper: widget.showTail
                  ? ChatBubbleClipper3(
                      type: widget.received
                          ? BubbleType.receiverBubble
                          : BubbleType.sendBubble,
                    )
                  : ChatBubbleClipper5(
                      type: widget.received
                          ? BubbleType.receiverBubble
                          : BubbleType.sendBubble,
                    ),
              child: Container(
                padding: const EdgeInsets.only(left: 5, top: 2, right: 5),
                color: widget.received ? whiteColor : mainColor,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    widget.received ? blackColor : whiteColor,
                              ),
                            ),
                          ),
                          if (!widget.received)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ValueListenableBuilder(
                                valueListenable: isSpeakingNotifier,
                                builder: (context, isSpeaking, child) {
                                  return SvgPicture.asset(
                                    isSpeaking
                                        ? 'assets/icons/chat/sound_on.svg'
                                        : 'assets/icons/chat/sound_off.svg',
                                    width: 15,
                                    colorFilter: const ColorFilter.mode(
                                      whiteColor,
                                      BlendMode.srcIn,
                                    ),
                                  );
                                },
                              ),
                            )
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.received
                              ? blackColor.withOpacity(0.5)
                              : whiteColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
