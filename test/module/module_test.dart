import 'dart:io';

import 'package:lua_dardo_co/lua.dart';
import 'package:test/test.dart';


int callLuaAdd(int a,int b){
  Directory.current = './test/module/';
  late LuaState ls;

  try{
    ls = LuaState.newState();
    ls.openLibs();
    ls.doFile("test.lua");
    ls.getGlobal("test_add");
    ls.pushInteger(a);
    ls.pushInteger(b);
    ls.pCall(2, 1,1);
    return ls.toInteger(-1);
  }catch(e,s){
    print(ls.checkString(1));
    print(e);
    print(s);
  }
  return -1;
}

class Abcd {
  String a;
  int b;
  Abcd(this.a,this.b);
}

void setA(Abcd? a) {
  a = Abcd("a", 1);
}

void main() {
  test('lua require function load module test', () {
    expect(callLuaAdd(10,8), 10+8);
  });

  Abcd? a;
  setA(a);
  print('a is $a');
}
