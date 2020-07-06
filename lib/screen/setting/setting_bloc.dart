import 'package:rxdart/rxdart.dart';

class SettingBloc {

  SettingBlocState _currentState;
}

class SettingBlocState {

  ValueObservable<double> hoursPerMonth;
  ValueObservable<double> hoursPerDay;
  ValueObservable<double> start;
  ValueObservable<double> end;
  ValueObservable<double> rest;
  ValueObservable<String>
}