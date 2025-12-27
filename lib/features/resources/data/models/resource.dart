enum ResourceType {
  telegram,
  website,
  submission,
  video,
  document,
  code,
  communication,
  whatsapp,
  sharedDrive,
}

class Resource {
  final String id;
  final String courseId;
  final String url;
  final String type;
  final String description;

  Resource({
    required this.id,
    required this.courseId,
    required this.url,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'url': url,
      'type': type,
      'description': description,
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      type: (json['type'] ?? 'website').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  // Convenience: interpret the string type as enum safely
  ResourceType get typeEnum {
    final t = type.toLowerCase();
    for (final v in ResourceType.values) {
      if (v.name.toLowerCase() == t) return v;
    }
    return ResourceType.website;
  }

  void openLink() {
    // This would typically use url_launcher to open the URL
    // Implementation would be in the UI layer
  }
}
