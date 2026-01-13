import 'package:equatable/equatable.dart';
import 'form_config.dart';

class VersionSnapshot extends Equatable {
  final String professionId;
  final String version;
  final FormConfig config;
  final DateTime timestamp;
  final String author;
  final String? changeDescription;

  const VersionSnapshot({
    required this.professionId,
    required this.version,
    required this.config,
    required this.timestamp,
    required this.author,
    this.changeDescription,
  });

  factory VersionSnapshot.fromJson(Map<String, dynamic> json) {
    return VersionSnapshot(
      professionId: json['professionId'] as String,
      version: json['version'] as String,
      config: FormConfig.fromJson(json['config'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      author: json['author'] as String,
      changeDescription: json['changeDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionId': professionId,
      'version': version,
      'config': config.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'author': author,
      if (changeDescription != null) 'changeDescription': changeDescription,
    };
  }

  @override
  List<Object?> get props => [
        professionId,
        version,
        config,
        timestamp,
        author,
        changeDescription,
      ];
}
