import './match_slice.dart';


class Match {
  final String source;
  final List<int> _match;
  final List<bool> _isPosition;

  Match(this.source , this._match, this._isPosition);

  @override
  String toString() {
    return 'Match{source: $source, match: $_match}';
  }

  int endPos() {
    return _match[1];
  }

  int startPos() {
    return _match[0];
  }

  int get groupCount {
    return ((_match.length / 2) - 1).toInt();
  }

  bool isPosition(int group) {
    if (group < 0 || group > groupCount) {
      return false;
    }

    return _isPosition[group];
  }

  String? group(int group) {
    if (group < 0 || group > groupCount) {
      return null;
    }
    return source.substring(_match[group * 2], _match[group * 2 + 1]);
  }

  MatchSlice? matchSlice(int group) {
    if (group < 0 || group > groupCount) {
      return null;
    }
    return MatchSlice(_match[group * 2], _match[group * 2 + 1], source);
  }

  String replace(String repl) {
    int esc;
    int lastEnd = 0;
    List<String> res = [];
    while ((esc = repl.indexOf('%', lastEnd)) != -1) {
      res.add(repl.substring(lastEnd, esc));
      esc++;
      if (esc == repl.length) {
        throw ArgumentError('invalid use of % in replacement string');
      }

      int escChar = repl.codeUnitAt(esc);
      if (escChar == 0x25) { // 0x25 ascii is %
        res.add('%');
      }
      else if (escChar >= 0x31 && escChar <= 0x39) { // 0x30 ascii is 0, 0x39 ascii is 9
        int group = escChar - 0x30;
        if (group > groupCount) {
          throw ArgumentError('invalid capture index');
        }
        res.add(this.group(group) ?? '');
      }
      else {
        throw ArgumentError('invalid capture index');
      }
      lastEnd = esc + 1;
    }

    res.add(repl.substring(lastEnd));
    return res.join('');
  }
}
