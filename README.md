# Dart Dirty

The dart dirty library is persistent [HashMap](http://api.dartlang.org/docs/bleeding_edge/dart_core/HashMap.html) for Dart.

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

##License

This software is licensed under the MIT License.

Copyright Chris Strom, 2012.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
