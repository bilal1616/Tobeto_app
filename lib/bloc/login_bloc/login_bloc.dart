import 'dart:async';

enum LoginEventType { toggle }

class LoginBloc {
  bool _isLogin = true;
  final _eventController = StreamController<LoginEventType>();
  final _stateController = StreamController<bool>();

  LoginBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  Stream<bool> get isLoginStream => _stateController.stream;

  bool get isLogin => _isLogin;

  void toggleLogin() {
    _eventController.sink.add(LoginEventType.toggle);
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }

  void _mapEventToState(LoginEventType event) {
    if (event == LoginEventType.toggle) {
      _isLogin = !_isLogin;
      _stateController.sink.add(_isLogin);
    }
  }
}
