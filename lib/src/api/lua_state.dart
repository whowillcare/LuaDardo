

import 'lua_aux_lib.dart';
import 'lua_basic_api.dart';
import 'lua_coroutine.dart';
import 'lua_debug.dart';
import '../state/lua_state_impl.dart';



const luaMinStack = 20;
const luaMaxStack = 1000000;
const luaRegistryIndex = -luaMaxStack - 1000;
const luaMultret = -1;
const luaRidxGlobals = 2;

const luaMaxInteger = 1<<63 - 1;
const luaMinInteger = -1 << 63;

abstract class LuaState extends LuaBasicAPI implements LuaAuxLib, LuaCoroutineLib, LuaDebug {

  static LuaState newState(){
    return LuaStateImpl();
  }

}
