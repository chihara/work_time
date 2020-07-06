
import 'package:shared_preferences/shared_preferences.dart';

typedef void OnLoad();

class Settings {
  Future<SharedPreferences> _pref;
  static const String HOURS_PER_MONTH = 'hours_per_month';
  static const String HOURS_PER_DAY = 'hours_per_day';
  static const String START_TIME = 'start_time';
  static const String END_TIME = 'end_time';
  static const String REST_DURATION = 'rest_duration';

  static Settings _settings;
  double hoursPerMonth;
  double hoursPerDay;
  double start;
  double end;
  double rest;

  Settings._init() {
    _pref = SharedPreferences.getInstance();
  }

  factory Settings() {
    if (null == _settings) _settings = Settings._init();
    return _settings;
  }

  set({double start, double end, double rest}) {
    if (null != start)
      this.start = start;
    if (null != end)
      this.end = end;
    if (null != rest)
      this.rest = rest;
    this.hoursPerDay = this.end - this.start - this.rest;
  }

  save() {
    _pref.then((pref) {
      pref.setString(HOURS_PER_MONTH, hoursPerMonth.toStringAsFixed(2));
      pref.setString(HOURS_PER_DAY, hoursPerDay.toStringAsFixed(2));
      pref.setString(START_TIME, start.toStringAsFixed(2));
      pref.setString(END_TIME, end.toStringAsFixed(2));
      pref.setString(REST_DURATION, rest.toStringAsFixed(2));
    });
  }

  load(OnLoad onLoad) {
    _pref.then((pref) {
      hoursPerMonth = double.tryParse(pref.getString(HOURS_PER_MONTH) ?? '160.00');
      hoursPerDay = double.tryParse(pref.getString(HOURS_PER_DAY) ?? '8.00');
      start = double.tryParse(pref.getString(START_TIME) ?? '10.00');
      end = double.tryParse(pref.getString(END_TIME) ?? '19.00');
      rest = double.tryParse(pref.getString(REST_DURATION) ?? '1.00');
      if (null != onLoad)
        onLoad();
    });
  }
}