import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';

class TranscriptDialog extends StatefulWidget {
  final Function(String text) onPressed;
  final TranscriptDTO? transcriptDTO;

  const TranscriptDialog({
    super.key,
    this.transcriptDTO,
    required this.onPressed,
  });

  @override
  State<TranscriptDialog> createState() => _TranscriptDialogState();
}

class _TranscriptDialogState extends State<TranscriptDialog> {
  final TextEditingController transcriptTitleController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transcriptDTO == null) {
      transcriptTitleController.text = 'Untitled';
    } else {
      transcriptTitleController.text = widget.transcriptDTO!.transcriptName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.transcriptDTO == null
                ? "Create Transcript"
                : "Edit Transcript",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
              child: Icon(Icons.close, size: 20),
            ),
          )
        ],
      ),
      content: SingleChildScrollView(
        reverse: true,
        child: SizedBox(
          height: 170,
          child: Column(children: [
            const SizedBox(height: 20),
            const SizedBox(
              width: double.infinity,
              child: Text(
                "Title",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextField(
              controller: transcriptTitleController,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
              ),
            ),
            Expanded(child: Container()),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.onPressed(transcriptTitleController.text);
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: _isLoading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: whiteColor,
                        ),
                      )
                    : Text(
                        widget.transcriptDTO == null ? "Create" : "Edit",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
              ),
            ])
          ]),
        ),
      ),
    );
  }
}
