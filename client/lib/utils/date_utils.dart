import 'package:deafconnect/dtos/transcript.dto.dart';
import 'package:deafconnect/models/message.model.dart';

String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  Duration difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (dateTime.day == today.day) {
    String timeString =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    // String timePeriod = dateTime.hour >= 12 ? 'PM' : 'AM';
    return 'Today • $timeString';
  } else if (dateTime.day == yesterday.day) {
    String timeString =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    String timePeriod = dateTime.hour >= 12 ? 'PM' : 'AM';
    return 'Yesterday • $timeString$timePeriod';
  } else {
    String timeString =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    String timePeriod = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} • $timeString$timePeriod';
  }
}

String formatDateTimeByDay(DateTime date) {
  final DateTime now = DateTime.now();
  final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday';
  } else if (date.year == now.year) {
    return '${_formatDayOfWeek(date.weekday)}, ${_formatMonth(date.month)} ${date.day}';
  } else {
    return '${_formatDayOfWeek(date.weekday)}, ${_formatMonth(date.month)} ${date.day}, ${date.year}';
  }
}

String _formatDayOfWeek(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return '';
  }
}

String _formatMonth(int month) {
  switch (month) {
    case DateTime.january:
      return 'January';
    case DateTime.february:
      return 'February';
    case DateTime.march:
      return 'March';
    case DateTime.april:
      return 'April';
    case DateTime.may:
      return 'May';
    case DateTime.june:
      return 'June';
    case DateTime.july:
      return 'July';
    case DateTime.august:
      return 'August';
    case DateTime.september:
      return 'September';
    case DateTime.october:
      return 'October';
    case DateTime.november:
      return 'November';
    case DateTime.december:
      return 'December';
    default:
      return '';
  }
}

Map<DateTime, List<TranscriptDTO>> groupTranscriptsByDate(
    List<TranscriptDTO> transcripts) {
  Map<DateTime, List<TranscriptDTO>> groupedMap = {};

  // Sort transcripts by date
  transcripts.sort((a, b) => getLatestDate(b).compareTo(getLatestDate(a)));

  for (var transcript in transcripts) {
    DateTime date = DateTime(getLatestDate(transcript).year,
        getLatestDate(transcript).month, getLatestDate(transcript).day);

    if (groupedMap.containsKey(date)) {
      groupedMap[date]!.add(transcript);
    } else {
      groupedMap[date] = [transcript];
    }
  }
  return groupedMap;
}

Map<DateTime, List<Message>> groupMessagesByDate(List<Message> messages) {
  Map<DateTime, List<Message>> groupedMap = {};

  for (var message in messages) {
    DateTime date =
        DateTime(message.date.year, message.date.month, message.date.day);

    if (groupedMap.containsKey(date)) {
      groupedMap[date]!.add(message);
    } else {
      groupedMap[date] = [message];
    }
  }
  return groupedMap;
}

DateTime getLatestDate(TranscriptDTO transcriptDTO) {
  if (transcriptDTO.messages.isNotEmpty) {
    return transcriptDTO.messages.last.date;
  }
  // if transcript does not contain any messages, return date it was created
  return transcriptDTO.dateCreated;
}
