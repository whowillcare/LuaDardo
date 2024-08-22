import 'dart:core';
import '../api/lua_state.dart';


class ThreadCache {
  WeakReference<LuaState>? pLuaState;
  int id;

  ThreadCache(this.id, LuaState ls) {
    pLuaState = WeakReference(ls);
  }
}


typedef ThreadsMap = Map<int, ThreadCache>;
