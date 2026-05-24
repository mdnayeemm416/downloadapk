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
    String? url = json['download_url'] as String? ?? json['url'] as String? ?? json['apk_url'] as String?;
    
    // Fallback: search for any string value that is an APK URL
    if (url == null) {
      for (final value in json.values) {
        if (value is String && value.startsWith('http') && value.endsWith('.apk')) {
          url = value;
          break;
        }
      }
    }
    // Fallback: search keys in case of malformed JSON
    if (url == null) {
      for (final key in json.keys) {
        if (key.startsWith('http') && key.endsWith('.apk')) {
          url = key;
          break;
        }
      }
    }

    return AppUpdateModel(
      id: json['id'] as String?,
      version: json['version'] as String?,
      buildNumber: json['build_number'] as int?,
      downloadUrl: url,
      releaseNotes: json['release_notes'] as String?,
      isMandatory: json['is_mandatory'] as int?,
      createdAt: json['created_at'] as String?,
      appname: json['appname'] as String?,
    );
  }
}
