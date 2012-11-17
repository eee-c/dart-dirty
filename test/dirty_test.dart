#import('package:unittest/unittest.dart');
#import('package:dart_dirty/dirty.dart');

#import('dart:io');

test_create() {
  group("new DBs", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("creates a new DB", () {
      var db = new Dirty('test/test.db');
      expect(
        new File('test/test.db').existsSync(),
        equals(true)
      );
    });

  });
}

test_write() {
  group("writing", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can write a record to the DB", () {
      var db = new Dirty('test/test.db');
      db.set('everything', {'answer': 42});
      db.close(expectAsync0(() {
        expect(
          new File('test/test.db').lengthSync(),
          greaterThan(0)
        );
      }));

    });

  });
}

main() {
  test_create();
  test_write();
}

removeFixtures() {
  var db = new File('test/test.db');
  if (!db.existsSync()) return;
  db.deleteSync();
}
