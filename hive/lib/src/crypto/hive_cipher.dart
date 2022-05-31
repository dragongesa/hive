part of hive;

/// Abstract cipher can be implemented to customize encryption.
///
/// Encryption and decryption can be either synchronous (e.g. with the
/// [HiveAesCipher] implementation) or asynchronous for use with
/// hardware-accelerated crypto implementations.
abstract class HiveCipher {
  /// Calculate a hash of the key. Make sure to use a secure hash.
  int calculateKeyCrc();

  /// The maximum size the input can have after it has been encrypted.
  int maxEncryptedSize(Uint8List inp);

  /// Encrypt the given bytes.
  ///
  /// - [inp]: the total bytes in plain text
  /// - [inpOff]: the byte offset to start encryption at
  /// - [inpLength]: the number of bytes (length) to encrypt
  /// - [getOut]: the buffer to write the encrypted output in
  /// - [outOff]: the byte offset to write the encrypted output to
  ///
  /// returns the length of the new encrypted output
  FutureOr<ParallelEncryption> encryptParallel(
    Uint8List inp,
    int inpOff,
    int inpLength,
    Uint8List Function() getOut,
    int Function() getOutOff,
  );

  /// Encrypt the given bytes.
  ///
  /// - [inp]: the total bytes in plain text
  /// - [inpOff]: the byte offset to start encryption at
  /// - [inpLength]: the number of bytes (length) to encrypt
  /// - [out]: the buffer to write the encrypted output in
  /// - [outOff]: the byte offset to write the encrypted output to
  ///
  /// returns the length of the new encrypted output
  @Deprecated('Use encryptParallel instead')
  FutureOr<int> Function(
          Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff)?
      encrypt;

  /// Decrypt the given bytes.
  ///
  /// - [inp]: the total encrypted bytes
  /// - [inpOff]: the byte offset to start decryption at
  /// - [inpLength]: the number of bytes (length) to decrypt
  /// - [out]: the buffer to write the decrypted output in
  /// - [outOff]: the byte offset to write the decrypted output to
  ///
  /// returns the length of the new decrypted output
  FutureOr<int> decrypt(
      Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff);
}

/// helper class providing information on [HiveCipher.encryptParallel]
///
/// this class is returned as the intermediate result of a parallel encryption
/// and provides the data required for the [BinaryWriter] to perform loss-less
/// parallel encryption.
///
/// in case the cipher does not support parallel encryption
/// (see [outputLength]), use [ParallelEncryption.serial].
///
class ParallelEncryption {
  /// the final length of the encrypted buffer
  ///
  /// for most cryptographic algorithms, this should be known *before* te actual
  /// encryption
  final int outputLength;

  /// the operation happening in background
  ///
  /// the future should complete as soon as the buffer is properly encrypted in
  /// background
  ///
  /// if null, the operation is done in serial mode
  final FutureOr<Uint8List> operation;

  const ParallelEncryption(
      {required this.outputLength, required this.operation});

  factory ParallelEncryption.serial(Uint8List result) {
    return ParallelEncryption(outputLength: result.length, operation: result);
  }
}
