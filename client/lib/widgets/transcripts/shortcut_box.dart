import 'package:deafconnect/models/shortcut.model.dart';
import 'package:deafconnect/providers/shortcuts.provider.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ShortcutBox extends StatefulWidget {
  final Shortcut shortcut;
  const ShortcutBox(this.shortcut, {super.key});

  @override
  State<ShortcutBox> createState() => _ShortcutBoxState();
}

class _ShortcutBoxState extends State<ShortcutBox> {
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
                  ShortcutsProvider shortcutsProvider =
                      Provider.of<ShortcutsProvider>(context, listen: false);
                  await shortcutsProvider
                      .deleteShortcut(widget.shortcut.shortcutOrder);
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
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: lightGray)),
        ),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Row(
            children: [
              Text(
                widget.shortcut.shortcutName,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
