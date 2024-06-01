import 'package:deafconnect/daos/shortcuts.dao.dart';
import 'package:deafconnect/database/db_helper.dart';
import 'package:deafconnect/models/shortcut.model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ShortcutsProvider extends ChangeNotifier {
  List<Shortcut> _shortcuts = [];

  List<Shortcut> get shortcuts => _shortcuts;

  void updateShortcuts(List<Shortcut> newList) {
    _shortcuts = newList;
    notifyListeners();
  }

  Future fetchShortcuts() async {
    List<Shortcut> newShortcuts = await ShortcutDAO.getAllShortcuts();
    updateShortcuts(newShortcuts);
  }

  Future addShortcut(Shortcut shortcut) async {
    await ShortcutDAO.insertShortcut(shortcut);
    List<Shortcut> shortcuts = await ShortcutDAO.getAllShortcuts();
    updateShortcuts(shortcuts);
  }

  Future updateShortcut(Shortcut shortcut) async {
    await ShortcutDAO.updateShortcut(shortcut);
    List<Shortcut> shortcuts = await ShortcutDAO.getAllShortcuts();
    updateShortcuts(shortcuts);
  }

  Future deleteShortcut(int shortcutId) async {
    await ShortcutDAO.deleteShortcut(shortcutId);
    List<Shortcut> shortcuts = await ShortcutDAO.getAllShortcuts();
    updateShortcuts(shortcuts);
  }

  Future insertInitialShortcuts() async {
    await ShortcutDAO.insertInitialShortcuts();
    List<Shortcut> shortcuts = await ShortcutDAO.getAllShortcuts();
    updateShortcuts(shortcuts);
  }

  Future changeOrderInDB(List<Shortcut> newList) async {
    // we clear the db first
    await ShortcutDAO.deleteAllShortcuts();
    // we reinsert the new list of shortcuts in the db
    Database db = await DbHelper.getDb();
    // creating a batch to apply multiple insertions simultanously
    var batch = db.batch();
    for (int i = 0; i < newList.length; i++) {
      batch.insert(
          'shortcuts',
          Shortcut(
            shortcutName: newList[i].shortcutName,
            shortcutOrder: i,
          ).toJsonWithOrder());
    }
    await batch.commit(noResult: true);
    updateShortcuts(newList);
  }
}
