import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/transcript.model.dart';
import 'package:deafconnect/providers/transcript.provider.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/date_utils.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/widgets/common/inkwell_with_opacity.dart';
import 'package:deafconnect/widgets/dialogs/transcript_dialog.dart';
import 'package:deafconnect/widgets/transcripts/transcript_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class TranscriptsScreen extends StatefulWidget {
  const TranscriptsScreen({super.key});

  @override
  State<TranscriptsScreen> createState() => _TranscriptsScreenState();
}

class _TranscriptsScreenState extends State<TranscriptsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        setState(() {
          isFetchingMore = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            isFetchingMore = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        floatingActionButton: InkwellWithOpacity(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return TranscriptDialog(
                  onPressed: (text) async {
                    if (text.isEmpty) return;

                    TranscriptProvider transcriptProvider =
                        Provider.of<TranscriptProvider>(context, listen: false);
                    await transcriptProvider.addTranscript(
                      Transcript(
                        transcriptId: 99, // anything, wont be stored in the db
                        transcriptName: text,
                        dateCreated: DateTime.now(),
                      ),
                    );
                    if (context.mounted) {
                      NavigationUtils.pop(context);
                    }
                  },
                );
              },
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: whiteColor,
                size: 30,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('Transcripts'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                if (isFetchingMore)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: CupertinoActivityIndicator(color: mainColor),
                  ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for transcript',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: blackColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Consumer<TranscriptProvider>(
                  builder: (context, transcriptProvider, child) {
                    if (transcriptProvider.transcripts.isEmpty) {
                      return const Center(child: Text('No transcripts yet'));
                    }

                    Map<DateTime, List<TranscriptDTO>> groupedTranscripts =
                        groupTranscriptsByDate(transcriptProvider.transcripts);

                    return SlidableAutoCloseBehavior(
                      child: SingleChildScrollView(
                        child: Column(
                          children: groupedTranscripts.entries.map((entry) {
                            DateTime date = entry.key;
                            List<TranscriptDTO> transcripts = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    formatDateTimeByDay(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Container(height: 1, color: lightGray),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transcripts.length,
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      height: 1,
                                      color: lightGray,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    return TranscriptBox(transcripts[index]);
                                  },
                                ),
                                Container(height: 1, color: lightGray),
                                const SizedBox(
                                    height: 10) // to seperate between days
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
