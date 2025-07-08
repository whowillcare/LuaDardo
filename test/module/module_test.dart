import 'dart:io';

import 'package:lua_dardo/lua.dart';

int callLuaAdd(int a, int b) {
  Directory.current = './test/module/';
  late LuaState ls;

  try {
    print('cur ${Directory.current.path}');
    ls = LuaState.newState();
    ls.openLibs();
    ls.doFile("test.lua");
    ls.getGlobal("test_add");
    ls.pushInteger(a);
    ls.pushInteger(b);
    ls.pCall(2, 1, 0);
    return ls.toInteger(-1);
  } catch (e, s) {
    print(ls.checkString(1));
    print(e);
    print(s);
  }
  return -1;
}

void main() {
  // test('lua require function load module test', () {
  //   expect(callLuaAdd(10,8), 10+8);
  // });
}
