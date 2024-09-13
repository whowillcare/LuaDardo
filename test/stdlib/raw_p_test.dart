import 'package:lua_dardo_co/lua.dart';
import 'package:test/test.dart';


int testRawP() {
    LuaState ls = LuaState.newState();
    ls.openLibs();
    ls.newTable();
    ls.pushInteger(1);

    Map<String, int> m = {
        'a': 1,
        'b': 2,
        'c': 3,
    };

    ls.rawSetP(-2, m);

    Map<String, int> m2 = {
        'a': 1,
        'b': 2,
        'c': 3,
    };
    ls.rawGetP(-1, m2);

    return 0;
}

void main() {
  test('lua raw p test', () {
    expect(testRawP(), 0);
  });
}
