/// 单日活动数据模型
class ActivityData {
  final String date;
  final int count;
  final int level;

  ActivityData({
    required this.date,
    required this.count,
    required this.level,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      date: json['date'] as String,
      count: json['count'] as int,
      level: json['level'] as int,
    );
  }

  DateTime get dateTime => DateTime.parse(date);
}
