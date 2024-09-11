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
}
