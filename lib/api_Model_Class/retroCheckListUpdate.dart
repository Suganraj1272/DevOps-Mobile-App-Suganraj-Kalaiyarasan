class RetroCheckListUpdate {
  bool success;
  String message;
  Result result;

  RetroCheckListUpdate({
    required this.success,
    required this.message,
    required this.result,
  });

  factory RetroCheckListUpdate.fromJson(Map<String, dynamic> json) {
    return RetroCheckListUpdate(
      success: json['success'],
      message: json['message'],
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  String sprintName;
  String firstName;
  String lastName;
  Checklists checklists;

  Result({
    required this.sprintName,
    required this.firstName,
    required this.lastName,
    required this.checklists,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      sprintName: json['sprintName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      checklists: Checklists.fromJson(json['checklists']),
    );
  }
}

class Checklists {
  List<List<dynamic>> sprintDeliveryCompliance;
  List<List<SprintBehaviouralCompliance>> sprintBehaviouralCompliance;

  Checklists({
    required this.sprintDeliveryCompliance,
    required this.sprintBehaviouralCompliance,
  });

  factory Checklists.fromJson(Map<String, dynamic> json) {
    return Checklists(
      sprintDeliveryCompliance: List<List<dynamic>>.from(
          json['sprintDeliveryCompliance'].map((x) => List<dynamic>.from(x))),
      sprintBehaviouralCompliance: List<List<SprintBehaviouralCompliance>>.from(
          json['sprintBehaviouralCompliance'].map((x) =>
              List<SprintBehaviouralCompliance>.from(
                  x.map((x) => SprintBehaviouralCompliance.fromJson(x))))),
    );
  }
}

class SprintBehaviouralCompliance {
  String name;
  int value;
  int id;

  SprintBehaviouralCompliance({
    required this.name,
    required this.value,
    required this.id,
  });

  factory SprintBehaviouralCompliance.fromJson(Map<String, dynamic> json) {
    return SprintBehaviouralCompliance(
      name: json['name'],
      value: json['value'],
      id: json['id'],
    );
  }
}
