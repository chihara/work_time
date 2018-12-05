
import 'package:flutter/material.dart';
import 'package:working/db/working.dart';
import 'package:working/widget/daily_item.dart';

/// 月間データ集計画面の日別リストwidget
class MonthlyList extends StatefulWidget {
  final List<Working> list;
  final List<Working> estimations;

  MonthlyList({
    Key key,
    @required this.list,
    @required this.estimations,
  }) : super (key: key);

  @override
  State<StatefulWidget> createState() => MonthlyListState();
}

class MonthlyListState extends State<MonthlyList> {
  List<Working> _list;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    update(widget.list, widget.estimations);
  }

  update(List<Working> list, List<Working> estimations) {
    setState(() {
      _list = list + estimations;
      _list.sort(([a, b]) {
        return a.day > b.day ? 1 : -1;
      });
    });
  }
  
  scrollToTop() {
    _controller.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    if (null == _list) {
      return Center(
          child: CircularProgressIndicator()
      );
    } else if (_list.isEmpty) {
      return Center(
          child: Text('No Data'),
      );
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        itemBuilder: (BuildContext context, int index) {
          var length = _list?.length ?? 0;
          if (length <= index) {
            return null;
          } else {
            return DailyItem(working: _list[index]);
          }
        },
      controller: _controller,
    );
  }
}