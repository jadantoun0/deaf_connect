import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/transcript.model.dart';
import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/providers/transcript.provider.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/date_utils.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/widgets/common/inkwell_with_opacity.dart';
import 'package:deafconnect/widgets/dialogs/transcript_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class TranscriptBox extends StatefulWidget {
  final TranscriptDTO transcriptDTO;

  const TranscriptBox(this.transcriptDTO, {super.key});

  @override
  State<TranscriptBox> createState() => _TranscriptBoxState();
}

class _TranscriptBoxState extends State<TranscriptBox> {
  final ValueNotifier<bool> isDeletingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      groupTag: '0',
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          ValueListenableBuilder(
            valueListenable: isDeletingNotifier,
            builder: (context, isDeleting, child) {
              return SlidableAction(
                padding: EdgeInsets.zero,
                onPressed: (context) async {
                  isDeletingNotifier.value = true;
                  TranscriptProvider transcriptProvider =
                      Provider.of<TranscriptProvider>(context, listen: false);
                  await transcriptProvider
                      .deleteTranscript(widget.transcriptDTO.transcriptId);
                  isDeletingNotifier.value = false;
                },
                backgroundColor:
                    !isDeleting ? Colors.red : Colors.red.withOpacity(0.8),
                label: 'Delete',
              );
            },
          ),
        ],
      ),
      child: InkwellWithOpacity(
        onTap: () {
          StoreProvider storeProvider =
              Provider.of<StoreProvider>(context, listen: false);
          // 1. update selected transcript
          storeProvider
              .updateSelectedTranscriptId(widget.transcriptDTO.transcriptId);
          // 2. navigate to chat page
          storeProvider.updateSelectedTab(0); // navigate to chat screen
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SvgPicture.asset(
              'assets/icons/transcript/transcript.svg',
              width: 45,
            ),
            title: Text(
              widget.transcriptDTO.transcriptName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.transcriptDTO.messages.isNotEmpty)
                  Text(widget.transcriptDTO.messages.last.messageContent),
                Text(
                  formatDateTime(getLatestDate(widget.transcriptDTO)),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Builder(builder: (context) {
              return GestureDetector(
                onTap: () {
                  showPopover(
                      context: context,
                      width: 80,
                      arrowHeight: 10,
                      arrowWidth: 10,
                      bodyBuilder: (context) {
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              NavigationUtils.pop(context);
                            }
                            showDialog(
                              context: context,
                              builder: (context) {
                                return TranscriptDialog(
                                  transcriptDTO: widget.transcriptDTO,
                                  onPressed: (text) async {
                                    TranscriptProvider transcriptProvider =
                                        Provider.of<TranscriptProvider>(context,
                                            listen: false);
                                    await transcriptProvider.updateTranscript(
                                      Transcript(
                                        transcriptId:
                                            widget.transcriptDTO.transcriptId,
                                        transcriptName: text,
                                        dateCreated:
                                            widget.transcriptDTO.dateCreated,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: const ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            title: Text('Edit'),
                          ),
                        );
                      });
                },
                child: const Icon(Icons.more_vert, color: lightGray),
              );
            }),
          ),
        ),
      ),
    );
  }
}
