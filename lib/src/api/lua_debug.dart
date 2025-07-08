

class HookContext {
  int hookId;
  int line;
  String fileName;
  // hook function define here
  Function hookFunction;

  HookContext(this.hookId, this.line, this.fileName, this.hookFunction);

  bool isHooked(String fileName, int line) {
    return this.line == line && fileName.contains(this.fileName);
  }

  void triggerHook() {
    hookFunction();
  }
}


abstract class LuaDebug {
  void setHook(HookContext context);
}
