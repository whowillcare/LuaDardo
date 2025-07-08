import '../state/lua_state_impl.dart';


// just for test, when in release mode, this file will not be imported
mixin TestMixin {
  String lastCodeName = "";
  String lastFileName = "";
  int lastLine = 0;

  void setLastCodeName(LuaStateImpl ls) {
  }
}
