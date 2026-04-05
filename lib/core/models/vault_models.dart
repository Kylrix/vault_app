import 'dart:convert';

class VaultCredential {
  VaultCredential({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
    required this.folderId,
    required this.isFavorite,
    required this.updatedAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
  final String folderId;
  final bool isFavorite;
  final DateTime updatedAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'username': username,
        'password': password,
        'url': url,
        'notes': notes,
        'folderId': folderId,
        'isFavorite': isFavorite,
        'updatedAt': updatedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory VaultCredential.fromJson(Map<String, dynamic> json) {
    return VaultCredential(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      folderId: json['folderId'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class VaultFolder {
  VaultFolder({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String color;
  final String icon;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VaultFolder.fromJson(Map<String, dynamic> json) {
    return VaultFolder(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#10B981',
      icon: json['icon'] as String? ?? 'folder',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class VaultTotp {
  VaultTotp({
    required this.id,
    required this.issuer,
    required this.accountName,
    required this.secret,
    required this.updatedAt,
  });

  final String id;
  final String issuer;
  final String accountName;
  final String secret;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'issuer': issuer,
        'accountName': accountName,
        'secret': secret,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VaultTotp.fromJson(Map<String, dynamic> json) {
    return VaultTotp(
      id: json['id'] as String,
      issuer: json['issuer'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class VaultSettings {
  VaultSettings({
    required this.autoLockMinutes,
    required this.quickUnlockEnabled,
    required this.autofillEnabled,
    required this.desktopHotkeyEnabled,
    required this.keepRunningInBackground,
  });

  final int autoLockMinutes;
  final bool quickUnlockEnabled;
  final bool autofillEnabled;
  final bool desktopHotkeyEnabled;
  final bool keepRunningInBackground;

  Map<String, dynamic> toJson() => {
        'autoLockMinutes': autoLockMinutes,
        'quickUnlockEnabled': quickUnlockEnabled,
        'autofillEnabled': autofillEnabled,
        'desktopHotkeyEnabled': desktopHotkeyEnabled,
        'keepRunningInBackground': keepRunningInBackground,
      };

  factory VaultSettings.fromJson(Map<String, dynamic> json) {
    return VaultSettings(
      autoLockMinutes: json['autoLockMinutes'] as int? ?? 5,
      quickUnlockEnabled: json['quickUnlockEnabled'] as bool? ?? true,
      autofillEnabled: json['autofillEnabled'] as bool? ?? true,
      desktopHotkeyEnabled: json['desktopHotkeyEnabled'] as bool? ?? true,
      keepRunningInBackground: json['keepRunningInBackground'] as bool? ?? true,
    );
  }

  factory VaultSettings.defaults() => VaultSettings(
        autoLockMinutes: 5,
        quickUnlockEnabled: true,
        autofillEnabled: true,
        desktopHotkeyEnabled: true,
        keepRunningInBackground: true,
      );

  VaultSettings copyWith({
    int? autoLockMinutes,
    bool? quickUnlockEnabled,
    bool? autofillEnabled,
    bool? desktopHotkeyEnabled,
    bool? keepRunningInBackground,
  }) {
    return VaultSettings(
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      quickUnlockEnabled: quickUnlockEnabled ?? this.quickUnlockEnabled,
      autofillEnabled: autofillEnabled ?? this.autofillEnabled,
      desktopHotkeyEnabled: desktopHotkeyEnabled ?? this.desktopHotkeyEnabled,
      keepRunningInBackground:
          keepRunningInBackground ?? this.keepRunningInBackground,
    );
  }
}

String encodeJson(Map<String, dynamic> json) => jsonEncode(json);
Map<String, dynamic> decodeJson(String value) => jsonDecode(value) as Map<String, dynamic>;
