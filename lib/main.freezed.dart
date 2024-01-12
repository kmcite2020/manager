// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

GlobalStateManager _$GlobalStateManagerFromJson(Map<String, dynamic> json) {
  return _GlobalStateManager.fromJson(json);
}

/// @nodoc
mixin _$GlobalStateManager {
  @MaterialColorConverter()
  MaterialColor get materialColor => throw _privateConstructorUsedError;
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)
        raw,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)?
        raw,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)?
        raw,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GlobalStateManager value) raw,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GlobalStateManager value)? raw,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GlobalStateManager value)? raw,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GlobalStateManagerCopyWith<GlobalStateManager> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalStateManagerCopyWith<$Res> {
  factory $GlobalStateManagerCopyWith(
          GlobalStateManager value, $Res Function(GlobalStateManager) then) =
      _$GlobalStateManagerCopyWithImpl<$Res, GlobalStateManager>;
  @useResult
  $Res call(
      {@MaterialColorConverter() MaterialColor materialColor,
      ThemeMode themeMode});
}

/// @nodoc
class _$GlobalStateManagerCopyWithImpl<$Res, $Val extends GlobalStateManager>
    implements $GlobalStateManagerCopyWith<$Res> {
  _$GlobalStateManagerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? materialColor = null,
    Object? themeMode = null,
  }) {
    return _then(_value.copyWith(
      materialColor: null == materialColor
          ? _value.materialColor
          : materialColor // ignore: cast_nullable_to_non_nullable
              as MaterialColor,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GlobalStateManagerImplCopyWith<$Res>
    implements $GlobalStateManagerCopyWith<$Res> {
  factory _$$GlobalStateManagerImplCopyWith(_$GlobalStateManagerImpl value,
          $Res Function(_$GlobalStateManagerImpl) then) =
      __$$GlobalStateManagerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@MaterialColorConverter() MaterialColor materialColor,
      ThemeMode themeMode});
}

/// @nodoc
class __$$GlobalStateManagerImplCopyWithImpl<$Res>
    extends _$GlobalStateManagerCopyWithImpl<$Res, _$GlobalStateManagerImpl>
    implements _$$GlobalStateManagerImplCopyWith<$Res> {
  __$$GlobalStateManagerImplCopyWithImpl(_$GlobalStateManagerImpl _value,
      $Res Function(_$GlobalStateManagerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? materialColor = null,
    Object? themeMode = null,
  }) {
    return _then(_$GlobalStateManagerImpl(
      materialColor: null == materialColor
          ? _value.materialColor
          : materialColor // ignore: cast_nullable_to_non_nullable
              as MaterialColor,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GlobalStateManagerImpl extends _GlobalStateManager {
  _$GlobalStateManagerImpl(
      {@MaterialColorConverter() this.materialColor = Colors.blue,
      this.themeMode = ThemeMode.system})
      : super._();

  factory _$GlobalStateManagerImpl.fromJson(Map<String, dynamic> json) =>
      _$$GlobalStateManagerImplFromJson(json);

  @override
  @JsonKey()
  @MaterialColorConverter()
  final MaterialColor materialColor;
  @override
  @JsonKey()
  final ThemeMode themeMode;

  @override
  String toString() {
    return 'GlobalStateManager.raw(materialColor: $materialColor, themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalStateManagerImpl &&
            (identical(other.materialColor, materialColor) ||
                other.materialColor == materialColor) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, materialColor, themeMode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalStateManagerImplCopyWith<_$GlobalStateManagerImpl> get copyWith =>
      __$$GlobalStateManagerImplCopyWithImpl<_$GlobalStateManagerImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)
        raw,
  }) {
    return raw(materialColor, themeMode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)?
        raw,
  }) {
    return raw?.call(materialColor, themeMode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@MaterialColorConverter() MaterialColor materialColor,
            ThemeMode themeMode)?
        raw,
    required TResult orElse(),
  }) {
    if (raw != null) {
      return raw(materialColor, themeMode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GlobalStateManager value) raw,
  }) {
    return raw(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GlobalStateManager value)? raw,
  }) {
    return raw?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GlobalStateManager value)? raw,
    required TResult orElse(),
  }) {
    if (raw != null) {
      return raw(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GlobalStateManagerImplToJson(
      this,
    );
  }
}

abstract class _GlobalStateManager extends GlobalStateManager {
  factory _GlobalStateManager(
      {@MaterialColorConverter() final MaterialColor materialColor,
      final ThemeMode themeMode}) = _$GlobalStateManagerImpl;
  _GlobalStateManager._() : super._();

  factory _GlobalStateManager.fromJson(Map<String, dynamic> json) =
      _$GlobalStateManagerImpl.fromJson;

  @override
  @MaterialColorConverter()
  MaterialColor get materialColor;
  @override
  ThemeMode get themeMode;
  @override
  @JsonKey(ignore: true)
  _$$GlobalStateManagerImplCopyWith<_$GlobalStateManagerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
