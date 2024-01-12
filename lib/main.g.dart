// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalStateManagerImpl _$$GlobalStateManagerImplFromJson(
        Map<String, dynamic> json) =>
    _$GlobalStateManagerImpl(
      materialColor: json['materialColor'] == null
          ? Colors.blue
          : const MaterialColorConverter()
              .fromJson(json['materialColor'] as int),
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
    );

Map<String, dynamic> _$$GlobalStateManagerImplToJson(
        _$GlobalStateManagerImpl instance) =>
    <String, dynamic>{
      'materialColor':
          const MaterialColorConverter().toJson(instance.materialColor),
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
