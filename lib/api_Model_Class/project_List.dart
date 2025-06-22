class Projectlist {
  final bool status;
  final String message;
  final ProjectResult result;

  Projectlist({
    required this.status,
    required this.message,
    required this.result,
  });

  factory Projectlist.fromJson(Map<String, dynamic> json) {
    return Projectlist(
      status: json['status'] as bool,
      message: json['message'] as String,
      result: ProjectResult.fromJson(json['result']),
    );
  }
}

class ProjectResult {
  final List<Project> projects;

  ProjectResult({
    required this.projects,
  });

  factory ProjectResult.fromJson(Map<String, dynamic> json) {
    return ProjectResult(
      projects:
          (json['projects'] as List).map((p) => Project.fromJson(p)).toList(),
    );
  }
}

class Project {
  final int id;
  final String projectName;
  final dynamic repoOwner;
  final String? giteaRepoName;
  final dynamic redmineProjectId;
  final dynamic giteaProjectId;
  final String status;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  Project({
    required this.id,
    required this.projectName,
    required this.repoOwner,
    required this.giteaRepoName,
    required this.redmineProjectId,
    required this.giteaProjectId,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      projectName: json['project_name'],
      repoOwner: json['repo_owner'],
      giteaRepoName: json['gitea_repo_name'],
      redmineProjectId: json['redmine_project_id'],
      giteaProjectId: json['gitea_project_id'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
    );
  }
}
