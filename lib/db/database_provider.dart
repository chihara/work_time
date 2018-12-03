
import 'package:mutex/mutex.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working/db/working.dart';


typedef OnOpened();

class DatabaseProvider {
  static const String FILE_NAME = 'worktime.db';
  static Database _db;

  static open({OnOpened onOpened}) async {
    if (null != _db && _db.isOpen) {
      if (null != onOpened) {
        onOpened();
      }
      return;
    }
    getDatabasesPath().then((path) async {
      var mutex = Mutex();
      await mutex.acquire();
      if (null == _db) {
        _db = await openDatabase(
          join(path, FILE_NAME),
          version: 3,
          onCreate: (Database db, int version) async {
            WorkingProvider.create(db, version);
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            WorkingProvider.upgrade(db, oldVersion, newVersion);
          },
        );
      }
      mutex.release();
      if (null != onOpened) {
        onOpened();
      }
    });
  }

  static getWorkingProvider() {
    return null != _db ? WorkingProvider(_db) : null;
  }
}