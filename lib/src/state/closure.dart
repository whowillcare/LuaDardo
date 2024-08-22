import '../api/lua_type.dart';
import '../binchunk/binary_chunk.dart';
import 'upvalue_holder.dart';
import '../types/closure_context.dart';

class Closure {

  final Prototype? proto;
  final DartFunction? dartFunc;
  final List<UpvalueHolder?> upvals;
  final ctx = ClosureContext();

  Closure(Prototype this.proto) :
        this.dartFunc = null,
        this.upvals = List<UpvalueHolder?>.filled(proto.upvalues.length,null);

  Closure.DartFunc(this.dartFunc, int nUpvals) :
        this.proto = null,
        this.upvals = List<UpvalueHolder?>.filled(nUpvals,null);

}
