import 'lua_state.dart';

abstract class LuaCoroutineLib {

  LuaState? toThread(int idx);

  void pushThread(LuaState L);

  void xmove(LuaState from, int n);

  Object? popObject();

  LuaState newThread();
}
