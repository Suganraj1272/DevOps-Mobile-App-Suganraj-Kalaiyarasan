class RetroSprintList {
  final bool success;
  final String message;
  final Result? result;

  RetroSprintList({
    required this.success,
    required this.message,
    required this.result,
  });

  factory RetroSprintList.fromJson(Map<String, dynamic> json) {
    return RetroSprintList(
      success: json['success'],
      message: json['message'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final String userId;
  final String firstName;
  final String lastName;
  final int totalTaskCompletionPercentage;
  final int totalQualityPercentage;
  final int totalCompletionPercentage;
  final int overAllTotalPercentage;
  final List<dynamic> retroScoresSprintWise;

  Result({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.totalTaskCompletionPercentage,
    required this.totalQualityPercentage,
    required this.totalCompletionPercentage,
    required this.overAllTotalPercentage,
    required this.retroScoresSprintWise,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      totalTaskCompletionPercentage: json['totalTaskCompletionPercentage'] ?? 0,
      totalQualityPercentage: json['totalQualityPercentage'] ?? 0,
      totalCompletionPercentage: json['totalCompletionPercentage'] ?? 0,
      overAllTotalPercentage: json['overAllTotalPercentage'] ?? 0,
      retroScoresSprintWise: json['retroScoresSprintWise'] ?? [],
    );
  }
}

class RetroCheckList {
  bool success;
  String message;
  ChecklistResult result;

  RetroCheckList({
    required this.success,
    required this.message,
    required this.result,
  });

  factory RetroCheckList.fromJson(Map<String, dynamic> json) {
    return RetroCheckList(
      success: json['success'],
      message: json['message'],
      result: ChecklistResult.fromJson(json['result']),
    );
  }
}

class ChecklistResult {
  String sprintName;
  String firstName;
  String lastName;
  Checklists checklists;

  ChecklistResult({
    required this.sprintName,
    required this.firstName,
    required this.lastName,
    required this.checklists,
  });

  factory ChecklistResult.fromJson(Map<String, dynamic> json) {
    return ChecklistResult(
      sprintName: json['sprint_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      checklists: Checklists.fromJson(json['checklists']),
    );
  }
}

class Checklists {
  List<List<dynamic>> sprintDeliveryCompliance;
  List<List<dynamic>> sprintBehaviouralCompliance;

  Checklists({
    required this.sprintDeliveryCompliance,
    required this.sprintBehaviouralCompliance,
  });

  factory Checklists.fromJson(Map<String, dynamic> json) {
    return Checklists(
      sprintDeliveryCompliance: List<List<dynamic>>.from(
          json['sprint_delivery_compliance'].map((e) => List<dynamic>.from(e))),
      sprintBehaviouralCompliance: List<List<dynamic>>.from(
          json['sprint_behavioural_compliance']
              .map((e) => List<dynamic>.from(e))),
    );
  }
}

class UpdatecheckList {
  bool success;
  String message;
  String result;

  UpdatecheckList({
    required this.success,
    required this.message,
    required this.result,
  });

  factory UpdatecheckList.fromJson(Map<String, dynamic> json) {
    return UpdatecheckList(
      success: json['success'],
      message: json['message'],
      result: json['result'],
    );
  }
}
