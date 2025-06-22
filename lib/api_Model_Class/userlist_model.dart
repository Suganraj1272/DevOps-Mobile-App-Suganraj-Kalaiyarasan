// ignore_for_file: constant_identifier_names

enum CreatedBy { SUPER_ADMIN, SYSTEM_DEFAULT }

enum Gender { FEMALE, MALE }

enum PasswordEnforcement { N, Y }

enum Status { ACTIVE }

class Userlist1 {
  bool status;
  String message;
  Result result;

  Userlist1({
    required this.status,
    required this.message,
    required this.result,
  });

  factory Userlist1.fromJson(Map<String, dynamic> json) => Userlist1(
        status: json['status'],
        message: json['message'],
        result: Result.fromJson(json['result']),
      );
}

class Result {
  List<User> userList;

  Result({required this.userList});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        userList: List<User>.from(json['users'].map((x) => User.fromJson(x))),
      );
}

class User {
  int id;
  String firstName;
  String lastName;
  Gender gender;
  Status status;
  String email;
  dynamic emailVerifiedAt;
  String? redmineUserId;
  String? giteaUserId;
  String? giteaApiKey;
  String? redmineApiKey;
  int prohibitionPeriod;
  dynamic profilePicture;
  CreatedBy createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  PasswordEnforcement passwordEnforcement;
  bool loginAccess;
  String fullName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.status,
    required this.email,
    required this.emailVerifiedAt,
    required this.redmineUserId,
    required this.giteaUserId,
    required this.giteaApiKey,
    required this.redmineApiKey,
    required this.prohibitionPeriod,
    required this.profilePicture,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.passwordEnforcement,
    required this.loginAccess,
    required this.fullName,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: Gender.values.firstWhere((e) => e.name == json['gender'],
          orElse: () => Gender.MALE),
      status: Status.values.firstWhere((e) => e.name == json['status'],
          orElse: () => Status.ACTIVE),
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      redmineUserId: json['redmine_user_id'],
      giteaUserId: json['gitea_user_id'],
      giteaApiKey: json['gitea_api_key'],
      redmineApiKey: json['redmine_api_key'],
      prohibitionPeriod: json['prohibition_period'] ?? 0,
      profilePicture: json['profile_picture'],
      createdBy: CreatedBy.values.firstWhere(
          (e) => e.name == json['created_by'],
          orElse: () => CreatedBy.SYSTEM_DEFAULT),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'],
      passwordEnforcement: PasswordEnforcement.values.firstWhere(
          (e) => e.name == json['password_enforcement'],
          orElse: () => PasswordEnforcement.N),
      loginAccess: json['login_access'] ?? false,
      fullName: json['full_name'] ?? '',
    );
  }
}
