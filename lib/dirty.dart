library dart_dirty;

import 'dart:io';
import 'dart:json';

class Dirty implements HashMap<String, Object> {
  OutputStream _writeStream;
  File db;
  bool flushing = false;
  Queue<String> _queue;
  HashMap<String, Object> _docs;
  var onLoad;

  Dirty(path, {this.onLoad}) {
    db = new File(path);
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
    _writeStream = db.openOutputStream(FileMode.WRITE);
  }

  void forEach(cb) => _docs.forEach(cb);

  void close([cb]) {
    _writeStream.onClosed = cb;
    _writeStream.close();
  }

  _load() {
    var exists = db.existsSync();

    _writeStream = db.openOutputStream(FileMode.APPEND);

    if (!exists) return;

    var inputStream = db.openInputStream();
    var input = new StringInputStream(inputStream);
    input.onLine = () {
      var line = input.readLine();
      var rec = JSON.parse(line);
      _docs[rec['key']] = rec['val'];
    };
    input.onClosed = () {
      onLoad(this);
    };
  }

  _maybeFlush() {
    if (flushing) return;
    _flush();
  }

  _flush() {
    flushing = true;

    _queue.forEach((key) {
      String doc = JSON.stringify({'key': key, 'val': _docs[key]});
      var saved = _writeStream.writeString("$doc\n");
    });

    _writeStream.flush();
    _queue.clear();

    flushing = false;
  }
}
