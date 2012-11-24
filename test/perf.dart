import 'package:dart_dirty/dirty.dart';

main() {
  Stopwatch stopwatch = new Stopwatch()..start();
  var db = new Dirty('test/perf.db', onLoad: (db) {
    stopwatch.stop();
    print("done!");
    print("Finshed in ${stopwatch.elapsedMicroseconds} us");
    // print("${db['key99999']}");
  });
}
