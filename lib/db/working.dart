
import 'package:sqflite/sqflite.dart';

final String tableWorking = "working";
final String columnId = "_id";
final String columnYear = "year";
final String columnMonth = "month";
final String columnDay = "day";
final String columnStart = "start";
final String columnEnd = "end";
final String columnRest = "rest";
final String columnDuration = "duration";
final String columnHoliday = "holiday";

class Working {
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
      start = time[columnStart];
      end = time[columnEnd];
      rest = time[columnRest];
      if (null != start && null != end && null != rest)
        duration = end - start - rest;
    } else {
      duration = 0.0;
    }
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

  setDuration(double duration) {
    this.duration = duration;
    this.start = 10.0;
    this.end = 11.0 + duration;
    this.rest = 1.0;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnYear: year,
      columnMonth: month,
      columnDay: day,
      columnStart: start,
      columnEnd: end,
      columnRest: rest,
      columnDuration: duration,
      columnHoliday: holiday.toString(),
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Working.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    year = map[columnYear];
    month = map[columnMonth];
    day = map[columnDay];
    start = map[columnStart];
    end = map[columnEnd];
    rest = map[columnRest];
    duration = map[columnDuration];
    holiday = map[columnHoliday] == 'true';
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
          CREATE TABLE $tableWorking (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnYear INTEGER,
            $columnMonth INTEGER,
            $columnDay INTEGER,
            $columnStart REAL,
            $columnEnd REAL,
            $columnRest REAL,
            $columnDuration REAL,
            $columnHoliday TEXT,
          UNIQUE (
            $columnYear,
            $columnMonth,
            $columnDay
          ))
        ''');
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion && 2 == newVersion) {
          await database.execute('ALTER TABLE $tableWorking ADD $columnHoliday TEXT');
        }
      }
    );
  }

  Future<Working> insert(Working working) async {
    working.id = await database.insert(tableWorking, working.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return working;
  }

  Future<Working> get(DateTime date) async {
    List<Map> maps = await database.query(tableWorking,
        where: "$columnYear = ? AND $columnMonth = ? AND $columnDay = ?",
        whereArgs: [date.year, date.month, date.day]);
    if (0 < maps.length) {
      return Working.fromMap(maps.first);
    }
    return null;
  }

  Future<List> list(DateTime date) async {
    List<Map> maps = await database.query(tableWorking,
        where: "$columnYear = ? AND $columnMonth = ?",
        whereArgs: [date.year, date.month],
        orderBy: "$columnDay ASC");
    List<Working> list = List<Working>();
    maps.forEach((it) => list.add(Working.fromMap(it)));
    return list;
  }

  delete(DateTime date) async {
    await database.delete(tableWorking,
        where: "$columnYear = ? AND $columnMonth = ? AND $columnDay = ?",
        whereArgs: [date.year, date.month, date.day]);
  }
}