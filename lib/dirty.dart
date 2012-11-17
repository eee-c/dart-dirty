#library('dart_dirty');

#import('dart:io');

class Dirty {
  OutputStream _writeStream;
  File db;

  Dirty(path) {
    db = new File(path);
    _load();
  }

  _load() {
    _writeStream = db.openOutputStream(FileMode.APPEND);
  }
}
