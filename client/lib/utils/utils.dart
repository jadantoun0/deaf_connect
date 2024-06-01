String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text.replaceFirst(text[0], text[0].toUpperCase());
}

String getNextLetterForLetter(String letter) {
  letter = letter.toUpperCase();

  int asciiCode = letter.codeUnitAt(0);

  if (asciiCode == 'Z'.codeUnitAt(0)) {
    return 'A'; // Wrap around to 'A' if it's 'Z'
  } else {
    return String.fromCharCode(asciiCode + 1);
  }
}
