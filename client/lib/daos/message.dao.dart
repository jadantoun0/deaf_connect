import 'package:deafconnect/database/db_helper.dart';
import 'package:deafconnect/models/message.model.dart';

class MessageDAO {
  static const int messagesLimit = 10;

  static Future<int> insertMessage(Message message) async {
    final db = await DbHelper.getDb();
    return await db.insert('messages', message.toJson());
  }

  static Future<List<Message>> getOlderMessages(
    int transcriptId,
    DateTime oldestMessageTimestamp,
  ) async {
    final db = await DbHelper.getDb();

    // Construct SQL query to fetch older messages
    String query = '''
      SELECT * FROM (
        SELECT * FROM messages 
        WHERE transcript_id = ? AND ms_since_epoch < ?
        ORDER BY ms_since_epoch DESC
        LIMIT ?
      )
      ORDER BY ms_since_epoch ASC
    ''';

    // Execute the query and fetch results
    List<Map<String, dynamic>> results = await db.rawQuery(query, [
      transcriptId,
      oldestMessageTimestamp.millisecondsSinceEpoch,
      messagesLimit,
    ]);

    // Process results and construct Message objects
    List<Message> olderMessages =
        results.map((row) => Message.fromJson(row)).toList();

    return olderMessages;
  }
}
