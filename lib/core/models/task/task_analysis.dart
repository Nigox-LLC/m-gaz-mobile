class TaskAnalysisModel {
  final int allTask;
  final int doneTask;
  final int notDoneTask;
  final int expiredTask;
  final int consumerCount;

  TaskAnalysisModel({
    required this.allTask,
    required this.doneTask,
    required this.notDoneTask,
    required this.expiredTask,
    required this.consumerCount,
  });

  factory TaskAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TaskAnalysisModel(
      allTask: json["all_task"] ?? 0,
      doneTask: json["done_task"] ?? 0,
      notDoneTask: json["not_done_task"] ?? 0,
      expiredTask: json["expired_task"] ?? 0,
      consumerCount: json["consumer_count"] ?? 0,
    );
  }
}
