# LuaDardo

![logo](https://github.com/arcticfox1919/ImageHosting/blob/master/language_logo.png?raw=true)

------

A Lua virtual machine written in [Dart](https://github.com/dart-lang/sdk), which implements [Lua5.3](http://www.lua.org/manual/5.3/) version.

Original : LuaDardo

## Example:

```yaml
dependencies:
  lua_dardo_co: ^0.0.1
```

```dart
import 'package:lua_dardo/lua.dart';


void main(List<String> arguments) {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.loadString(r'''


local function test_a(b, c)
    print('test_a', b, c)
    return b + c
end

local function test_coroutine3()
    print('coroutine3 step 1', coroutine.running())
    local arg1, arg2 = coroutine.yield(1992)
    print('coroutine3 step 2 <<<', arg1, arg2, '>>>\n')

    -- local a = nil
    -- a = a + 1
end

local function test_coroutine2()
    print('coroutine2 step 1')
    local arg1, arg2 = coroutine.yield(1991)
    print('coroutine2 step 2 <<<', arg1, arg2, '>>>\n')
    test_coroutine3()
end

local function test_coroutine()
    local q = test_a(1, 2)
    print('q', q)
    test_coroutine2()
    print('test_coroutine end')
end

local co = coroutine.create(test_coroutine)

print('will test coroutine')
print(coroutine.resume(co, 1, 2))

print('will test coroutine2')
print(coroutine.resume(co, 3, 4))

print('is suspended', coroutine.status(co))

print('coroutine 3', coroutine.running())

print(coroutine.resume(co, 5, 6))

print('is dead', coroutine.status(co))

print('coroutine 4', coroutine.running())

''');
  state.call(0, 0);
}
```


