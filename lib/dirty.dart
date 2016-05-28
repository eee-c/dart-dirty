library dirty;

import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'package:logging/logging.dart';

typedef OnLoadCallback(Dirty instance);

final Logger _logger = new Logger('Dirty');

/// The Dirty class is a quick and dirty way to create a persistent
/// [HashMap]. In addition to doing all of the usual [HashMap] things, it will
/// store records in an append-only file database.
class Dirty implements HashMap<String, Object> {
  RandomAccessFile _io;
  bool _flushing = false;

  final Map<String, Object> _docs;
  final File _db;
  final Queue<String> _queue;

  /// The optional callback to be invoked when an existing database has been
  /// completely loaded into memory. If defined, this must be a function that
  /// accepts a single argument (a copy of the [Dirty] instance).
  OnLoadCallback onLoad;

  /// The database at [path] will be created if it does not already exist. If the
  /// optional [onLoad] parameter is supplied, it will be invoked with a copy of
  /// the [Dirty] instance.
  Dirty(String dbFilePath, {this.onLoad})
      : _db = new File(dbFilePath),
        _queue = new Queue(),
        _docs = <String, Object>{} {
    if (onLoad == null) onLoad = (_) {};
    _load();
  }

  void operator []=(String key, Object value) {
    _docs[key] = value;
    _queue.add(key);
    _maybeFlush();
  }

  Object operator [](Object key) => _docs[key];

  int get length => _docs.length;

  bool get isEmpty => _docs.isEmpty;

  bool get isNotEmpty => _docs.isNotEmpty;

  Iterable<String> get keys => _docs.keys;

  Iterable<Object> get values => _docs.values;

  bool containsValue(Object v) => _docs.containsValue(v);

  bool containsKey(Object k) => _docs.containsKey(k);

  void addAll(Map<String, Object> m) {
    _docs.addAll(m);
    _queue.addAll(m.keys);
    _maybeFlush();
  }

  Object putIfAbsent(String key, cb) {
    var value = _docs.putIfAbsent(key, cb);
    _queue.add(key);
    _maybeFlush();
    return value;
  }

  Object remove(Object key) {
    var value = _docs.remove(key);
    _queue.add(key);
    _maybeFlush();
    return value;
  }

  void clear() {
    _docs.clear();
    _io.close();
    _io = _db.openSync(mode: FileMode.WRITE);
  }

  void forEach(cb) => _docs.forEach(cb);

  /// Close the database, including the underlying write stream. Once invoked,
  /// no more data will be persisted.
  File close([cb()]) {
    _io
      ..flushSync()
      ..closeSync();
    return _db;
  }

  _load() {
    _io = _db.openSync(mode: FileMode.APPEND);

    List<String> lines = _db.readAsLinesSync();
    lines.forEach((line) {
      var rec = JSON.decode(line);
      if (rec['val'] == null) {
        _docs.remove(rec['key']);
      } else {
        _docs[rec['key']] = rec['val'];
      }
    });

    onLoad(this);
  }

  _maybeFlush() {
    if (_flushing)
      throw new StateError(
          'Flushing in progress, this error should have not happened, please report it.');
    _flush();
  }

  _flush() {
    _flushing = true;
    Queue<String> queueCopy = new Queue.from(_queue);
    _logger.finest('Writing keys: ${queueCopy.toList()}');
    queueCopy.forEach((key) {
      String doc = JSON.encode({'key': key, 'val': _docs[key]});
      _io.writeStringSync("$doc\n");
    });

    _io.flushSync();
    _queue.removeWhere((String k) => queueCopy.contains(k));

    _flushing = false;
  }
}
