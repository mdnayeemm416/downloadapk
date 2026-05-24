class AppUpdateModel {
  final String? id;
  final String? version;
  final int? buildNumber;
  final String? downloadUrl;
  final String? releaseNotes;
  final int? isMandatory;
  final String? createdAt;
  final String? appname;

  AppUpdateModel({
    this.id,
    this.version,
    this.buildNumber,
    this.downloadUrl,
    this.releaseNotes,
    this.isMandatory,
    this.createdAt,
    this.appname,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      id: json['id'] as String?,
      version: json['version'] as String?,
      buildNumber: json['build_number'] as int?,
      downloadUrl: json['download_url'] as String?,
      releaseNotes: json['release_notes'] as String?,
      isMandatory: json['is_mandatory'] as int?,
      createdAt: json['created_at'] as String?,
      appname: json['appname'] as String?,
    );
  }
}
