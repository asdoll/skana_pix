class AppSettings {
  Map<String, dynamic> settings = {
    'theme': 'system',
    'language': 'system',
    'notificationsEnabled': 'true',
    'maxParallels': 4,
    'showOriginalImage': true,
    'blockTags': [],
    'checkUpdate': true,
  };

  AppSettings();

  AppSettings.fromJson(Map<String, dynamic> json) {
    settings = {
      'theme': json['theme'],
      'language': json['language'],
      'notificationsEnabled': json['notificationsEnabled'],
      'maxParallels': json['maxParallels'],
      'showOriginalImage': json['showOriginalImage'],
      'blockTags': List<String>.from(json['blockTags']),
      'checkUpdate': json['checkUpdate'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': settings['theme'],
      'language': settings['language'],
      'notificationsEnabled': settings['notificationsEnabled'],
      'maxParallels': settings['maxParallels'],
      'showOriginalImage': settings['showOriginalImage'],
      'blockTags': settings['blockTags'],
      'checkUpdate': settings['checkUpdate'],
    };
  }

  void updateTheme(String newTheme) {
    settings['theme'] = newTheme;
  }

  void updateLanguage(String newLanguage) {
    settings['language'] = newLanguage;
  }

  void toggleNotifications() {
    settings['notificationsEnabled'] = !settings['notificationsEnabled'];
  }

  void updateMaxParallels(int newMaxParallels) {
    settings['maxParallels'] = newMaxParallels;
  }

  void updateShowOriginalImage(bool newShowOriginalImage) {
    settings['showOriginalImage'] = newShowOriginalImage;
  }

  void updateBlockTags(List<String> newBlockTags) {
    settings['blockTags'] = newBlockTags;
  }

  void toggleCheckUpdate() {
    settings['checkUpdate'] = !settings['checkUpdate'];
  }

  String get theme => settings['theme'];
  String get language => settings['language'];
  bool get notificationsEnabled => settings['notificationsEnabled'];
  int get maxParallels => settings['maxParallels'];
  bool get showOriginalImage => settings['showOriginalImage'];
  List<String> get blockTags => settings['blockTags'];
  bool get checkUpdate => settings['checkUpdate'];

  @override
  String toString() {
    return 'AppSettings(theme: ${settings['theme']}, language: ${settings['language']}, notificationsEnabled: ${settings['notificationsEnabled']}, maxParallels: ${settings['maxParallels']}, showOriginalImage: ${settings['showOriginalImage']}, blockTags: ${settings['blockTags']}, checkUpdate: ${settings['checkUpdate']})';
  }
}

var settings = AppSettings();
