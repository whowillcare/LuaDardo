class LuaYieldException implements Exception {
  final int nResults;

  LuaYieldException(this.nResults);

  @override
  String toString() => 'LuaYieldException(nResults: $nResults)';
}