class Shortcut {
  int shortcutOrder;
  String shortcutName;

  Shortcut({
    required this.shortcutName,
    required this.shortcutOrder,
  });

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      shortcutOrder: json['shortcut_order'],
      shortcutName: json['shortcut_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortcut_name': shortcutName,
    };
  }

  Map<String, dynamic> toJsonWithOrder() {
    return {
      'shortcut_name': shortcutName,
      'shortcut_order': shortcutOrder,
    };
  }
}
