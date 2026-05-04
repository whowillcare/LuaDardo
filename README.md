# LuaDardo

![logo](https://github.com/arcticfox1919/ImageHosting/blob/master/language_logo.png?raw=true)

------

A Lua virtual machine written in [Dart](https://github.com/dart-lang/sdk), which implements [Lua5.3](http://www.lua.org/manual/5.3/) version.

Original : LuaDardo

## Example:

```yaml
dependencies:
  lua_dardo_enhanced: ^0.0.14
```

```dart
import 'package:lua_dardo_enhanced/lua.dart';

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

## Async Example
Starting with `0.0.13`, you can leverage seamless integration with Dart `Future` using `registerAsync` and `doAsyncString`. Passing Lua Tables (`{}`) between Dart's `Map`/`List` is also handled automatically.
Starting with `0.0.14`, you can seamlessly pass Lua functions to Dart inside `registerAsync`!

```dart
import 'package:lua_dardo_enhanced/lua.dart';

void main() async {
  LuaState lua = LuaState.newState();
  lua.openLibs();

  // Register an asynchronous Dart function
  lua.registerAsync("fetch_user", (args) async {
    final Map request = args[0] as Map;
    final Function callback = request['on_complete'];
    
    await Future.delayed(Duration(seconds: 1)); // Work...

    // We can call the lua callback!
    if (callback != null) {
       callback(["Fetch complete!"]);
    }

    // Return a structured Dart Map, which converts back to a Lua Table
    return {
      'status': 'success',
      'id': request['id'],
      'roles': ['admin', 'user']
    };
  });

  // Run the Lua script using `doAsyncString`
  await lua.doAsyncString('''
    local payload = { 
       id = 404,
       on_complete = function(msg)
           print("Message from Dart: " .. msg)
       end
    }
    
    -- Use await() to suspend execution until Future resolves
    local response = await(fetch_user(payload))
    
    print(response.status)
    print(response.roles[1])
  ''');
}
```
