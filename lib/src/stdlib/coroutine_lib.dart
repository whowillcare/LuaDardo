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
    co.printStack();
    try {
      co.call(nArgs, 0);
    } catch (e) {
      print('received exception: $e ----------------------------');
      if (e is LuaYieldException) {
        return 0;
      }
      return 0;
    }
    return 0;
  }

  static int _coYield(LuaState ls) {
    throw LuaYieldException();
    // print('yielding');
    // return 0;
  }
}
