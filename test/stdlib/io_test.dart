import 'package:lua_dardo/lua.dart';
import 'package:test/test.dart';


bool testIO() {
  try {
    LuaState state = LuaState.newState();
    state.openLibs();
    state.loadString(r'''
local f = io.open('test.txt', 'w')
f:write('hel')
f:close()

f = io.open('test.txt', 'r')
print(f:read('*a'))
f:close()
''');
    state.pCall(0, 0, 1);
  } catch (e, s) {
    print('$e\n$s');
    return false;
  }
  return true;
}

void main() {
  test('lua IO standard library test', () {
    expect(testIO(), true);
  });
}
