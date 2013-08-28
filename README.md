# Dart Dirty

The dart dirty library is persistent [HashMap](http://api.dartlang.org/docs/bleeding_edge/dart_core/HashMap.html) for Dart.

[![](https://drone.io/eee-c/DartDirty/status.png)](https://drone.io/eee-c/DartDirty/latest)


Create a new database with the constructor:

```dart
var db = new Dirty('test/test.db');
```

Open an existing database with the same constructor:

```dart
var db = new Dirty('test/test.db');
```

Then use the usual `HashMap` methods to add records:

```dart
db['everything'] = {'answer': 42};
```

And to remove records:

```dart
db.remove('everything');
```

To ensure that everything is written to the filesystem, it is best to properly close a database:

```dart
db.close();
```

## Performance

I have not really optimized this yet. Using `readAsLines` to read DB records seems less than ideal, but it actually works fairly well. Writing could probably be sped up if data was buffered more, but I focused on read for the first pass.

If you would like to improve, see the `test/mk_perf_db.dart` and `test/perf.dart` scripts. The former creates a 100,000 record DB and the latter reads it back in. On my machine the former takes ~4 minutes to write and ~10 seconds to read. Performance patches welcome!

## Contributors

 * [Nicolas R Dufour](https://github.com/nrdufour)
 * [Ali Ibrahim](https://github.com/alimi)


##License

This software is licensed under the MIT License.

Copyright Chris Strom, 2013.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
