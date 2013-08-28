import 'package:unittest/unittest.dart';
import 'package:dirty/dirty.dart';

import 'dart:io';

Dirty db;

test_create() {
  group("new DBs", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("creates a new DB", () {
      db = new Dirty('test/test.db');
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
      db = new Dirty('test/test.db');
      db['everything'] =  {'answer': 42};
      db.
        close().
        then(expectAsync1((db_file) {
          expect(
            db_file.lengthSync(),
            greaterThan(0)
          );
        }));

    });

  });
}

test_read() {
  group("reading", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can read a record from the DB", () {
      db = new Dirty('test/test.db');
      db['everything'] =  {'answer': 42};
      expect(
        db['everything'],
        equals({'answer': 42})
      );
    });

    test("can read a record from the DB stored on the filesystem", () {
      expectStorage() {
        new Dirty('test/test.db', onLoad: expectAsync1((db) {
          expect(
            db['everything'],
            equals({'answer': 42})
          );
        }));
      }

      db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};
      db.
        close().
        then(expectAsync1((_) => expectStorage()));
    });

  });
}

test_remove() {
  group("removing", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can remove a record from the DB", () {
      db = new Dirty('test/test.db');

      db['everything'] =  {'answer': 42};
      db.remove('everything');

      expect(
        db['everything'],
        isNull
      );
    });

    test("can remove keys from the DB", () {
      db = new Dirty('test/test.db');

      db['everything'] =  {'answer': 42};
      db.remove('everything');

      expect(
        db.keys.toList(),
        isEmpty
      );
    });

    test("can remove a record from the filesystem store", () {
      expectKeyIsGone() {
        db = new Dirty('test/test.db');
        expect(
          db['everything'],
          isNull
        );
      }

      removeKey() {
        db = new Dirty('test/test.db');
        db.remove('everything');
        db.
          close().
          then(expectAsync1((_) { expectKeyIsGone(); }));
      }

      addKey() {
        db = new Dirty('test/test.db');
        db['everything'] = {'answer': 42};
        db.
          close().
          then(expectAsync1((_) { removeKey(); }));
      }

      addKey();
    });

    test("removes from the list of keys in the filesystem store", () {
      expectKeyIsGone() {
        new Dirty('test/test.db', onLoad: expectAsync1((db) {
          // Why can't I equal a list?!!
          expect(
            db.keys.toList().first,
            equals('first')
          );
          expect(
            db.keys.toList().last,
            equals('last')
          );
          expect(
            db.keys.toList(),
            hasLength(2)
          );
        }));
      }

      removeKey() {
        db = new Dirty('test/test.db');
        db.remove('everything');
        db.close().then(expectAsync1((_){ expectKeyIsGone(); }));
      }

      addKey() {
        db = new Dirty('test/test.db');
        db['first'] = {'answer': 42};
        db['everything'] = {'answer': 42};
        db['last'] = {'answer': 42};
        db.close().then(expectAsync1((_){ removeKey(); }));
      }

      addKey();
    });

    test("can delete the DB entirely from the filesystem", (){
      Dirty db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};

      db.close().
        then(expectAsync1((f) {
          f.deleteSync();
        }));
    });
  });
}

main() {
  test_create();
  test_write();
  test_read();
  test_remove();
}

removeFixtures() {
  File db_file = new File('test/test.db');
  if (!db_file.existsSync()) return;
  db_file.deleteSync();
}
