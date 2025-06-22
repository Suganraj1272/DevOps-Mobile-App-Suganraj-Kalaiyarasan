class SprintList {
  final bool status;
  final String message;
  final Result result;

  SprintList({
    required this.status,
    required this.message,
    required this.result,
  });

  factory SprintList.fromJson(Map<String, dynamic> json) {
    return SprintList(
      status: json['status'] as bool,
      message: json['message'] as String,
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  final List<Sprint> sprints;

  Result({
    required this.sprints,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      sprints:
          (json['sprints'] as List).map((s) => Sprint.fromJson(s)).toList(),
    );
  }
}

class Sprint {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String goal;
  final int owner;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  Sprint({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.goal,
    required this.owner,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      goal: json['goal'] ?? '',
      owner: json['owner'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
    );
  }
}
