@TestOn("vm")
import 'package:test/test.dart';
import 'package:dirty/dirty.dart';
import 'package:logging/logging.dart';
import 'dart:io';

test_create() {
  group("new DBs", () {
    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("creates a new DB", () {
      Dirty db = new Dirty('test/test.db');
      bool fileExists = new File('test/test.db').existsSync();
      expect(fileExists, true);
      db.close();
    });
  });
}

test_write() {
  group("writing", () {
    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can write a record to the DB", () {
      Dirty db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};
      expect(new File('test/test.db').lengthSync(), isNonZero);
      db.close();
    });

    test('can write multiple values', () {
      Dirty db = new Dirty('test/test.db');
      Map<String, dynamic> values = <String, dynamic>{
        'first': 'test',
        'second': {'answer': 42}
      };
      db.addAll(values);
      expect(db.keys, allOf(contains('first'), contains('second')));
      expect(db['first'], equals(values['first']));
      expect(db['second'], values['second']);
      db.close();
    });

    test('write if key does not exist yet', () {
      Dirty db = new Dirty('test/test.db');
      db['answer'] = 42;
      Object storedVal = db.putIfAbsent('answer', () => 24);
      expect(db['answer'], 42);
      expect(storedVal, 42);
      db.close();
    });

    test('subsequent writes + flushes get persisted', () {
      Dirty db = new Dirty('test/test.db');
      expect(() {
        db['answer'] = 42;
        db['first'] = 'Lady';
        db['president'] = 'Not Trump for sure';
        db.close();
      }, returnsNormally);
    });
  });
}

test_read() {
  group("reading", () {
    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can read a record from the DB", () {
      Dirty db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};
      expect(db['everything'], equals({'answer': 42}));
      db.close();
    });

    test("can read a record from the DB stored on the filesystem", () {
      OnLoadCallback callback = expectAsync((Dirty db) {
        expect(db['everything'], equals({'answer': 42}));
      }, count: 1, max: 1) as OnLoadCallback;

      // write the required value into the DB
      Dirty db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};
      db.close();
      // open a new DB instance and pass callback
      db = new Dirty('test/test.db', onLoad: callback);
      db.close();
    }, timeout: new Timeout(new Duration(seconds: 5)));
  });
}

test_remove() {
  group("removing", () {
    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can remove a record from the DB", () {
      Dirty db = new Dirty('test/test.db');

      db['everything'] = {'answer': 42};
      db.remove('everything');

      expect(db['everything'], isNull);
      db.close();
    });

    test("can remove keys from the DB", () {
      Dirty db = new Dirty('test/test.db');

      db['everything'] = {'answer': 42};
      db.remove('everything');

      expect(db.keys.toList(), isEmpty);
      db.close();
    });

    test("can remove a record from the filesystem store", () {
      expectKeyIsGone() {
        Dirty db = new Dirty('test/test.db');
        expect(db['everything'], isNull);
        db.close();
      }

      removeKey() {
        Dirty db = new Dirty('test/test.db');
        db.remove('everything');
        db.close();
        expectKeyIsGone();
      }

      addKey() {
        Dirty db = new Dirty('test/test.db');
        db['everything'] = {'answer': 42};
        db.close();
        removeKey();
      }
      addKey();
    });

    test("removes from the list of keys in the filesystem store", () {
      expectKeyIsGone() {
        OnLoadCallback callback = expectAsync((Dirty db) {
          expect(db.keys.first, equals('first'));
          expect(db.keys.last, equals('last'));
          expect(db.keys.toList(), hasLength(2));
        }) as OnLoadCallback;
        new Dirty('test/test.db', onLoad: callback)..close();
      }

      removeKey() {
        Dirty db = new Dirty('test/test.db');
        db.remove('everything');
        db.close();
        expectKeyIsGone();
      }

      addKey() {
        Dirty db = new Dirty('test/test.db');
        db['first'] = {'answer': 42};
        db['everything'] = {'answer': 42};
        db['last'] = {'answer': 42};
        db.close();
        removeKey();
      }

      addKey();
    });
  });
}

main() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(print);
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
