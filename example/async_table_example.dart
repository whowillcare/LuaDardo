import 'package:lua_dardo_enhanced/lua.dart';
import 'dart:async';

void main() async {
  LuaState lua = LuaState.newState();
  lua.openLibs();

  // Register an asynchronous Dart function that accepts and returns Tables (Maps/Lists)
  lua.registerAsync("process_user_data", (args) async {
    // args[0] is automatically converted from a Lua table to a Dart Map or List
    print("Dart: Received arguments: ${args[0]}");

    final Map userData = args[0] as Map;
    final int userId = userData['id'] ?? 0;
    final List scopes = userData['scopes'] ?? [];

    print("Dart: Start processing user $userId with scopes: $scopes");
    await Future.delayed(Duration(seconds: 1)); // Simulate processing latency
    print("Dart: End processing user $userId");

    // Return a structured Dart Map/List, which automatically converts back to a Lua table
    return {
      'status': 'success',
      'processed_id': userId,
      'metadata': {
        'permissions': ['read', 'write', 'execute'],
        'quota': 100
      }
    };
  });

  // Lua script with async/await handling tables
  final script = '''
print("Lua: Starting script")

local request_payload = {
    id = 404,
    scopes = {"admin", "billing"},
    metadata = { client = "web" }
}

print("Lua: Sending request payload to Dart...")
-- Use await() to suspend execution. Pass table, receive table.
local response = await(process_user_data(request_payload))

print("Lua: Response received!")
print("Lua: status = " .. response.status)
print("Lua: processed_id = " .. response.processed_id)
print("Lua: permissions[2] = " .. response.metadata.permissions[2])
print("Lua: quota = " .. response.metadata.quota)

print("Lua: Script completed")
  ''';

  print("Dart: Running Lua script...");
  await lua.doAsyncString(script);
  print("Dart: Script execution returned");
}
