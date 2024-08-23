import '../../lua.dart';
import '../api/lua_state.dart';
import '../../debug.dart';
import '../types/exceptions.dart';


class CoroutineLib {
  static const Map<String, DartFunction> _coFuncs = {
    "create": _coCreate,
    "resume": _coResume,
    "yield": _coYield,
    "status": _coStatus,
    'running': _coRunning,
  };

  static int openCoroutineLib(LuaState ls) {
    ls.newLib(_coFuncs);
    return 1;
  }

  static int _coCreate(LuaState ls) {
    if (!ls.isFunction(1)) {
      return 0;
    }

    LuaState newls = ls.newThread();
    newls.xmove(ls, 1);
    ls.pushThread(newls);
    return 1;
  }

  static int _coResume(LuaState ls) {
    int nArgs = ls.getTop() - 1;
    LuaState? co = ls.toThread(1);
    if (co == null) {
      throw "thread expected";
    }

    co.xmove(ls, nArgs);
    try {
      if (co.getStatus() == ThreadStatus.luaOk) {
        co.call(nArgs, 0);
      }
      else if (co.getStatus() == ThreadStatus.luaYield) {
        co.setStatus(ThreadStatus.luaOk);
        co.resume(nArgs);
      }
    } catch (e) {
      if (e is LuaYieldException) {
        int nRets = co.getTop();
        ls.xmove(co, nRets);
        return nRets;
      }
      else {
        print('received exception in resume: [$e] ----------------------------');
        print('${co.traceStack()}');
        return 0;
      }
    }

    co.setStatus(ThreadStatus.luaDead);
    return 0;
  }

  static int _coStatus(LuaState ls) {
    LuaState? co = ls.toThread(1);
    if (co == null) {
      ls.pushString("dead");
    }
    else {
      if (co.runningId() == ls.runningId()) {
        ls.pushString("running");
      }
      else if (co.getStatus() == ThreadStatus.luaDead) {
        ls.pushString("dead");
      }
      else {
        ls.pushString("suspended");
      }
    }
    return 1;
  }

  static int _coYield(LuaState ls) {
    ls.setStatus(ThreadStatus.luaYield);
    throw LuaYieldException();
    // print('yielding');
    // return 0;
  }

  static int _coRunning(LuaState ls) {
    ls.pushThread(ls);
    return 1;
  }
}
