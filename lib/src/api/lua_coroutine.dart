import 'lua_state.dart';
import 'lua_type.dart';

abstract class LuaCoroutineLib {
  LuaState? toThread(int idx);

  void pushThread(LuaState L);

  void xmove(LuaState from, int n);

  Object? popObject();

  LuaState newThread();

  String debugThread();

  void clearThreadWeakRef();

  void setStatus(ThreadStatus status);

  ThreadStatus getStatus();

  void resume(int nArgs);

  int runningId();
}
