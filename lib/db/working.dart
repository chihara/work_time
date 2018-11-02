
import 'package:sqflite/sqflite.dart';

const String DB_NAME = 'worktime.db';

class Working {
  static const String TABLE_NAME = 'working';
  static const String ID = '_id';
  static const String YEAR = 'year';
  static const String MONTH = 'month';
  static const String DAY = 'day';
  static const String START = 'start';
  static const String END = 'end';
  static const String REST = 'rest';
  static const String DURATION = 'duration';
  static const String HOLIDAY = 'holiday';

  int id;
  int year;
  int month;
  int day;
  double start;
  double end;
  double rest;
  double duration;
  bool holiday = false;
  bool estimated = false;

  Working(
      this.year,
      this.month,
      this.day,
      this.start,
      this.end,
      this.rest,
  ) {
    duration = end - start - rest;
  }

  Working.fromDate(
      DateTime date,
      {
        Map<String, double> time,
      }
  ) {
    year = date.year;
    month = date.month;
    day = date.day;
    if (null != time) {
      start = time[START];
      end = time[END];
      rest = time[REST];
      if (null != start && null != end && null != rest)
        duration = end - start - rest;
    } else {
      duration = 0.0;
    }
  }

  Working.fromMap(Map<String, dynamic> map) {
    id = map[ID];
    year = map[YEAR];
    month = map[MONTH];
    day = map[DAY];
    start = map[START];
    end = map[END];
    rest = map[REST];
    duration = map[DURATION];
    holiday = (map[HOLIDAY] == 'true');
  }

  setTime({double start, double end, double rest}) {
    if (null != start)
      this.start = start;
    if (null != end)
      this.end = end;
    if (null != rest)
      this.rest = rest;
    this.duration = this.end - this.start - this.rest;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      YEAR: year,
      MONTH: month,
      DAY: day,
      START: start,
      END: end,
      REST: rest,
      DURATION: duration,
      HOLIDAY: holiday.toString(),
    };
    if (id != null) {
      map[ID] = id;
    }
    return map;
  }
}

class WorkingProvider {
  Database database;

  Future open(String path) async {
    database = await openDatabase(
      path,
      version: 2,
      onCreate: (Database database, int version) async {
        await database.execute('''
          CREATE TABLE ${Working.TABLE_NAME} (
            ${Working.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Working.YEAR} INTEGER,
            ${Working.MONTH} INTEGER,
            ${Working.DAY} INTEGER,
            ${Working.START} REAL,
            ${Working.END} REAL,
            ${Working.REST} REAL,
            ${Working.DURATION} REAL,
            ${Working.HOLIDAY} TEXT,
          UNIQUE (
            ${Working.YEAR},
            ${Working.MONTH},
            ${Working.DAY}
          ))
        ''');
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion && 2 == newVersion) {
          await database.execute('ALTER TABLE ${Working.TABLE_NAME} ADD ${Working.HOLIDAY} TEXT');
        }
      }
    );
  }

  Future<Working> insert(Working working) async {
    working.id = await database.insert(Working.TABLE_NAME, working.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return working;
  }

  Future<Working> get(DateTime date) async {
    List<Map> maps = await database.query(Working.TABLE_NAME,
        where: "${Working.YEAR} = ? AND ${Working.MONTH} = ? AND ${Working.DAY} = ?",
        whereArgs: [date.year, date.month, date.day]);
    if (0 < maps.length) {
      return Working.fromMap(maps.first);
    }
    return null;
  }

  Future<List> list(DateTime date) async {
    List<Map> maps = await database.query(Working.TABLE_NAME,
        where: "${Working.YEAR} = ? AND ${Working.MONTH} = ?",
        whereArgs: [date.year, date.month],
        orderBy: "${Working.DAY} ASC");
    List<Working> list = List<Working>();
    maps.forEach((it) => list.add(Working.fromMap(it)));
    return list;
  }

  delete(DateTime date) async {
    await database.delete(Working.TABLE_NAME,
        where: "${Working.YEAR} = ? AND ${Working.MONTH} = ? AND ${Working.DAY} = ?",
        whereArgs: [date.year, date.month, date.day]);
  }
}