import 'package:deafconnect/database/db_helper.dart';
import 'package:deafconnect/models/avatar_message.model.dart';
import 'package:sqflite/sqflite.dart';

class AvatarMessagesDAO {
  static int limit = 20;

  static Future<void> insertMessage(String message) async {
    final db = await DbHelper.getDb();
    final avatarMessage = AvatarMessage(id: 99, message: message);
    await db.insert(
      'avatar_messages',
      avatarMessage.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<AvatarMessage>> getMessages({required int page}) async {
    final db = await DbHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'avatar_messages',
      orderBy: 'avatar_message_id DESC',
      where: 'avatar_message IS NOT NULL AND avatar_message != ""',
      limit: limit,
      offset: (page - 1) * limit,
    );
    return List.generate(maps.length, (i) {
      return AvatarMessage.fromJson(maps[i]);
    });
  }

  static Future<void> deleteMessage(int id) async {
    final db = await DbHelper.getDb();
    await db.delete(
      'avatar_messages',
      where: 'avatar_message_id = ?',
      whereArgs: [id],
    );
  }
}
