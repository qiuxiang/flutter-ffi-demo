import 'dart:convert';
import 'dart:ffi';

/// The contents of a native zero-terminated array of UTF-8 code units.
///
/// The Utf8 type itself has no functionality, it's only intended to be used
/// through a `Pointer<Utf8>` representing the entire array. This pointer is
/// the equivalent of a char pointer (`const char*`) in C code.
class Utf8 extends Opaque {}

/// Extension method for converting a`Pointer<Utf8>` to a [String].
extension Utf8Pointer on Pointer<Utf8> {
  /// The number of UTF-8 code units in this zero-terminated UTF-8 string.
  ///
  /// The UTF-8 code units of the strings are the non-zero code units up to the
  /// first zero code unit.
  int get length {
    final array = cast<Uint8>();
    var length = 0;
    while (array[length] != 0) {
      length++;
    }
    return length;
  }

  /// Converts this UTF-8 encoded string to a Dart string.
  ///
  /// Decodes the UTF-8 code units of this zero-terminated byte array as
  /// Unicode code points and creates a Dart string containing those code
  /// points.
  ///
  /// If [length] is provided, zero-termination is ignored and the result can
  /// contain NUL characters.
  String toDartString({int? length}) {
    if (length != null) {
      RangeError.checkNotNegative(length, 'length');
    } else {
      length = this.length;
    }
    return utf8.decode(cast<Uint8>().asTypedList(length));
  }
}

final lib = DynamicLibrary.open('libffi.so');

final int Function(int x, int y) nativeAdd = lib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add')
    .asFunction();

typedef Hello = Pointer<Utf8> Function();
final hello = lib.lookupFunction<Hello, Hello>('hello');
