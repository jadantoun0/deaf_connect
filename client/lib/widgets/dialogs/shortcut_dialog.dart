import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:flutter/material.dart';

class ShortcutDialog extends StatefulWidget {
  final Function(String text) onPressed;

  const ShortcutDialog({
    super.key,
    required this.onPressed,
  });

  @override
  State<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<ShortcutDialog> {
  final TextEditingController transcriptTitleController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Create Shortcut",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 20),
          )
        ],
      ),
      content: SingleChildScrollView(
        reverse: true,
        child: SizedBox(
          height: 170,
          child: Column(children: [
            const SizedBox(height: 20),
            TextField(
              controller: transcriptTitleController,
              decoration: const InputDecoration(
                // contentPadding: EdgeInsets.symmetric(
                //   horizontal: 10,
                //   vertical: 5,
                // ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: lightGray),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: lightGray),
                ),
                hintText: 'Enter Shortcut',
                hintStyle: TextStyle(fontSize: 15),
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
                  if (mounted) {
                    NavigationUtils.pop(context);
                  }
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
                    : const Text(
                        "Create",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ])
          ]),
        ),
      ),
    );
  }
}
