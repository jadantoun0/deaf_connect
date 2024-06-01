import 'package:deafconnect/utils/shared_preferences_utils.dart';
import 'package:flutter/widgets.dart';

class StoreProvider extends ChangeNotifier {
  int _selectedTab = 0;
  int _selectedTranscriptId = 1;
  bool _female = true;
  String _selectedBgImage = "";

  int get selectedTab => _selectedTab;
  int get selectedTranscriptId => _selectedTranscriptId;
  bool get isFemale => _female;
  String get selectedBgImage => _selectedBgImage;

  void updateSelectedTab(int newTab) {
    _selectedTab = newTab;
    notifyListeners();
  }

  void setFemale(bool value) async {
    _female = value;
    await SharedPreferencesUtils.setBool("isFemale", value);
    notifyListeners();
  }

  void setBgImage(String value) {
    _selectedBgImage = value;
    SharedPreferencesUtils.setString("bgImage", _selectedBgImage);
    notifyListeners();
  }

  void updateSelectedTranscriptId(int newValue) {
    _selectedTranscriptId = newValue;
    notifyListeners();
  }
}
