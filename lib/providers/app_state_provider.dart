import 'package:flutter/foundation.dart';

class AppStateProvider with ChangeNotifier {
  bool _isFakeMode = false;
  bool get isFakeMode => _isFakeMode;

  void toggleFakeMode() {
    _isFakeMode = !_isFakeMode;
    notifyListeners();
  }
}
