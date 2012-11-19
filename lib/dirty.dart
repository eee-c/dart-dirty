#library('dart_dirty');

#import('dart:io');
#import('dart:json');

class Dirty {
  OutputStream _writeStream;
  File db;
  boolean flushing = false;
  List<String> _keys;
  Queue<String> _queue;
  HashMap<String, dynamic> _docs;
  var onLoad;

  Dirty(path, [this.onLoad]) {
    db = new File(path);
    _keys = [];
    _queue = new Queue();
    _docs = {};

    _load();
  }

  void set(String key, value) {
    _keys.add(key);
    _docs[key] = value;
    _queue.add(key);
    _maybeFlush();
  }

  dynamic get(String key) => _docs[key];

  void close([cb]) {
    _writeStream.onClosed = cb;
    _writeStream.close();
  }

  _load() {
    _writeStream = db.openOutputStream(FileMode.APPEND);

    var lines = db.readAsLinesSync();
    lines.forEach((line) {
      var rec = JSON.parse(line);
      _docs[rec['key']] = rec['val'];
    });

    if (onLoad != null) {
      onLoad(this);
    }
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

    flushing = false;
  }
}
