import 'package:deafconnect/database/db_helper.dart';
import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/message.model.dart';
import 'package:deafconnect/models/transcript.model.dart';
import 'package:sqflite/sqflite.dart';

class TranscriptDAO {
  static const messagesLimit = 10;

  static Future<int> insertTranscript(Transcript transcript) async {
    Database db = await DbHelper.getDb();
    String sql =
        'INSERT INTO transcripts(transcript_name, date_created) VALUES (?, ?)';
    List params = [
      transcript.transcriptName,
      transcript.dateCreated.toIso8601String()
    ];
    await db.rawInsert(sql, params);
    int? lastInsertedId =
        Sqflite.firstIntValue(await db.rawQuery('SELECT last_insert_rowid()'));
    return lastInsertedId ??
        -1; // Providing -1 as a default value if lastInsertedId is null
  }

  static Future<List<TranscriptDTO>> getAllTranscripts() async {
    // Execute SQL query to fetch transcripts along with their latest 20 messages
    String query = '''
      SELECT
          latest_messages.transcript_id,
          latest_messages.transcript_name,
          latest_messages.date_created,
          latest_messages.message_id,
          latest_messages.message_transcript_id,
          latest_messages.message_content,
          latest_messages.is_received,
          latest_messages.message_date
      FROM
          (
              SELECT
                  t.transcript_id,
                  t.transcript_name,
                  t.date_created,
                  m.message_id,
                  m.transcript_id AS message_transcript_id,
                  m.message_content,
                  m.is_received,
                  m.message_date
              FROM
                  transcripts t
              LEFT JOIN (
                  SELECT 
                      transcript_id,
                      message_id,
                      message_content,
                      is_received,
                      message_date
                  FROM messages
                  ORDER BY message_date DESC
                  LIMIT 10
              ) m ON t.transcript_id = m.transcript_id
              ORDER BY
                  m.message_date DESC

          ) AS latest_messages
      ORDER BY
          latest_messages.message_date ASC;
    ''';

    // Execute the query and fetch results
    Database db = await DbHelper.getDb();
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    // Process results and construct TranscriptDTO objects
    Map<int, TranscriptDTO> transcriptsMap = {};
    for (var row in results) {
      int transcriptId = row['transcript_id'];
      if (!transcriptsMap.containsKey(transcriptId)) {
        transcriptsMap[transcriptId] = TranscriptDTO(
          transcriptId: transcriptId,
          transcriptName: row['transcript_name'],
          dateCreated: DateTime.parse(row['date_created']),
          messages: [],
        );
      }
      TranscriptDTO transcriptDTO = transcriptsMap[transcriptId]!;

      // checking that message is not null (it exists) and limit is not passed
      if (row['message_id'] != null &&
          transcriptDTO.messages.length < messagesLimit) {
        Message message = Message(
          messageId: row['message_id'],
          transcriptId: row['message_transcript_id'],
          messageContent: row['message_content'],
          isReceived: row['is_received'] == 1,
          date: DateTime.parse(row['message_date']),
        );
        transcriptDTO.messages.add(message);
      }
    }
    // Convert transcriptsMap values to a list and return
    return transcriptsMap.values.toList();
  }

  static Future<int> updateTranscript(Transcript transcript) async {
    final db = await DbHelper.getDb();
    return await db.update(
      'transcripts',
      transcript.toJson(),
      where: 'transcript_id = ?',
      whereArgs: [transcript.transcriptId],
    );
  }

  static Future<int> deleteTranscript(int id) async {
    final db = await DbHelper.getDb();
    return await db.delete(
      'transcripts',
      where: 'transcript_id = ?',
      whereArgs: [id],
    );
  }
}
