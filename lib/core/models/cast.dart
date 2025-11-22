import 'package:json_annotation/json_annotation.dart';

part 'cast.g.dart';

@JsonSerializable()
class CreditsResponse {
  final int id;
  final List<Cast> cast;
  final List<Crew> crew;

  CreditsResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory CreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreditsResponseToJson(this);
}

@JsonSerializable()
class Cast {
  final int id;
  final String? name;
  @JsonKey(name: 'original_name')
  final String? originalName;
  final String? character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @JsonKey(name: 'cast_id')
  final int? castId;
  @JsonKey(name: 'credit_id')
  final String? creditId;
  final int? order;
  final int? gender;
  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;
  final double? popularity;
  final bool? adult;

  Cast({
    required this.id,
    this.name,
    this.originalName,
    this.character,
    this.profilePath,
    this.castId,
    this.creditId,
    this.order,
    this.gender,
    this.knownForDepartment,
    this.popularity,
    this.adult,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => _$CastFromJson(json);
  Map<String, dynamic> toJson() => _$CastToJson(this);

  String get displayName => name ?? originalName ?? 'Unknown';
}

@JsonSerializable()
class Crew {
  final int id;
  final String? name;
  @JsonKey(name: 'original_name')
  final String? originalName;
  final String? job;
  final String? department;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @JsonKey(name: 'credit_id')
  final String? creditId;
  final int? gender;
  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;
  final double? popularity;
  final bool? adult;

  Crew({
    required this.id,
    this.name,
    this.originalName,
    this.job,
    this.department,
    this.profilePath,
    this.creditId,
    this.gender,
    this.knownForDepartment,
    this.popularity,
    this.adult,
  });

  factory Crew.fromJson(Map<String, dynamic> json) => _$CrewFromJson(json);
  Map<String, dynamic> toJson() => _$CrewToJson(this);

  String get displayName => name ?? originalName ?? 'Unknown';
}