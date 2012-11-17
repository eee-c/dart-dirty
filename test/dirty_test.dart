#import('package:unittest/unittest.dart');
#import('package:dart_dirty/dirty.dart');

#import('dart:io');

test_create() {
  test("creates a new DB", () {
    var db = new Dirty('test/test.db');
    expect(
      new File('test/test.db').existsSync(),
      equals(true)
    );
  });
}

main() {
  before();
  test_create();
}

before() {
  var db = new File('test/test.db');
  if (!db.existsSync()) return;
  db.deleteSync();
}
