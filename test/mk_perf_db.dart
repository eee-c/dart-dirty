import 'package:unittest/unittest.dart';
import 'package:dart_dirty/dirty.dart';

main() {
  var db = new Dirty('test/perf.db');
  db.clear();
  for (var i=0; i<1e5; i++) {
    db["key$i"] = {
      'value': i,
      'noise': """
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
        xxxxx xxxxx
      """
    };
  }
  db.close();
}
