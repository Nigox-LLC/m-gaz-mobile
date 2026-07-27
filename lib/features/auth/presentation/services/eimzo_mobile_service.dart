import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/eimzo_mobile_session.dart';
import '../../domain/entities/eimzo_status.dart';

class EImzoLaunchException implements Exception {
  const EImzoLaunchException();
}

class EImzoPollingException implements Exception {
  const EImzoPollingException(this.message);

  final String message;

  @override
  String toString() => message;
}

@lazySingleton
class EImzoMobileService {
  Timer? _timer;
  Completer<EImzoStatus>? _completer;

  String buildDeepLink(EImzoMobileSession session) {
    final hash = _Gost341194.hashAscii(session.challenge.trim()).toLowerCase();
    final siteId = session.siteId.trim();
    final documentId = session.documentId.trim();

    final body = '$siteId$documentId$hash';
    final crcHex = _Crc32.hex(body);
    final qc = '$body$crcHex';
    _log(
      'Deep link payload built: siteId=$siteId, documentId=$documentId, '
      'hash=$hash, crc32=$crcHex, qcLength=${qc.length}',
    );

    return 'eimzo://sign?qc=$qc';
  }

  Future<void> launch(EImzoMobileSession session) async {
    _log('Launching E-Imzo ID-CARD for documentId=${session.documentId}');
    final launched = await launchUrl(
      Uri.parse(buildDeepLink(session)),
      mode: LaunchMode.externalNonBrowserApplication,
    );
    _log('E-Imzo ID-CARD launch result: $launched');
    if (!launched) throw const EImzoLaunchException();
  }

  Future<EImzoStatus> waitForCompletion({
    required EImzoMobileSession session,
    required Future<EImzoStatus> Function(String documentId) getStatus,
    bool stopWhenWaiting = false,
  }) {
    cancel();
    _log(
      'Status polling started for documentId=${session.documentId}; '
      'stopWhenWaiting=$stopWhenWaiting',
    );
    final completer = Completer<EImzoStatus>();
    _completer = completer;
    final deadline = DateTime.now().add(session.ttl);

    Future<void> poll() async {
      if (!identical(_completer, completer) || completer.isCompleted) return;
      try {
        final status = await getStatus(session.documentId);
        _log(
          'Status received for documentId=${session.documentId}: '
          '${status.code}',
        );
        if (!identical(_completer, completer) || completer.isCompleted) return;
        if (stopWhenWaiting && status.isWaiting) {
          _log('Initial status=2 received; E-Imzo session is ready');
          _finish(completer, status);
          return;
        }
        if (status.isCompleted) {
          _log('E-Imzo signing completed with status=1');
          _finish(completer, status);
          return;
        }
        if (!status.isWaiting) {
          _log('E-Imzo polling failed with status=${status.code}');
          _fail(
            completer,
            EImzoPollingException(
              status.message.isEmpty ? 'E-Imzo tasdiqlanmadi' : status.message,
            ),
          );
          return;
        }
        if (DateTime.now().isAfter(deadline)) {
          _log('E-Imzo polling timed out');
          _fail(completer, const EImzoPollingException('E-Imzo vaqti tugadi'));
        }
      } catch (error, stackTrace) {
        _fail(completer, error, stackTrace);
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => poll());
    unawaited(poll());
    return completer.future;
  }

  void cancel() {
    final completer = _completer;
    _timer?.cancel();
    _timer = null;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      _log('E-Imzo polling cancelled');
      completer.completeError(
        const EImzoPollingException('E-Imzo bekor qilindi'),
      );
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[E-Imzo Auth] $message');
  }

  void _finish(Completer<EImzoStatus> completer, EImzoStatus status) {
    if (!identical(_completer, completer) || completer.isCompleted) return;
    _timer?.cancel();
    _timer = null;
    _completer = null;
    completer.complete(status);
  }

  void _fail(
    Completer<EImzoStatus> completer,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!identical(_completer, completer) || completer.isCompleted) return;
    _timer?.cancel();
    _timer = null;
    _completer = null;
    completer.completeError(error, stackTrace);
  }
}

class _Crc32 {
  static String hex(String value) {
    final bytes = _hexBytes(value);
    var crc = 0xFFFFFFFF;

    for (final byte in bytes) {
      crc ^= byte;
      for (var j = 0; j < 8; j++) {
        crc = (crc & 1 != 0) ? ((crc >> 1) ^ 0xEDB88320) : (crc >> 1);
      }
    }

    return (~crc & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  }
}

class _Gost341194 {
  static const _sBox = <int>[
    10,
    4,
    5,
    6,
    8,
    1,
    3,
    7,
    13,
    12,
    14,
    0,
    9,
    2,
    11,
    15,
    5,
    15,
    4,
    0,
    2,
    13,
    11,
    9,
    1,
    7,
    6,
    3,
    12,
    14,
    10,
    8,
    7,
    15,
    12,
    14,
    9,
    4,
    1,
    0,
    3,
    11,
    5,
    2,
    6,
    10,
    8,
    13,
    4,
    10,
    7,
    12,
    0,
    15,
    2,
    8,
    14,
    1,
    6,
    5,
    13,
    11,
    9,
    3,
    7,
    6,
    4,
    11,
    9,
    12,
    2,
    10,
    1,
    8,
    0,
    14,
    15,
    13,
    3,
    5,
    7,
    6,
    2,
    4,
    13,
    9,
    15,
    0,
    10,
    1,
    5,
    11,
    8,
    14,
    12,
    3,
    13,
    14,
    4,
    1,
    7,
    0,
    5,
    10,
    3,
    12,
    8,
    15,
    6,
    2,
    9,
    11,
    1,
    3,
    10,
    9,
    5,
    11,
    4,
    15,
    8,
    6,
    7,
    14,
    13,
    0,
    2,
    12,
  ];
  static const _c2 = <int>[
    0,
    255,
    0,
    255,
    0,
    255,
    0,
    255,
    255,
    0,
    255,
    0,
    255,
    0,
    255,
    0,
    0,
    255,
    255,
    0,
    255,
    0,
    0,
    255,
    255,
    0,
    0,
    0,
    255,
    255,
    0,
    255,
  ];

  static String hashAscii(String value) {
    final digest = _GostDigest(_sBox, _c2);
    digest.update(value.codeUnits.map((unit) => unit & 0xff));
    return digest
        .digest()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

class _GostDigest {
  _GostDigest(this._sBox, List<int> c2)
    : _cipher = _GostCipher(_sBox),
      _c = List<List<int>>.generate(4, (_) => List<int>.filled(32, 0)),
      _h = List<int>.filled(32, 0),
      _length = List<int>.filled(32, 0),
      _message = List<int>.filled(32, 0),
      _sum = List<int>.filled(32, 0),
      _buffer = List<int>.filled(32, 0),
      _keyBuffer = List<int>.filled(32, 0),
      _aBuffer = List<int>.filled(8, 0),
      _work = List<int>.filled(16, 0),
      _work2 = List<int>.filled(16, 0),
      _s = List<int>.filled(32, 0),
      _u = List<int>.filled(32, 0),
      _v = List<int>.filled(32, 0),
      _w = List<int>.filled(32, 0) {
    for (var index = 0; index < 32; index++) {
      _c[2][index] = c2[index];
    }
  }

  final List<int> _sBox;
  final _GostCipher _cipher;
  final List<List<int>> _c;
  final List<int> _h;
  final List<int> _length;
  final List<int> _message;
  final List<int> _sum;
  final List<int> _buffer;
  final List<int> _keyBuffer;
  final List<int> _aBuffer;
  final List<int> _work;
  final List<int> _work2;
  final List<int> _s;
  final List<int> _u;
  final List<int> _v;
  final List<int> _w;
  var _bufferOffset = 0;
  var _byteCount = 0;

  void update(Iterable<int> bytes) {
    for (final byte in bytes) {
      _updateByte(byte);
    }
  }

  List<int> digest() {
    final bitCount = _byteCount * 8;
    _length[0] = bitCount & 0xff;
    _length[1] = (bitCount >> 8) & 0xff;
    _length[2] = (bitCount >> 16) & 0xff;
    _length[3] = (bitCount >> 24) & 0xff;
    while (_bufferOffset != 0) {
      _updateByte(0);
    }
    _processBlock(_length);
    _processBlock(_sum);
    return List<int>.from(_h);
  }

  void _updateByte(int byte) {
    _buffer[_bufferOffset++] = byte & 0xff;
    if (_bufferOffset == 32) {
      _sumBlock(_buffer);
      _processBlock(_buffer);
      _bufferOffset = 0;
    }
    _byteCount++;
  }

  List<int> _permute(List<int> input) {
    for (var index = 0; index < 8; index++) {
      _keyBuffer[index * 4] = input[index];
      _keyBuffer[index * 4 + 1] = input[index + 8];
      _keyBuffer[index * 4 + 2] = input[index + 16];
      _keyBuffer[index * 4 + 3] = input[index + 24];
    }
    return _keyBuffer;
  }

  void _transformA(List<int> input) {
    for (var index = 0; index < 8; index++) {
      _aBuffer[index] = (input[index] ^ input[index + 8]) & 0xff;
    }
    for (var index = 0; index < 24; index++) {
      input[index] = input[index + 8];
    }
    for (var index = 0; index < 8; index++) {
      input[index + 24] = _aBuffer[index];
    }
  }

  void _mix(List<int> input) {
    for (var index = 0; index < 16; index++) {
      _work[index] = ((input[index * 2 + 1] << 8) | input[index * 2]) & 0xffff;
    }
    _work2[15] =
        (_work[0] ^ _work[1] ^ _work[2] ^ _work[3] ^ _work[12] ^ _work[15]) &
        0xffff;
    for (var index = 0; index < 15; index++) {
      _work2[index] = _work[index + 1];
    }
    for (var index = 0; index < 16; index++) {
      input[index * 2 + 1] = (_work2[index] >> 8) & 0xff;
      input[index * 2] = _work2[index] & 0xff;
    }
  }

  void _processBlock(List<int> input) {
    for (var index = 0; index < 32; index++) {
      _message[index] = input[index];
      _u[index] = _h[index];
      _v[index] = _message[index];
      _w[index] = (_u[index] ^ _v[index]) & 0xff;
    }
    _cipher.encrypt(_permute(_w), _s, 0, _h, 0);
    for (var index = 1; index < 4; index++) {
      _transformA(_u);
      for (var byte = 0; byte < 32; byte++) {
        _u[byte] = (_u[byte] ^ _c[index][byte]) & 0xff;
      }
      _transformA(_v);
      _transformA(_v);
      for (var byte = 0; byte < 32; byte++) {
        _w[byte] = (_u[byte] ^ _v[byte]) & 0xff;
      }
      _cipher.encrypt(_permute(_w), _s, index * 8, _h, index * 8);
    }
    for (var index = 0; index < 12; index++) _mix(_s);
    for (var index = 0; index < 32; index++) {
      _s[index] = (_s[index] ^ _message[index]) & 0xff;
    }
    _mix(_s);
    for (var index = 0; index < 32; index++) {
      _s[index] = (_h[index] ^ _s[index]) & 0xff;
    }
    for (var index = 0; index < 61; index++) _mix(_s);
    for (var index = 0; index < 32; index++) {
      _h[index] = _s[index];
    }
  }

  void _sumBlock(List<int> input) {
    var carry = 0;
    for (var index = 0; index < 32; index++) {
      final sum = _sum[index] + input[index] + carry;
      _sum[index] = sum & 0xff;
      carry = sum >> 8;
    }
  }
}

class _GostCipher {
  _GostCipher(this._sBox);

  final List<int> _sBox;
  final _key = List<int>.filled(8, 0);

  void encrypt(
    List<int> key,
    List<int> output,
    int outputOffset,
    List<int> input,
    int inputOffset,
  ) {
    for (var index = 0; index < 8; index++) {
      _key[index] = _bytesToInt(key, index * 4);
    }
    var n1 = _bytesToInt(input, inputOffset);
    var n2 = _bytesToInt(input, inputOffset + 4);
    for (var round = 0; round < 3; round++) {
      for (var index = 0; index < 8; index++) {
        final previous = n1;
        n1 = (n2 ^ _mainStep(n1, _key[index])) & 0xffffffff;
        n2 = previous;
      }
    }
    for (var index = 7; index > 0; index--) {
      final previous = n1;
      n1 = (n2 ^ _mainStep(n1, _key[index])) & 0xffffffff;
      n2 = previous;
    }
    n2 = (n2 ^ _mainStep(n1, _key[0])) & 0xffffffff;
    _intToBytes(n1, output, outputOffset);
    _intToBytes(n2, output, outputOffset + 4);
  }

  int _mainStep(int n1, int key) {
    final value = (n1 + key) & 0xffffffff;
    var substituted = 0;
    for (var index = 0; index < 8; index++) {
      substituted |=
          _sBox[index * 16 + ((value >> (index * 4)) & 0x0f)] << (index * 4);
    }
    substituted &= 0xffffffff;
    return ((substituted << 11) | (substituted >> 21)) & 0xffffffff;
  }

  int _bytesToInt(List<int> bytes, int offset) =>
      (bytes[offset] |
          (bytes[offset + 1] << 8) |
          (bytes[offset + 2] << 16) |
          (bytes[offset + 3] << 24)) &
      0xffffffff;

  void _intToBytes(int value, List<int> output, int offset) {
    output[offset] = value & 0xff;
    output[offset + 1] = (value >> 8) & 0xff;
    output[offset + 2] = (value >> 16) & 0xff;
    output[offset + 3] = (value >> 24) & 0xff;
  }
}

List<int> _hexBytes(String value) {
  if (value.length.isOdd)
    throw const FormatException('Expected hexadecimal data.');
  return List<int>.generate(value.length ~/ 2, (index) {
    final byte = int.tryParse(
      value.substring(index * 2, index * 2 + 2),
      radix: 16,
    );
    if (byte == null) throw const FormatException('Expected hexadecimal data.');
    return byte;
  });
}
