import 'package:deafconnect/database/db_helper.dart';
import 'package:deafconnect/models/shortcut.model.dart';
import 'package:sqflite/sqflite.dart';

class ShortcutDAO {
  static Future<void> insertShortcut(Shortcut shortcut) async {
    final db = await DbHelper.getDb();
    await db.insert(
      'shortcuts',
      shortcut.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Shortcut>> getAllShortcuts() async {
    final db = await DbHelper.getDb();
    final List<Map<String, dynamic>> maps =
        await db.query('shortcuts', orderBy: 'shortcut_order');
    return List.generate(maps.length, (i) {
      return Shortcut.fromJson(maps[i]);
    });
  }

  static Future insertInitialShortcuts() async {
    List<Shortcut> initialShortcuts = [
      Shortcut(
        shortcutOrder: 0,
        shortcutName: 'Hey, how are you',
      ),
      Shortcut(
        shortcutName: 'Thank you',
        shortcutOrder: 1,
      ),
      Shortcut(
        shortcutName: 'One coffee, please',
        shortcutOrder: 2,
      ),
      Shortcut(
        shortcutName: 'I\’m deaf, help please',
        shortcutOrder: 3,
      ),
      Shortcut(
        shortcutName: 'I need assistance',
        shortcutOrder: 4,
      ),
      Shortcut(
        shortcutName: 'Hello',
        shortcutOrder: 5,
      ),
      Shortcut(
        shortcutName: 'How much does it cost?',
        shortcutOrder: 6,
      ),
      Shortcut(
        shortcutName: 'Goodbye, see you later',
        shortcutOrder: 7,
      ),
    ];

    for (Shortcut shortcut in initialShortcuts) {
      await insertShortcut(shortcut);
    }
  }

  static Future<void> updateShortcut(Shortcut shortcut) async {
    final db = await DbHelper.getDb();
    await db.update(
      'shortcuts',
      shortcut.toJson(),
      where: 'shortcut_order = ?',
      whereArgs: [shortcut.shortcutOrder],
    );
  }

  static Future<void> deleteShortcut(int shortcutOrder) async {
    final db = await DbHelper.getDb();
    await db.delete(
      'shortcuts',
      where: 'shortcut_order = ?',
      whereArgs: [shortcutOrder],
    );
  }

  static Future<void> deleteAllShortcuts() async {
    final db = await DbHelper.getDb();
    await db.delete('shortcuts');
  }
}
