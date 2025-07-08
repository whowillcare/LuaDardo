import 'package:lua_dardo_co/lua.dart';
import 'dart:io';
import 'package:test/test.dart';

(String, String) coTest() {
    Directory.current = './test/coroutine/';
    LuaState ls = LuaState.newState();
    ls.openLibs();
    ls.doFile("test.lua");
    ls.getGlobal("co_test");
    ls.pushString("1");
    ls.pushString("a");
    ls.pCall(2, 2, 1);
    String ret1 = ls.checkString(-2)!;
    String ret2 = ls.checkString(-1)!;
    return (ret1, ret2);
}


void main() {
    test('lua coroutine test', () {
        var (ret1, ret2) = coTest();
        expect(ret1, "123456789");
        expect(ret2, "abcdefghi");
    });
}
