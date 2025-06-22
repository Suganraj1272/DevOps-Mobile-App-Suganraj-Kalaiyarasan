class SprintPlanList {
  bool status;
  String message;
  List<Result> result;

  SprintPlanList({
    required this.status,
    required this.message,
    required this.result,
  });

  factory SprintPlanList.fromJson(Map<String, dynamic> json) {
    return SprintPlanList(
      status: json['status'],
      message: json['message'],
      result: List<Result>.from(json['result'].map((x) => Result.fromJson(x))),
    );
  }
}

class Result {
  int sprintMainId;
  String sprintName;
  String estimationTime;
  String? spentTime;
  String ticketNo;
  String status;
  String estimationStatus;
  String companyOutcomeStatus;
  String isCarryForward;
  String projectName;
  String firstName;
  String lastName;
  int userId;

  Result({
    required this.sprintMainId,
    required this.sprintName,
    required this.estimationTime,
    required this.spentTime,
    required this.ticketNo,
    required this.status,
    required this.estimationStatus,
    required this.companyOutcomeStatus,
    required this.isCarryForward,
    required this.projectName,
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      sprintMainId: json['sprintMainId'],
      sprintName: json['sprint_name'],
      estimationTime: json['estimation_time'],
      spentTime: json['spent_time'],
      ticketNo: json['ticket_no'],
      status: json['status'],
      estimationStatus: json['estimationstatus'],
      companyOutcomeStatus: json['company_outcome_status'],
      isCarryForward: json['is_carry_forward'],
      projectName: json['project_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      userId: json['userId'],
    );
  }
}
