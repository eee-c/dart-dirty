## 0.1.5

### Test Changes
* `unittest` package has been removed and replaced with test
* a few new tests have also been added

### Core library changes
* `OnLoadCallback` typedef added, constructor `onLoad` parameter now has to match it
* `operator[]`, `remove`, `containsKey` interface overrides have been adjusted to to match declaration signature
* `addAll` now adds keys to queue and attempts to flush as well, just like `operator[]=`
* Initialization changes:
  * if the DB file is not present on the disk, it will be created. If that cannot be performed, an exception is raised.
* If flushing is in progress and a new flush is invoked, Dirty will no longer fail silently, a `StateError` will be raised.
* Fixed an issue: sometimes keys would not get persisted

### Code cleanup
* Doc comments have been converted from block comments to `///` format
* Minor code-style upgrades
* strong mode enabled for library

### Possible breaking changes
* changes to `addAll`
* database file will be created on Class instantiation if it is not present on path