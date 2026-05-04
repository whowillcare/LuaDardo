import 'package:test/test.dart';
import 'package:lua_dardo_enhanced/lua.dart';
import 'dart:async';

void main() {
  test('Async functions and await in Lua', () async {
    LuaState state = LuaState.newState();
    state.openLibs();

    // Register async functions
    state.registerAsync('http_get', (args) async {
      final url = args[0] as String;
      await Future.delayed(Duration(milliseconds: 100)); // simulate network
      return 'Response from $url';
    });

    state.registerAsync('fetch_user', (args) async {
      await Future.delayed(Duration(milliseconds: 50));
      if (args[0] is Map) {
         final map = args[0] as Map;
         final id = map['id'] ?? map[1.0]; 
         return {
           'name': 'User-$id',
           'values': [10, 20, 30]
         };
      }
      final id = args[0] as int;
      return 'User-$id';
    });
    
    String results = '';
    state.registerAsync('log_result', (args) async {
      results += args[0].toString() + '\\n';
      return null;
    });

    final script = '''
      local r1 = await(http_get("https://example.com"))
      log_result(r1)
      local r2 = await(fetch_user(123))
      log_result(r2)
      
      local items = await(fetch_user({ id = 456, data = {1, 2, 3} }))
      log_result(items.name)
      log_result(items.values[2])
    ''';

    await state.doAsyncString(script);

    expect(results, 'Response from https://example.com\\nUser-123\\nUser-456\\n20\\n');
  });

  test('Fire and forget async in Lua (no await)', () async {
    LuaState state = LuaState.newState();
    state.openLibs();

    bool executed = false;
    Completer<void> completer = Completer<void>();

    state.registerAsync('send_analytics', (args) async {
      await Future.delayed(Duration(milliseconds: 50));
      executed = true;
      completer.complete();
    });

    final script = '''
      send_analytics("click", "data") -- No await, fire and forget
    ''';

    await state.doAsyncString(script);
    
    // Script finishes immediately because we didn't await
    expect(executed, false);

    // Wait for the async task to finish in Dart
    await completer.future;
    expect(executed, true);
  });
}
