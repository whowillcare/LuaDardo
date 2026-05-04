import 'package:lua_dardo_enhanced/lua.dart';
import 'dart:async';

void main() async {
  LuaState lua = LuaState.newState();
  lua.openLibs();

  // Register asynchronous Dart functions
  lua.registerAsync("http_get", (args) async {
    print("Dart: Start HTTP GET for ${args[0]}");
    await Future.delayed(Duration(seconds: 1)); // Simulate network latency
    print("Dart: End HTTP GET");
    return "200 OK - ${args[0]}";
  });

  lua.registerAsync("send_analytics", (args) async {
    print("Dart: Start analytics for ${args[0]} with data ${args[1]}");
    await Future.delayed(Duration(milliseconds: 500));
    print("Dart: Analytics sent");
    return null;
  });

  // Lua script with async/await
  final script = '''
print("Lua: Starting script")

-- Use await() to suspend execution and wait for the Future to resolve
local response = await(http_get("https://example.com"))
print("Lua: Response received: " .. response)

-- Fire and forget, no await. Coroutine continues immediately.
send_analytics("click", "homepage")
print("Lua: Analytics event triggered, not waiting for completion")

print("Lua: Script completed")
  ''';

  print("Dart: Running Lua script...");
  await lua.doAsyncString(script);
  print("Dart: Script execution returned (note: background tasks may still be running)");

  // Add a delay to let the fire-and-forget task finish before the process exits
  await Future.delayed(Duration(seconds: 1));
  print("Dart: Example finished");
}
