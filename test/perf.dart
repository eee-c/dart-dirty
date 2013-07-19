import '../lib/dirty.dart';

main() {
  Stopwatch stopwatch = new Stopwatch()..start();
  var db = new Dirty('test/perf.db', onLoad: (givenDb) {
    stopwatch.stop();
    print("done!");
    print("Finshed in ${stopwatch.elapsedMicroseconds} us");
    // print("${db['key99999']}");
  });
}
