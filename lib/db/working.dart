
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

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
  static const String COMPANY_HOLIDAY = 'company_holiday';
  static const String DATE = 'date';

  int id;
  int year;
  int month;
  int day;
  DateTime date;
  double start;
  double end;
  double rest;
  double duration;
  bool holiday = false;
  bool companyHoliday = false;
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
    date = DateTime(year, month, day);
  }

  Working.fromDateTime(DateTime datetime, {
    Map<String, double> time,
  }) {
    year = datetime.year;
    month = datetime.month;
    day = datetime.day;
    date = datetime;
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
    date = DateFormat('yyyy/MM/dd').parse(map[DATE]);
    start = map[START];
    end = map[END];
    rest = map[REST];
    duration = map[DURATION];
    holiday = (map[HOLIDAY] == 'true');
    companyHoliday = (map[COMPANY_HOLIDAY] == 'true');
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
      COMPANY_HOLIDAY: companyHoliday.toString(),
      DATE: DateFormat('yyyy/MM/dd').format(date),
    };
    if (id != null) {
      map[ID] = id;
    }
    return map;
  }
}

class WorkingProvider {
  Database _db;

  WorkingProvider(this._db);

  static create(Database db, int version) async {
    await db.execute('''
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
            ${Working.COMPANY_HOLIDAY} TEXT,
            ${Working.DATE} TEXT,
          UNIQUE (
            ${Working.YEAR},
            ${Working.MONTH},
            ${Working.DAY}
          ))
        ''');
  }

  static upgrade(Database db, int oldVersion, int newVersion) async {
    if (2 > oldVersion && 2 <= newVersion) {
      await db.execute('ALTER TABLE ${Working.TABLE_NAME} ADD ${Working.HOLIDAY} TEXT');
    }
    if (3 > oldVersion && 3 <= newVersion) {
      await db.execute('ALTER TABLE ${Working.TABLE_NAME} ADD ${Working.COMPANY_HOLIDAY} TEXT');
      await db.update(Working.TABLE_NAME, {Working.COMPANY_HOLIDAY: 'false'},
        where: '${Working.COMPANY_HOLIDAY} IS NULL'
      );
    }
    if (4 > oldVersion && 4 <= newVersion) {
      await db.execute('ALTER TABLE ${Working.TABLE_NAME} ADD ${Working.DATE} TEXT');
      await db.execute("UPDATE ${Working.TABLE_NAME} SET ${Working.DATE}=${Working.YEAR}||'/'||substr('00'||${Working.MONTH}, -2, 2)||'/'||substr('00'||${Working.DAY}, -2, 2)");
    }
  }

  Future<Working> insert(Working working) async {
    working.id = await _db.insert(Working.TABLE_NAME, working.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return working;
  }

  Future<Working> get(DateTime date) async {
    List<Map> maps = await _db.query(Working.TABLE_NAME,
        where: '${Working.YEAR} = ? AND ${Working.MONTH} = ? AND ${Working.DAY} = ?',
        whereArgs: [date.year, date.month, date.day]);
    if (0 < maps.length) {
      return Working.fromMap(maps.first);
    }
    return null;
  }

  Future<List> list(DateTime date) async {
    List<Map> maps = await _db.query(Working.TABLE_NAME,
        where: '${Working.YEAR} = ? AND ${Working.MONTH} = ? AND ${Working.COMPANY_HOLIDAY} = ?',
        whereArgs: [date.year, date.month, 'false'],
        orderBy: '${Working.DAY} ASC');
    List<Working> list = [];
    maps.forEach((it) => list.add(Working.fromMap(it)));
    return list;
  }

  Future<Map<DateTime, List>> listAsCalendarEvent(DateTime first, DateTime last) async {
    List<Map> maps = await _db.query(Working.TABLE_NAME,
        where: '${Working.DATE} >= ? AND ${Working.DATE} <= ? AND ${Working.COMPANY_HOLIDAY} = ?',
        whereArgs: [DateFormat('yyyy/MM/dd').format(first), DateFormat('yyyy/MM/dd').format(last), 'false'],
        orderBy: '${Working.DAY} ASC');
    Map map = Map<DateTime, List>();
    maps?.forEach((it) {
      Working working = Working.fromMap(it);
      map[DateTime(working.year, working.month, working.day)] = ["${working.duration}"];
    });
    return map;
  }

  Future<List> companyHolidays() async {
    List<Map> maps = await _db.query(Working.TABLE_NAME,
        where: '${Working.COMPANY_HOLIDAY} = ?',
        whereArgs: ['true']);
    List<String> list = [];
    maps.forEach((it) {
      Working working = Working.fromMap(it);
      list.add(DateFormat('yyyy/MM/dd').format(DateTime(working.year, working.month, working.day)));
    });
    return list;
  }

  delete(DateTime date) async {
    await _db.delete(Working.TABLE_NAME,
        where: '${Working.YEAR} = ? AND ${Working.MONTH} = ? AND ${Working.DAY} = ?',
        whereArgs: [date.year, date.month, date.day]);
  }
}