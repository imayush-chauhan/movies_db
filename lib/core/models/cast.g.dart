// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditsResponse _$CreditsResponseFromJson(Map<String, dynamic> json) =>
    CreditsResponse(
      id: (json['id'] as num).toInt(),
      cast: (json['cast'] as List<dynamic>)
          .map((e) => Cast.fromJson(e as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>)
          .map((e) => Crew.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreditsResponseToJson(CreditsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cast': instance.cast,
      'crew': instance.crew,
    };

Cast _$CastFromJson(Map<String, dynamic> json) => Cast(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  originalName: json['original_name'] as String?,
  character: json['character'] as String?,
  profilePath: json['profile_path'] as String?,
  castId: (json['cast_id'] as num?)?.toInt(),
  creditId: json['credit_id'] as String?,
  order: (json['order'] as num?)?.toInt(),
  gender: (json['gender'] as num?)?.toInt(),
  knownForDepartment: json['known_for_department'] as String?,
  popularity: (json['popularity'] as num?)?.toDouble(),
  adult: json['adult'] as bool?,
);

Map<String, dynamic> _$CastToJson(Cast instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'original_name': instance.originalName,
  'character': instance.character,
  'profile_path': instance.profilePath,
  'cast_id': instance.castId,
  'credit_id': instance.creditId,
  'order': instance.order,
  'gender': instance.gender,
  'known_for_department': instance.knownForDepartment,
  'popularity': instance.popularity,
  'adult': instance.adult,
};

Crew _$CrewFromJson(Map<String, dynamic> json) => Crew(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  originalName: json['original_name'] as String?,
  job: json['job'] as String?,
  department: json['department'] as String?,
  profilePath: json['profile_path'] as String?,
  creditId: json['credit_id'] as String?,
  gender: (json['gender'] as num?)?.toInt(),
  knownForDepartment: json['known_for_department'] as String?,
  popularity: (json['popularity'] as num?)?.toDouble(),
  adult: json['adult'] as bool?,
);

Map<String, dynamic> _$CrewToJson(Crew instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'original_name': instance.originalName,
  'job': instance.job,
  'department': instance.department,
  'profile_path': instance.profilePath,
  'credit_id': instance.creditId,
  'gender': instance.gender,
  'known_for_department': instance.knownForDepartment,
  'popularity': instance.popularity,
  'adult': instance.adult,
};
