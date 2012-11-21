# Dart Dirty

The dart dirty library is persistent [HashMap](http://api.dartlang.org/docs/bleeding_edge/dart_core/HashMap.html) for Dart.

Create a new database with the constructor:

{:language="dart"}
~~~~
var db = new Dirty('test/test.db');
~~~~

Open an existing database with the same constructor:

{:language="dart"}
~~~~
var db = new Dirty('test/test.db');
~~~~

Then use the usual `HashMap` methods to add records:

{:language="dart"}
~~~~
db['everything'] = {'answer': 42};
~~~~

And to remove records:

{:language="dart}
~~~~
db.remove('everything');
~~~~

To ensure that everything is written to the filesystem, it is best to properly close a database:

{:language="dart"}
~~~~
db.close();
~~~~
