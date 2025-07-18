import '../../lua.dart';
import '../types/exceptions.dart';

class CoroutineLib {
  static const Map<String, DartFunction> _coFuncs = {
    "create": _coCreate,
    "resume": _coResume,
    "yield": _coYield,
    "wrap": _coWrap,
    "status": _coStatus,
    "running": _coRunning,
    "id": _coId,
    "debug": _coDebug,
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
      ls.pushBoolean(false);
      ls.pushString("thread expected");
      return 2;
    }

    // 🚨 Add this check for "cannot resume non-suspended coroutine"
    if (co.runningId() == ls.runningId()) {
      ls.pushBoolean(false);
      ls.pushString("cannot resume non-suspended coroutine");
      return 2;
    }

    if (co.getStatus() == ThreadStatus.luaDead) {
      ls.pushBoolean(false);
      ls.pushString("cannot resume dead coroutine");
      return 2;
    }

    co.xmove(ls, nArgs);
    int nRets = ls.getCurrentNResults();
    if (nRets > 0) {
      co.resetTopClosureNResults(nRets - 1);
    }
    try {
      if (co.getStatus() == ThreadStatus.luaOk) {
        co.call(nArgs, nRets - 1);
      } else if (co.getStatus() == ThreadStatus.luaYield) {
        co.setStatus(ThreadStatus.luaOk);
        co.resume(nArgs);
      }
    } catch (e, s) {
      if (e is LuaYieldException) {
        final n = e.nResults;
        ls.pushBoolean(true);
        ls.xmove(co, n);
        return n + 1;
      } else {
        String msg = 'error: $e\n\n${s.toString()}\n\n${co.traceStack()}';
        print(msg);
        ls.pushBoolean(false);
        ls.pushString(msg);
        return 2;
      }
    }

    co.setStatus(ThreadStatus.luaDead);
    if (nRets == 1) {
      ls.pushBoolean(true);
    } else if (nRets > 1) {
      ls.pushBoolean(true);
      ls.xmove(co, nRets - 1);
    }
    return nRets;
  }

  static int _coStatus(LuaState ls) {
    LuaState? co = ls.toThread(1);
    if (co == null) {
      ls.pushString("dead");
    } else {
      if (co.runningId() == ls.runningId()) {
        ls.pushString("running");
      } else if (co.getStatus() == ThreadStatus.luaDead) {
        ls.pushString("dead");
      } else {
        ls.pushString("suspended");
      }
    }
    return 1;
  }

  static int _coYield(LuaState ls) {
    final nResults = ls.getTop(); // Number of values to yield
    ls.setStatus(ThreadStatus.luaYield);
    throw LuaYieldException(nResults);
  }

  static int _coRunning(LuaState ls) {
    ls.pushThread(ls);
    return 1;
  }

  static int _coId(LuaState ls) {
    LuaState? co = ls.toThread(1);
    if (co == null) {
      ls.pushNil();
    } else {
      ls.pushInteger(co.runningId());
    }
    return 1;
  }

  static int _coDebug(LuaState ls) {
    ls.pushString(ls.debugThread());
    return 1;
  }

  static int _coWrap(LuaState ls) {
    if (!ls.isFunction(1)) {
      ls.pushNil();
      return 1;
    }

    LuaState newCo = ls.newThread();
    newCo.xmove(ls, 1); // move function to coroutine

    // wrap returns a function that resumes the coroutine
    ls.pushDartFunction((LuaState innerLs) {
      LuaState co = newCo;
      int nargs = innerLs.getTop();

      co.xmove(innerLs, nargs); // move arguments into coroutine

      int nRets = innerLs.getCurrentNResults();
      if (nRets > 0) {
        co.resetTopClosureNResults(nRets - 1);
      }

      try {
        if (co.getStatus() == ThreadStatus.luaOk) {
          co.call(nargs, nRets - 1);
        } else if (co.getStatus() == ThreadStatus.luaYield) {
          co.setStatus(ThreadStatus.luaOk);
          co.resume(nargs);
        }
      } catch (e) {
        if (e is LuaYieldException) {
          int n = e.nResults;
          innerLs.xmove(co, n);
          return n;
        } else {
          throw Exception("coroutine error: $e");
        }
      }

      if (co.getStatus() == ThreadStatus.luaDead) {
        co.setStatus(ThreadStatus.luaDead);
      }

      innerLs.xmove(co, co.getTop());
      return innerLs.getTop();
    });

    return 1;
  }

}
