
import 'package:intl/intl.dart';

/// カレンダー関連のユーティリティ
class CalendarUtil {

  // 指定した月の平日のみのリストを取得する
  static List<DateTime> getWeekdays(DateTime date, {
    List<String> customHolidays = const [],
  }) {
    DateTime day = DateTime(date.year, date.month, 1);
    List<DateTime> list = [];
    for (int i = 0; i < 31; ++i) {
      if (DateTime.saturday != day.weekday &&
          DateTime.sunday != day.weekday &&
          !isNationalHoliday(day) &&
          !customHolidays.contains(DateFormat('yyyy/MM/dd').format(day))) {
        list.add(day);
      }
      day = DateTime(day.year, day.month, day.day + 1);
      if (date.month != day.month) {
        break;
      }
    }
    return list;
  }

  // 今日の0時ちょうどのDateTimeを取得する
  static DateTime getToday() {
    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  // 30日後までを検索して指定日の次の平日を取得する
  // 見つからなかった場合は指定日がそのまま返る
  static DateTime getNextWeekday(DateTime date, {
    List<String> customHolidays = const [],
  }) {
    DateTime day = DateTime(date.year, date.month, date.day);
    for (int i = 0; i <= 30; ++i) {
      day = DateTime(day.year, day.month, day.day + 1);
      if (DateTime.saturday != day.weekday &&
          DateTime.sunday != day.weekday &&
          !isNationalHoliday(day) &&
          !customHolidays.contains(DateFormat('yyyy/MM/dd').format(day))) {
        return day;
      }
    }
    return date;
  }

  // 月の表示文字列を取得する
  static String getMonth(DateTime date) {
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (1 <= date.month && date.month <= 12) {
      return '${month[date.month - 1]}';
    } else {
      return '';
    }
  }

  // 年・月の表示文字列を取得する
  static String getYearAndMonth(DateTime date) {
    return '${getMonth(date)} ${date.year}';
  }

  // 祝日かどうかを判定する
  static bool isNationalHoliday(DateTime date) {
    return _nationalHolidays.contains(DateFormat('yyyy/MM/dd').format(date));
  }

  static Map<DateTime, List> getNationalHoliday() {
    Map map = Map<DateTime, List>();
    _nationalHolidays.forEach((it) => {
      map[DateFormat('yyyy/MM/dd').parse(it)] = ['National Holiday']
    });
    return map;
  }

  // 拾ってきた日本の祝日データ
  static List<String> _nationalHolidays = [
    "2017/01/01",
    "2017/01/02",
    "2017/01/09",
    "2017/02/11",
    "2017/03/20",
    "2017/04/29",
    "2017/05/03",
    "2017/05/04",
    "2017/05/05",
    "2017/07/17",
    "2017/08/11",
    "2017/09/18",
    "2017/09/23",
    "2017/10/09",
    "2017/11/03",
    "2017/11/23",
    "2017/12/23",
    "2018/01/01",
    "2018/01/08",
    "2018/02/11",
    "2018/02/12",
    "2018/03/21",
    "2018/04/29",
    "2018/04/30",
    "2018/05/03",
    "2018/05/04",
    "2018/05/05",
    "2018/07/16",
    "2018/08/11",
    "2018/09/17",
    "2018/09/23",
    "2018/09/24",
    "2018/10/08",
    "2018/11/03",
    "2018/11/23",
    "2018/12/23",
    "2018/12/24",
    "2019/01/01",
    "2019/01/14",
    "2019/02/11",
    "2019/03/21",
    "2019/04/29",
    "2019/04/30",
    "2019/05/01",
    "2019/05/02",
    "2019/05/03",
    "2019/05/04",
    "2019/05/05",
    "2019/05/06",
    "2019/07/15",
    "2019/08/11",
    "2019/08/12",
    "2019/09/16",
    "2019/09/23",
    "2019/10/14",
    "2019/10/22",
    "2019/11/03",
    "2019/11/04",
    "2019/11/23",
    "2020/01/01",
    "2020/01/13",
    "2020/02/11",
    "2020/02/23",
    "2020/02/24",
    "2020/03/20",
    "2020/04/29",
    "2020/05/03",
    "2020/05/04",
    "2020/05/05",
    "2020/05/06",
    "2020/07/23",
    "2020/07/24",
    "2020/08/10",
    "2020/09/21",
    "2020/09/22",
    "2020/11/03",
    "2020/11/23",
    "2021/01/01",
    "2021/01/11",
    "2021/02/11",
    "2021/02/23",
    "2021/03/20",
    "2021/04/29",
    "2021/05/03",
    "2021/05/04",
    "2021/05/05",
    "2021/07/19",
    "2021/08/11",
    "2021/09/20",
    "2021/09/23",
    "2021/10/11",
    "2021/11/03",
    "2021/11/23",
    "2022/01/01",
    "2022/01/10",
    "2022/02/11",
    "2022/02/23",
    "2022/03/21",
    "2022/04/29",
    "2022/05/03",
    "2022/05/04",
    "2022/05/05",
    "2022/07/18",
    "2022/08/11",
    "2022/09/19",
    "2022/09/23",
    "2022/10/10",
    "2022/11/03",
    "2022/11/23",
    "2023/01/01",
    "2023/01/02",
    "2023/01/09",
    "2023/02/11",
    "2023/02/23",
    "2023/03/21",
    "2023/04/29",
    "2023/05/03",
    "2023/05/04",
    "2023/05/05",
    "2023/07/17",
    "2023/08/11",
    "2023/09/18",
    "2023/09/23",
    "2023/10/09",
    "2023/11/03",
    "2023/11/23",
    "2024/01/01",
    "2024/01/08",
    "2024/02/11",
    "2024/02/12",
    "2024/02/23",
    "2024/03/20",
    "2024/04/29",
    "2024/05/03",
    "2024/05/04",
    "2024/05/05",
    "2024/05/06",
    "2024/07/15",
    "2024/08/11",
    "2024/08/12",
    "2024/09/16",
    "2024/09/22",
    "2024/09/23",
    "2024/10/14",
    "2024/11/03",
    "2024/11/04",
    "2024/11/23",
    "2025/01/01",
    "2025/01/13",
    "2025/02/11",
    "2025/02/23",
    "2025/02/24",
    "2025/03/20",
    "2025/04/29",
    "2025/05/03",
    "2025/05/04",
    "2025/05/05",
    "2025/05/06",
    "2025/07/21",
    "2025/08/11",
    "2025/09/15",
    "2025/09/23",
    "2025/10/13",
    "2025/11/03",
    "2025/11/23",
    "2025/11/24",
    "2026/01/01",
    "2026/01/12",
    "2026/02/11",
    "2026/02/23",
    "2026/03/20",
    "2026/04/29",
    "2026/05/03",
    "2026/05/04",
    "2026/05/05",
    "2026/05/06",
    "2026/07/20",
    "2026/08/11",
    "2026/09/21",
    "2026/09/22",
    "2026/09/23",
    "2026/10/12",
    "2026/11/03",
    "2026/11/23",
    "2027/01/01",
    "2027/01/11",
    "2027/02/11",
    "2027/02/23",
    "2027/03/21",
    "2027/03/22",
    "2027/04/29",
    "2027/05/03",
    "2027/05/04",
    "2027/05/05",
    "2027/07/19",
    "2027/08/11",
    "2027/09/20",
    "2027/09/23",
    "2027/10/11",
    "2027/11/03",
    "2027/11/23",
    "2028/01/01",
    "2028/01/10",
    "2028/02/11",
    "2028/02/23",
    "2028/03/20",
    "2028/04/29",
    "2028/05/03",
    "2028/05/04",
    "2028/05/05",
    "2028/07/17",
    "2028/08/11",
    "2028/09/18",
    "2028/09/22",
    "2028/10/09",
    "2028/11/03",
    "2028/11/23",
    "2029/01/01",
    "2029/01/08",
    "2029/02/11",
    "2029/02/12",
    "2029/02/23",
    "2029/03/20",
    "2029/04/29",
    "2029/04/30",
    "2029/05/03",
    "2029/05/04",
    "2029/05/05",
    "2029/07/16",
    "2029/08/11",
    "2029/09/17",
    "2029/09/23",
    "2029/09/24",
    "2029/10/08",
    "2029/11/03",
    "2029/11/23",
    "2030/01/01",
    "2030/01/14",
    "2030/02/11",
    "2030/02/23",
    "2030/03/20",
    "2030/04/29",
    "2030/05/03",
    "2030/05/04",
    "2030/05/05",
    "2030/05/06",
    "2030/07/15",
    "2030/08/11",
    "2030/08/12",
    "2030/09/16",
    "2030/09/23",
    "2030/10/14",
    "2030/11/03",
    "2030/11/04",
    "2030/11/23",
    "2031/01/01",
    "2031/01/13",
    "2031/02/11",
    "2031/02/23",
    "2031/02/24",
    "2031/03/21",
    "2031/04/29",
    "2031/05/03",
    "2031/05/04",
    "2031/05/05",
    "2031/05/06",
    "2031/07/21",
    "2031/08/11",
    "2031/09/15",
    "2031/09/23",
    "2031/10/13",
    "2031/11/03",
    "2031/11/23",
    "2031/11/24",
    "2032/01/01",
    "2032/01/12",
    "2032/02/11",
    "2032/02/23",
    "2032/03/20",
    "2032/04/29",
    "2032/05/03",
    "2032/05/04",
    "2032/05/05",
    "2032/07/19",
    "2032/08/11",
    "2032/09/20",
    "2032/09/21",
    "2032/09/22",
    "2032/10/11",
    "2032/11/03",
    "2032/11/23",
    "2033/01/01",
    "2033/01/10",
    "2033/02/11",
    "2033/02/23",
    "2033/03/20",
    "2033/03/21",
    "2033/04/29",
    "2033/05/03",
    "2033/05/04",
    "2033/05/05",
    "2033/07/18",
    "2033/08/11",
    "2033/09/19",
    "2033/09/23",
    "2033/10/10",
    "2033/11/03",
    "2033/11/23",
    "2034/01/01",
    "2034/01/02",
    "2034/01/09",
    "2034/02/11",
    "2034/02/23",
    "2034/03/20",
    "2034/04/29",
    "2034/05/03",
    "2034/05/04",
    "2034/05/05",
    "2034/07/17",
    "2034/08/11",
    "2034/09/18",
    "2034/09/23",
    "2034/10/09",
    "2034/11/03",
    "2034/11/23",
    "2035/01/01",
    "2035/01/08",
    "2035/02/11",
    "2035/02/12",
    "2035/02/23",
    "2035/03/21",
    "2035/04/29",
    "2035/04/30",
    "2035/05/03",
    "2035/05/04",
    "2035/05/05",
    "2035/07/16",
    "2035/08/11",
    "2035/09/17",
    "2035/09/23",
    "2035/09/24",
    "2035/10/08",
    "2035/11/03",
    "2035/11/23",
    "2036/01/01",
    "2036/01/14",
    "2036/02/11",
    "2036/02/23",
    "2036/03/20",
    "2036/04/29",
    "2036/05/03",
    "2036/05/04",
    "2036/05/05",
    "2036/05/06",
    "2036/07/21",
    "2036/08/11",
    "2036/09/15",
    "2036/09/22",
    "2036/10/13",
    "2036/11/03",
    "2036/11/23",
    "2036/11/24",
  ];
}