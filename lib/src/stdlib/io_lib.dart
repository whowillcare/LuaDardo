import '../../lua.dart';
import 'dart:io';
import 'dart:typed_data';


class IOFile {
  RandomAccessFile file;
  String mode;
  String path;

  IOFile(this.path, this.mode, this.file);

  String readLine() {
    List<int> bytes = [];
    while (true) {
      int byte = file.readByteSync();
      if (byte == -1) {
        break;
      }
      bytes.add(byte);
      if (byte == 10) {
        break;
      }
    }

    return String.fromCharCodes(bytes);
  }

  String readAllString() {
    List<int> bytes = [];

    for (;;) {
      var tmp = file.readSync(1024);
      if (tmp.isEmpty) {
        break;
      }

      bytes.addAll(tmp);
    }

    return String.fromCharCodes(bytes);
  }

  Uint8List readAllBytes() {
    List<int> bytes = [];

    for (;;) {
      var tmp = file.readSync(1024);
      if (tmp.isEmpty) {
        break;
      }

      bytes.addAll(tmp);
    }

    return Uint8List.fromList(bytes);
  }
}


class IOLib {
  static const Map<String, DartFunction> _ioFuncs = {
    "read": _ioRead,
    "write": _ioWrite,
    // "flush": _ioFlush,
    // "input": _ioInput,
    // "output": _ioOutput,
    // "lines": _ioLines,
    "open": _ioOpen,
    // "popen": _ioPOpen,
    // "tmpfile": _ioTmpFile,
    "close": _ioClose,
  };

  static int openIOLib(LuaState ls) {
    ls.newLib(_ioFuncs);
    return 1;
  }

  static int _ioOpen(LuaState ls) {
    var path = ls.checkString(1)!;
    var mode = ls.optString(2, "r")!;

    // check path valid
    File file = File(path);
    if (!file.existsSync() && (mode.contains("r"))) {
      ls.pushNil();
      ls.pushString("open file failed: file not exists");
      return 2;
    }

    RandomAccessFile fileHandle;
    if (mode == "r") {
      fileHandle = file.openSync();
    } else if (mode == "w") {
      fileHandle = file.openSync(mode: FileMode.writeOnly);
    } else if (mode == "a") {
      fileHandle = file.openSync(mode: FileMode.writeOnlyAppend);
    } else if (mode == "r+") {
      fileHandle = file.openSync(mode: FileMode.write);
    } else if (mode == "w+") {
      fileHandle = file.openSync(mode: FileMode.write);
    } else if (mode == "a+") {
      fileHandle = file.openSync(mode: FileMode.append);
    } else {
      ls.pushNil();
      ls.pushString("open file failed: invalid mode");
      return 2;
    }

    var ud = ls.newUserdata<IOFile>();
    ud.data = IOFile(path, mode, fileHandle);
    ls.createTable(0, 1);
    ls.getGlobal("io");
    ls.setField(-2, "__index");
    ls.setMetatable(-2);
    return 1;
  }

  static int _ioRead(LuaState ls) {
    var ioFile = ls.toUserdata(1)!.data as IOFile;

    try {
      if (ls.isNoneOrNil(2)) {
        var content = ioFile.readLine();
        ls.pushString(content);
        return 1;
      }

      var format = ls.checkString(2)!;
      if (format != "*a") {
        throw Exception("not support format: $format");
      }

      if (ioFile.mode.contains("b")) {
        var bytes = ioFile.readAllBytes();
        var ud = ls.newUserdata<Uint8List>();
        ud.data = bytes;
      }
      else {
        ls.pushString(ioFile.readAllString());
      }
      return 1;
    } catch (e) {
      ls.pushNil();
      ls.pushString(e.toString());
      return 2;
    }
  }

  static int _ioClose(LuaState ls) {
    var ioFile = ls.toUserdata(1)!.data as IOFile;
    var file = ioFile.file;
    file.closeSync();
    return 0;
  }

  static int _ioWrite(LuaState ls) {
    var ioFile = ls.toUserdata(1)!.data as IOFile;
    var file = ioFile.file;

    var content = ls.checkString(2)!;
    try {
      file.writeStringSync(content);
      ls.pushBoolean(true);
      return 1;
    } catch (e) {
      ls.pushNil();
      ls.pushString(e.toString());
      return 2;
    }
  }
}
