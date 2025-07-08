class MatchSlice {
  final int start;
  final int end;
  final String source;

  MatchSlice(this.start, this.end, this.source);

  @override
  String toString() {
    return 'MatchSlice{start: $start, end: $end, source: $source}';
  }
}
