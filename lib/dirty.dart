library dirty;

import 'dart:io';
import 'dart:json';

/**
 * The Dirty class is a quick and dirty way to create a persistent
 * [HashMap]. In addition to doing all of the usual [HashMap] things, it will
 * store records in an append-only file database.
 */
class Dirty implements HashMap<String, Object> {
  OutputStream _writeStream;
  File _db;
  bool _flushing = false;
  Queue<String> _queue;
  HashMap<String, Object> _docs;

  /**
   * The optional callback to be invoked when an existing database has been
   * completely loaded into memory. If defined, this must be a function that
   * accepts a single argument (a copy of the [Dirty] instance).
   */
  var onLoad;

  /**
   * The database at [path] will be created if it does not already exist. If the
   * optional [onLoad] parameter is supplied, it will be invoked with a copy of
   * the [Dirty] instance.
   */
  Dirty(path, {this.onLoad}) {
    _db = new File(path);
    _queue = new Queue();
    _docs = {};

    if (onLoad == null) onLoad = (_){};
    _load();
  }

  void operator []=(String key, Object value) {
    _docs[key] = value;
    _queue.add(key);
    _maybeFlush();
  }

  Object operator [](String key) => _docs[key];

  int get length => _docs.length;
  bool get isEmpty => _docs.isEmpty;
  Collection<String> get keys => _docs.keys;
  Collection<Object> get values => _docs.values;
  bool containsValue(Object v) => _docs.containsValue(v);
  bool containsKey(String k) => _docs.containsKey(k);

  Object putIfAbsent(String key, cb) {
    var value = _docs.putIfAbsent(key, cb);
    _queue.add(key);
    _maybeFlush();
    return value;
  }

  Object remove(String key) {
    var value = _docs.remove(key);
    _queue.add(key);
    _maybeFlush();
    return value;
  }

  void clear() {
    _docs.clear();
    _writeStream.close();
    _writeStream = _db.openOutputStream(FileMode.WRITE);
  }

  void forEach(cb) => _docs.forEach(cb);

  /**
   * Close the database, including the underlying write stream. Once invoked,
   * no more data will be persisted. If supplied, the callback [cb] will be
   * invoked with no parameters.
   */
  void close([cb]) {
    _writeStream.onClosed = cb;
    _writeStream.close();
  }

  _load() {
    var exists = _db.existsSync();

    _writeStream = _db.openOutputStream(FileMode.APPEND);

    if (!exists) return;

    _db.readAsLines().then((lines) {
      lines.forEach((line) {
        var rec = JSON.parse(line);
        if (rec['val'] == null) {
          _docs.remove(rec['key']);
        }
        else {
          _docs[rec['key']] = rec['val'];
        }
      });

      onLoad(this);
    });
  }

  _maybeFlush() {
    if (_flushing) return;
    _flush();
  }

  _flush() {
    _flushing = true;

    _queue.forEach((key) {
      String doc = JSON.stringify({'key': key, 'val': _docs[key]});
      var saved = _writeStream.writeString("$doc\n");
    });

    _writeStream.flush();
    _queue.clear();

    _flushing = false;
  }
}
