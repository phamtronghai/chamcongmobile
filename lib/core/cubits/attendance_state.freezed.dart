// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttendanceState {

 AttendanceStatus get status; String? get errorMessage; String? get successMessage; bool get isProcessing; bool get isCheckingFace; bool get hasRegisteredFace; String? get currentLocation; double? get currentLat; double? get currentLng; DateTime? get serverTime; DateTime get selectedDate; List<AttendanceModel> get attendanceRecords; bool get isLoadingRecords; List<WorklogModel> get dailyWorklogs; bool get isLoadingWorklogs; bool get isLoadingReport;
/// Create a copy of AttendanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceStateCopyWith<AttendanceState> get copyWith => _$AttendanceStateCopyWithImpl<AttendanceState>(this as AttendanceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.isCheckingFace, isCheckingFace) || other.isCheckingFace == isCheckingFace)&&(identical(other.hasRegisteredFace, hasRegisteredFace) || other.hasRegisteredFace == hasRegisteredFace)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.serverTime, serverTime) || other.serverTime == serverTime)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&const DeepCollectionEquality().equals(other.attendanceRecords, attendanceRecords)&&(identical(other.isLoadingRecords, isLoadingRecords) || other.isLoadingRecords == isLoadingRecords)&&const DeepCollectionEquality().equals(other.dailyWorklogs, dailyWorklogs)&&(identical(other.isLoadingWorklogs, isLoadingWorklogs) || other.isLoadingWorklogs == isLoadingWorklogs)&&(identical(other.isLoadingReport, isLoadingReport) || other.isLoadingReport == isLoadingReport));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,successMessage,isProcessing,isCheckingFace,hasRegisteredFace,currentLocation,currentLat,currentLng,serverTime,selectedDate,const DeepCollectionEquality().hash(attendanceRecords),isLoadingRecords,const DeepCollectionEquality().hash(dailyWorklogs),isLoadingWorklogs,isLoadingReport);

@override
String toString() {
  return 'AttendanceState(status: $status, errorMessage: $errorMessage, successMessage: $successMessage, isProcessing: $isProcessing, isCheckingFace: $isCheckingFace, hasRegisteredFace: $hasRegisteredFace, currentLocation: $currentLocation, currentLat: $currentLat, currentLng: $currentLng, serverTime: $serverTime, selectedDate: $selectedDate, attendanceRecords: $attendanceRecords, isLoadingRecords: $isLoadingRecords, dailyWorklogs: $dailyWorklogs, isLoadingWorklogs: $isLoadingWorklogs, isLoadingReport: $isLoadingReport)';
}


}

/// @nodoc
abstract mixin class $AttendanceStateCopyWith<$Res>  {
  factory $AttendanceStateCopyWith(AttendanceState value, $Res Function(AttendanceState) _then) = _$AttendanceStateCopyWithImpl;
@useResult
$Res call({
 AttendanceStatus status, String? errorMessage, String? successMessage, bool isProcessing, bool isCheckingFace, bool hasRegisteredFace, String? currentLocation, double? currentLat, double? currentLng, DateTime? serverTime, DateTime selectedDate, List<AttendanceModel> attendanceRecords, bool isLoadingRecords, List<WorklogModel> dailyWorklogs, bool isLoadingWorklogs, bool isLoadingReport
});




}
/// @nodoc
class _$AttendanceStateCopyWithImpl<$Res>
    implements $AttendanceStateCopyWith<$Res> {
  _$AttendanceStateCopyWithImpl(this._self, this._then);

  final AttendanceState _self;
  final $Res Function(AttendanceState) _then;

/// Create a copy of AttendanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? successMessage = freezed,Object? isProcessing = null,Object? isCheckingFace = null,Object? hasRegisteredFace = null,Object? currentLocation = freezed,Object? currentLat = freezed,Object? currentLng = freezed,Object? serverTime = freezed,Object? selectedDate = null,Object? attendanceRecords = null,Object? isLoadingRecords = null,Object? dailyWorklogs = null,Object? isLoadingWorklogs = null,Object? isLoadingReport = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,isCheckingFace: null == isCheckingFace ? _self.isCheckingFace : isCheckingFace // ignore: cast_nullable_to_non_nullable
as bool,hasRegisteredFace: null == hasRegisteredFace ? _self.hasRegisteredFace : hasRegisteredFace // ignore: cast_nullable_to_non_nullable
as bool,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String?,currentLat: freezed == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double?,currentLng: freezed == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double?,serverTime: freezed == serverTime ? _self.serverTime : serverTime // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,attendanceRecords: null == attendanceRecords ? _self.attendanceRecords : attendanceRecords // ignore: cast_nullable_to_non_nullable
as List<AttendanceModel>,isLoadingRecords: null == isLoadingRecords ? _self.isLoadingRecords : isLoadingRecords // ignore: cast_nullable_to_non_nullable
as bool,dailyWorklogs: null == dailyWorklogs ? _self.dailyWorklogs : dailyWorklogs // ignore: cast_nullable_to_non_nullable
as List<WorklogModel>,isLoadingWorklogs: null == isLoadingWorklogs ? _self.isLoadingWorklogs : isLoadingWorklogs // ignore: cast_nullable_to_non_nullable
as bool,isLoadingReport: null == isLoadingReport ? _self.isLoadingReport : isLoadingReport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceState].
extension AttendanceStatePatterns on AttendanceState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceState value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceState value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttendanceStatus status,  String? errorMessage,  String? successMessage,  bool isProcessing,  bool isCheckingFace,  bool hasRegisteredFace,  String? currentLocation,  double? currentLat,  double? currentLng,  DateTime? serverTime,  DateTime selectedDate,  List<AttendanceModel> attendanceRecords,  bool isLoadingRecords,  List<WorklogModel> dailyWorklogs,  bool isLoadingWorklogs,  bool isLoadingReport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.successMessage,_that.isProcessing,_that.isCheckingFace,_that.hasRegisteredFace,_that.currentLocation,_that.currentLat,_that.currentLng,_that.serverTime,_that.selectedDate,_that.attendanceRecords,_that.isLoadingRecords,_that.dailyWorklogs,_that.isLoadingWorklogs,_that.isLoadingReport);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttendanceStatus status,  String? errorMessage,  String? successMessage,  bool isProcessing,  bool isCheckingFace,  bool hasRegisteredFace,  String? currentLocation,  double? currentLat,  double? currentLng,  DateTime? serverTime,  DateTime selectedDate,  List<AttendanceModel> attendanceRecords,  bool isLoadingRecords,  List<WorklogModel> dailyWorklogs,  bool isLoadingWorklogs,  bool isLoadingReport)  $default,) {final _that = this;
switch (_that) {
case _AttendanceState():
return $default(_that.status,_that.errorMessage,_that.successMessage,_that.isProcessing,_that.isCheckingFace,_that.hasRegisteredFace,_that.currentLocation,_that.currentLat,_that.currentLng,_that.serverTime,_that.selectedDate,_that.attendanceRecords,_that.isLoadingRecords,_that.dailyWorklogs,_that.isLoadingWorklogs,_that.isLoadingReport);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttendanceStatus status,  String? errorMessage,  String? successMessage,  bool isProcessing,  bool isCheckingFace,  bool hasRegisteredFace,  String? currentLocation,  double? currentLat,  double? currentLng,  DateTime? serverTime,  DateTime selectedDate,  List<AttendanceModel> attendanceRecords,  bool isLoadingRecords,  List<WorklogModel> dailyWorklogs,  bool isLoadingWorklogs,  bool isLoadingReport)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.successMessage,_that.isProcessing,_that.isCheckingFace,_that.hasRegisteredFace,_that.currentLocation,_that.currentLat,_that.currentLng,_that.serverTime,_that.selectedDate,_that.attendanceRecords,_that.isLoadingRecords,_that.dailyWorklogs,_that.isLoadingWorklogs,_that.isLoadingReport);case _:
  return null;

}
}

}

/// @nodoc


class _AttendanceState implements AttendanceState {
  const _AttendanceState({this.status = AttendanceStatus.initial, this.errorMessage, this.successMessage, this.isProcessing = false, this.isCheckingFace = true, this.hasRegisteredFace = false, this.currentLocation, this.currentLat, this.currentLng, this.serverTime, required this.selectedDate, final  List<AttendanceModel> attendanceRecords = const <AttendanceModel>[], this.isLoadingRecords = true, final  List<WorklogModel> dailyWorklogs = const <WorklogModel>[], this.isLoadingWorklogs = false, this.isLoadingReport = false}): _attendanceRecords = attendanceRecords,_dailyWorklogs = dailyWorklogs;
  

@override@JsonKey() final  AttendanceStatus status;
@override final  String? errorMessage;
@override final  String? successMessage;
@override@JsonKey() final  bool isProcessing;
@override@JsonKey() final  bool isCheckingFace;
@override@JsonKey() final  bool hasRegisteredFace;
@override final  String? currentLocation;
@override final  double? currentLat;
@override final  double? currentLng;
@override final  DateTime? serverTime;
@override final  DateTime selectedDate;
 final  List<AttendanceModel> _attendanceRecords;
@override@JsonKey() List<AttendanceModel> get attendanceRecords {
  if (_attendanceRecords is EqualUnmodifiableListView) return _attendanceRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attendanceRecords);
}

@override@JsonKey() final  bool isLoadingRecords;
 final  List<WorklogModel> _dailyWorklogs;
@override@JsonKey() List<WorklogModel> get dailyWorklogs {
  if (_dailyWorklogs is EqualUnmodifiableListView) return _dailyWorklogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyWorklogs);
}

@override@JsonKey() final  bool isLoadingWorklogs;
@override@JsonKey() final  bool isLoadingReport;

/// Create a copy of AttendanceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceStateCopyWith<_AttendanceState> get copyWith => __$AttendanceStateCopyWithImpl<_AttendanceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.isCheckingFace, isCheckingFace) || other.isCheckingFace == isCheckingFace)&&(identical(other.hasRegisteredFace, hasRegisteredFace) || other.hasRegisteredFace == hasRegisteredFace)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.serverTime, serverTime) || other.serverTime == serverTime)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&const DeepCollectionEquality().equals(other._attendanceRecords, _attendanceRecords)&&(identical(other.isLoadingRecords, isLoadingRecords) || other.isLoadingRecords == isLoadingRecords)&&const DeepCollectionEquality().equals(other._dailyWorklogs, _dailyWorklogs)&&(identical(other.isLoadingWorklogs, isLoadingWorklogs) || other.isLoadingWorklogs == isLoadingWorklogs)&&(identical(other.isLoadingReport, isLoadingReport) || other.isLoadingReport == isLoadingReport));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,successMessage,isProcessing,isCheckingFace,hasRegisteredFace,currentLocation,currentLat,currentLng,serverTime,selectedDate,const DeepCollectionEquality().hash(_attendanceRecords),isLoadingRecords,const DeepCollectionEquality().hash(_dailyWorklogs),isLoadingWorklogs,isLoadingReport);

@override
String toString() {
  return 'AttendanceState(status: $status, errorMessage: $errorMessage, successMessage: $successMessage, isProcessing: $isProcessing, isCheckingFace: $isCheckingFace, hasRegisteredFace: $hasRegisteredFace, currentLocation: $currentLocation, currentLat: $currentLat, currentLng: $currentLng, serverTime: $serverTime, selectedDate: $selectedDate, attendanceRecords: $attendanceRecords, isLoadingRecords: $isLoadingRecords, dailyWorklogs: $dailyWorklogs, isLoadingWorklogs: $isLoadingWorklogs, isLoadingReport: $isLoadingReport)';
}


}

/// @nodoc
abstract mixin class _$AttendanceStateCopyWith<$Res> implements $AttendanceStateCopyWith<$Res> {
  factory _$AttendanceStateCopyWith(_AttendanceState value, $Res Function(_AttendanceState) _then) = __$AttendanceStateCopyWithImpl;
@override @useResult
$Res call({
 AttendanceStatus status, String? errorMessage, String? successMessage, bool isProcessing, bool isCheckingFace, bool hasRegisteredFace, String? currentLocation, double? currentLat, double? currentLng, DateTime? serverTime, DateTime selectedDate, List<AttendanceModel> attendanceRecords, bool isLoadingRecords, List<WorklogModel> dailyWorklogs, bool isLoadingWorklogs, bool isLoadingReport
});




}
/// @nodoc
class __$AttendanceStateCopyWithImpl<$Res>
    implements _$AttendanceStateCopyWith<$Res> {
  __$AttendanceStateCopyWithImpl(this._self, this._then);

  final _AttendanceState _self;
  final $Res Function(_AttendanceState) _then;

/// Create a copy of AttendanceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? successMessage = freezed,Object? isProcessing = null,Object? isCheckingFace = null,Object? hasRegisteredFace = null,Object? currentLocation = freezed,Object? currentLat = freezed,Object? currentLng = freezed,Object? serverTime = freezed,Object? selectedDate = null,Object? attendanceRecords = null,Object? isLoadingRecords = null,Object? dailyWorklogs = null,Object? isLoadingWorklogs = null,Object? isLoadingReport = null,}) {
  return _then(_AttendanceState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,isCheckingFace: null == isCheckingFace ? _self.isCheckingFace : isCheckingFace // ignore: cast_nullable_to_non_nullable
as bool,hasRegisteredFace: null == hasRegisteredFace ? _self.hasRegisteredFace : hasRegisteredFace // ignore: cast_nullable_to_non_nullable
as bool,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String?,currentLat: freezed == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double?,currentLng: freezed == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double?,serverTime: freezed == serverTime ? _self.serverTime : serverTime // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,attendanceRecords: null == attendanceRecords ? _self._attendanceRecords : attendanceRecords // ignore: cast_nullable_to_non_nullable
as List<AttendanceModel>,isLoadingRecords: null == isLoadingRecords ? _self.isLoadingRecords : isLoadingRecords // ignore: cast_nullable_to_non_nullable
as bool,dailyWorklogs: null == dailyWorklogs ? _self._dailyWorklogs : dailyWorklogs // ignore: cast_nullable_to_non_nullable
as List<WorklogModel>,isLoadingWorklogs: null == isLoadingWorklogs ? _self.isLoadingWorklogs : isLoadingWorklogs // ignore: cast_nullable_to_non_nullable
as bool,isLoadingReport: null == isLoadingReport ? _self.isLoadingReport : isLoadingReport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
