import 'package:lua_dardo_co/lua.dart';
import 'package:test/test.dart';


bool testString(){
  try{
    LuaState state = LuaState.newState();
    state.openLibs();
    state.loadString(r'''
local function tohex(x) return string.byte(tonumber(x, 16)) end
local function todec(x) return string.byte(tonumber(x, 10)) end
--local function toesc(x) return escape[x] or x end


local origin = "\\x00,\\x4,\\x10,qq"

local after_sub = origin:gsub("\\x(%x+)", tohex, 2)
print('after_sub', after_sub)
      ''');
    state.pCall(0, 0, 1);

    state.loadString(r'''
--[[
multi-line comments
multi-line comments
]]

a = [[abc
123]]
b = [==[
abc
123]==]
print(a)
print(b)
str = 'a string with "quotes" and \n new line\r\n'
print(str)
print(string.gsub("hello world", "(%w+)", "%1 %1%%"))
print(string.len("abc"))
print(string.byte("abcABC", 1, 6))
print(string.char(97, 98, 99))
print(string.upper("acde"))
print(string.find("8Abc%a23", "%a"))
print(string.find("8Abc%a23", "(%a)"))
print(string.find("8Abc%a23", "(%a)", 4))
print(string.find("8Abc%a23", "%a", 1, true))
print(string.find("8Abca23", "Ab"))
print(string.match("abc123ABC456", "ABC"))

''');
    state.pCall(0, 0, 1);
  }catch(e,s){
    print('$e\n$s');
    return false;
  }
  return true;
}

void main() {
  test('lua table standard library test', () {
    expect(testString(), true);
  });
}
