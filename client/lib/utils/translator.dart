class Translator {
  String phrase = "";

  List<String> videoUrls = [];

  List<String> seperatedIndexd = [];
  int index = 0;

  final Map<String, String> letters = {
    'a': 'assets/videos/Letters/A.mp4',
    'b': 'assets/videos/Letters/B.mp4',
    'c': 'assets/videos/Letters/C.mp4',
    'd': 'assets/videos/Letters/D.mp4',
    'e': 'assets/videos/Letters/E.mp4',
    'f': 'assets/videos/Letters/F.mp4',
    'g': 'assets/videos/Letters/G.mp4',
    'h': 'assets/videos/Letters/H.mp4',
    'i': 'assets/videos/Letters/I.mp4',
    'j': 'assets/videos/Letters/J.mp4',
    'k': 'assets/videos/Letters/K.mp4',
    'l': 'assets/videos/Letters/L.mp4',
    'm': 'assets/videos/Letters/M.mp4',
    'n': 'assets/videos/Letters/N.mp4',
    'o': 'assets/videos/Letters/O.mp4',
    'p': 'assets/videos/Letters/P.mp4',
    'q': 'assets/videos/Letters/Q.mp4',
    'r': 'assets/videos/Letters/R.mp4',
    's': 'assets/videos/Letters/S.mp4',
    't': 'assets/videos/Letters/T.mp4',
    'u': 'assets/videos/Letters/U.mp4',
    'v': 'assets/videos/Letters/V.mp4',
    'w': 'assets/videos/Letters/W.mp4',
    'x': 'assets/videos/Letters/X.mp4',
    'y': 'assets/videos/Letters/Y.mp4',
    'z': 'assets/videos/Letters/Z.mp4',
  };

  final Map<String, String> words = {
    'happy': 'assets/videos/Words/Happy.mp4',
    'hello': 'assets/videos/Words/Hello.mp4',
    'meet': 'assets/videos/Words/Meet.mp4',
    'my': 'assets/videos/Words/My.mp4',
    'name': 'assets/videos/Words/Name.mp4',
    'nice': 'assets/videos/Words/Nice.mp4',
    'want': 'assets/videos/Words/Want.mp4',
    'you': 'assets/videos/Words/you.mp4',
    '': 'assets/videos/Words/Idle.mp4',
  };

  Translator(this.phrase);

  List<String> translatePhrase() {
    index = 0;
    videoUrls.clear();

    List<String> seperateWords = phrase.split(' ');

    for (int i = 0; i < seperateWords.length; i++) {
      String currentWord = seperateWords[i].toLowerCase();
      print('words ${currentWord}');
      if (words.containsKey(currentWord)) {
        videoUrls.add(words[currentWord]!);
        seperatedIndexd.add(currentWord);
        print(1);
      } else {
        for (int i = 0; i < currentWord.length; i++) {
          String currentLetter = currentWord[i].toLowerCase();
          String? currentVideoAsset = letters[currentLetter];
          print('12 ${letters[currentLetter]}');
          if (currentVideoAsset != null) {
            seperatedIndexd.add(currentLetter);

            videoUrls.add(currentVideoAsset);
          }
        }
      }
    }
    print(videoUrls);

    return videoUrls;
  }

  List<String> splitPhrase(String text) {
    return seperatedIndexd;
  }
}
