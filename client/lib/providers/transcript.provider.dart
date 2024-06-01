import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:deafconnect/daos/message.dao.dart';
import 'package:deafconnect/daos/transcript.dao.dart';
import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/message.model.dart';
import 'package:deafconnect/models/transcript.model.dart';

class TranscriptProvider extends ChangeNotifier {
  List<TranscriptDTO> _transcripts = [];

  List<TranscriptDTO> get transcripts => _transcripts;

  void updateTranscripts(List<TranscriptDTO> list) {
    _transcripts = list;
    notifyListeners();
  }

  Future fetchTranscripts() async {
    List<TranscriptDTO> transcriptsList =
        await TranscriptDAO.getAllTranscripts();
    updateTranscripts(transcriptsList);
  }

  Future insertInitialTranscript() async {
    Transcript transcript = Transcript(
      transcriptId: 0,
      transcriptName: 'Untitled',
      dateCreated: DateTime.now(),
    );
    await addTranscript(transcript);
    await fetchTranscripts();
  }

  Future<int> addTranscript(Transcript transcript) async {
    int id = await TranscriptDAO.insertTranscript(transcript);
    _transcripts.add(TranscriptDTO(
      transcriptId: id,
      transcriptName: transcript.transcriptName,
      dateCreated: transcript.dateCreated,
      messages: [],
    ));
    notifyListeners();
    return id;
  }

  Future updateTranscript(Transcript transcript) async {
    await TranscriptDAO.updateTranscript(transcript);
    final index = _transcripts
        .indexWhere((t) => t.transcriptId == transcript.transcriptId);
    if (index != -1) {
      _transcripts[index].transcriptName = transcript.transcriptName;
      _transcripts[index].dateCreated = transcript.dateCreated;
      notifyListeners();
    }
  }

  Future deleteTranscript(int transcriptId) async {
    await TranscriptDAO.deleteTranscript(transcriptId);
    _transcripts.removeWhere((t) => t.transcriptId == transcriptId);
    notifyListeners();
  }

  TranscriptDTO? getTranscriptById(int id) {
    return transcripts
        .firstWhereOrNull((transcript) => transcript.transcriptId == id);
  }

  Future loadMoreMessages(int transcriptId) async {
    TranscriptDTO? transcript = _transcripts.firstWhereOrNull(
      (transcript) => transcript.transcriptId == transcriptId,
    );
    if (transcript == null) {
      return; // Transcript not found
    }
    DateTime? oldestMessageTimestamp;
    if (transcript.messages.isNotEmpty) {
      oldestMessageTimestamp = transcript.messages.first.date;
    }
    // there are no messages => there are no older messages
    if (oldestMessageTimestamp == null) {
      return [];
    }
    // Fetch older messages from the database
    List<Message> olderMessages = await MessageDAO.getOlderMessages(
      transcriptId,
      oldestMessageTimestamp,
    );
    transcript.messages.insertAll(0, olderMessages);
    notifyListeners();
  }

  void addMessageToTranscript({
    required String message,
    required int transcriptId,
    required bool isReceived,
  }) {
    TranscriptDTO? transcript = transcripts.firstWhereOrNull(
      (transcript) => transcript.transcriptId == transcriptId,
    );

    Message newMessage = Message(
      messageId: 99, // will not be stored in the db
      messageContent: message,
      isReceived: isReceived,
      transcriptId: transcriptId,
      date: DateTime.now(),
    );

    transcript!.messages.add(newMessage);
    notifyListeners();

    // store message in db
    MessageDAO.insertMessage(newMessage);
  }
}
