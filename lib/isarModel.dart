import 'package:isar/isar.dart';

//part 'isarModel.g.dart';

@collection
class TodoItem {
  Id id = Isar.autoIncrement;

  late String title;
  late String subTitle;
  late String shortPrayer;
  late String mediumPrayer;
  late String longPrayer;
  late String userPrayer;
  Schedule schedule = Schedule();
}

@embedded
class Schedule {
  List<ScheduleItem> items = [];
}

@embedded
class ScheduleItem {
  late int dayOfWeek;
  late DateTime timeOfDay;
}
