import '../../lua.dart';
import '../api/lua_state.dart';
import '../../debug.dart';
import '../types/exceptions.dart';


class CoroutineLib {
  static const Map<String, DartFunction> _coFuncs = {
    "create": _coCreate,
    "resume": _coResume,
    "yield": _coYield,
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
        return 0;
      }
      else if (co.getStatus() == ThreadStatus.luaYield) {
        co.resume(nArgs);
        return 0;
      }
    } catch (e) {
      if (e is LuaYieldException) {
        int nRets = co.getTop();
        ls.xmove(co, nRets);
        return nRets;
      }
      else {
        print('received exception in resume: [$e] ----------------------------');
        return 0;
      }
    }
    return 0;
  }

  static int _coYield(LuaState ls) {
    ls.setStatus(ThreadStatus.luaYield);
    throw LuaYieldException();
    // print('yielding');
    // return 0;
  }
}
