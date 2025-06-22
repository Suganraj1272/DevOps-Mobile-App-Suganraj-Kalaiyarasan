class LoginResponse {
  final bool status;
  final String message;
  final Result result;

  LoginResponse(
      {required this.status, required this.message, required this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  final String token;
  final User user;

  Result({required this.token, required this.user});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String fullName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      fullName: json['full_name'],
    );
  }
}
