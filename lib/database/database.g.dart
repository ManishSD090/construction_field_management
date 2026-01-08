// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _geofenceRadiusMeta =
      const VerificationMeta('geofenceRadius');
  @override
  late final GeneratedColumn<double> geofenceRadius = GeneratedColumn<double>(
      'geofence_radius', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(200.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        name,
        description,
        location,
        latitude,
        longitude,
        geofenceRadius,
        status,
        isDeleted,
        serverUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('geofence_radius')) {
      context.handle(
          _geofenceRadiusMeta,
          geofenceRadius.isAcceptableOrUnknown(
              data['geofence_radius']!, _geofenceRadiusMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      geofenceRadius: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}geofence_radius'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectEntity extends DataClass implements Insertable<ProjectEntity> {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String location;
  final double latitude;
  final double longitude;
  final double geofenceRadius;
  final String status;
  final bool isDeleted;
  final DateTime? serverUpdatedAt;
  const ProjectEntity(
      {required this.id,
      required this.projectId,
      required this.name,
      this.description,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.geofenceRadius,
      required this.status,
      required this.isDeleted,
      this.serverUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['location'] = Variable<String>(location);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['geofence_radius'] = Variable<double>(geofenceRadius);
    map['status'] = Variable<String>(status);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      location: Value(location),
      latitude: Value(latitude),
      longitude: Value(longitude),
      geofenceRadius: Value(geofenceRadius),
      status: Value(status),
      isDeleted: Value(isDeleted),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory ProjectEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectEntity(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      location: serializer.fromJson<String>(json['location']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      geofenceRadius: serializer.fromJson<double>(json['geofenceRadius']),
      status: serializer.fromJson<String>(json['status']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'location': serializer.toJson<String>(location),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'geofenceRadius': serializer.toJson<double>(geofenceRadius),
      'status': serializer.toJson<String>(status),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
    };
  }

  ProjectEntity copyWith(
          {String? id,
          String? projectId,
          String? name,
          Value<String?> description = const Value.absent(),
          String? location,
          double? latitude,
          double? longitude,
          double? geofenceRadius,
          String? status,
          bool? isDeleted,
          Value<DateTime?> serverUpdatedAt = const Value.absent()}) =>
      ProjectEntity(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        geofenceRadius: geofenceRadius ?? this.geofenceRadius,
        status: status ?? this.status,
        isDeleted: isDeleted ?? this.isDeleted,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
      );
  ProjectEntity copyWithCompanion(ProjectsCompanion data) {
    return ProjectEntity(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      location: data.location.present ? data.location.value : this.location,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geofenceRadius: data.geofenceRadius.present
          ? data.geofenceRadius.value
          : this.geofenceRadius,
      status: data.status.present ? data.status.value : this.status,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectEntity(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geofenceRadius: $geofenceRadius, ')
          ..write('status: $status, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, name, description, location,
      latitude, longitude, geofenceRadius, status, isDeleted, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectEntity &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.description == this.description &&
          other.location == this.location &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geofenceRadius == this.geofenceRadius &&
          other.status == this.status &&
          other.isDeleted == this.isDeleted &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ProjectsCompanion extends UpdateCompanion<ProjectEntity> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> location;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> geofenceRadius;
  final Value<String> status;
  final Value<bool> isDeleted;
  final Value<DateTime?> serverUpdatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geofenceRadius = const Value.absent(),
    this.status = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String projectId,
    required String name,
    this.description = const Value.absent(),
    required String location,
    required double latitude,
    required double longitude,
    this.geofenceRadius = const Value.absent(),
    required String status,
    this.isDeleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        name = Value(name),
        location = Value(location),
        latitude = Value(latitude),
        longitude = Value(longitude),
        status = Value(status);
  static Insertable<ProjectEntity> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? location,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? geofenceRadius,
    Expression<String>? status,
    Expression<bool>? isDeleted,
    Expression<DateTime>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geofenceRadius != null) 'geofence_radius': geofenceRadius,
      if (status != null) 'status': status,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? location,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? geofenceRadius,
      Value<String>? status,
      Value<bool>? isDeleted,
      Value<DateTime?>? serverUpdatedAt,
      Value<int>? rowid}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geofenceRadius.present) {
      map['geofence_radius'] = Variable<double>(geofenceRadius.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geofenceRadius: $geofenceRadius, ')
          ..write('status: $status, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, AttendanceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationTypeMeta =
      const VerificationMeta('locationType');
  @override
  late final GeneratedColumn<String> locationType = GeneratedColumn<String>(
      'location_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PRESENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _checkInTimeMeta =
      const VerificationMeta('checkInTime');
  @override
  late final GeneratedColumn<DateTime> checkInTime = GeneratedColumn<DateTime>(
      'check_in_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _checkOutTimeMeta =
      const VerificationMeta('checkOutTime');
  @override
  late final GeneratedColumn<DateTime> checkOutTime = GeneratedColumn<DateTime>(
      'check_out_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _checkInLatitudeMeta =
      const VerificationMeta('checkInLatitude');
  @override
  late final GeneratedColumn<double> checkInLatitude = GeneratedColumn<double>(
      'check_in_latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _checkInLongitudeMeta =
      const VerificationMeta('checkInLongitude');
  @override
  late final GeneratedColumn<double> checkInLongitude = GeneratedColumn<double>(
      'check_in_longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _checkOutLatitudeMeta =
      const VerificationMeta('checkOutLatitude');
  @override
  late final GeneratedColumn<double> checkOutLatitude = GeneratedColumn<double>(
      'check_out_latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _checkOutLongitudeMeta =
      const VerificationMeta('checkOutLongitude');
  @override
  late final GeneratedColumn<double> checkOutLongitude =
      GeneratedColumn<double>('check_out_longitude', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        projectId,
        locationType,
        status,
        date,
        checkInTime,
        checkOutTime,
        checkInLatitude,
        checkInLongitude,
        checkOutLatitude,
        checkOutLongitude,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(Insertable<AttendanceEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('location_type')) {
      context.handle(
          _locationTypeMeta,
          locationType.isAcceptableOrUnknown(
              data['location_type']!, _locationTypeMeta));
    } else if (isInserting) {
      context.missing(_locationTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('check_in_time')) {
      context.handle(
          _checkInTimeMeta,
          checkInTime.isAcceptableOrUnknown(
              data['check_in_time']!, _checkInTimeMeta));
    }
    if (data.containsKey('check_out_time')) {
      context.handle(
          _checkOutTimeMeta,
          checkOutTime.isAcceptableOrUnknown(
              data['check_out_time']!, _checkOutTimeMeta));
    }
    if (data.containsKey('check_in_latitude')) {
      context.handle(
          _checkInLatitudeMeta,
          checkInLatitude.isAcceptableOrUnknown(
              data['check_in_latitude']!, _checkInLatitudeMeta));
    }
    if (data.containsKey('check_in_longitude')) {
      context.handle(
          _checkInLongitudeMeta,
          checkInLongitude.isAcceptableOrUnknown(
              data['check_in_longitude']!, _checkInLongitudeMeta));
    }
    if (data.containsKey('check_out_latitude')) {
      context.handle(
          _checkOutLatitudeMeta,
          checkOutLatitude.isAcceptableOrUnknown(
              data['check_out_latitude']!, _checkOutLatitudeMeta));
    }
    if (data.containsKey('check_out_longitude')) {
      context.handle(
          _checkOutLongitudeMeta,
          checkOutLongitude.isAcceptableOrUnknown(
              data['check_out_longitude']!, _checkOutLongitudeMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id']),
      locationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      checkInTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}check_in_time']),
      checkOutTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}check_out_time']),
      checkInLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}check_in_latitude']),
      checkInLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}check_in_longitude']),
      checkOutLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}check_out_latitude']),
      checkOutLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}check_out_longitude']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class AttendanceEntity extends DataClass
    implements Insertable<AttendanceEntity> {
  final String id;
  final String userId;
  final String? projectId;
  final String locationType;
  final String status;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final bool isSynced;
  final DateTime createdAt;
  const AttendanceEntity(
      {required this.id,
      required this.userId,
      this.projectId,
      required this.locationType,
      required this.status,
      required this.date,
      this.checkInTime,
      this.checkOutTime,
      this.checkInLatitude,
      this.checkInLongitude,
      this.checkOutLatitude,
      this.checkOutLongitude,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['location_type'] = Variable<String>(locationType);
    map['status'] = Variable<String>(status);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || checkInTime != null) {
      map['check_in_time'] = Variable<DateTime>(checkInTime);
    }
    if (!nullToAbsent || checkOutTime != null) {
      map['check_out_time'] = Variable<DateTime>(checkOutTime);
    }
    if (!nullToAbsent || checkInLatitude != null) {
      map['check_in_latitude'] = Variable<double>(checkInLatitude);
    }
    if (!nullToAbsent || checkInLongitude != null) {
      map['check_in_longitude'] = Variable<double>(checkInLongitude);
    }
    if (!nullToAbsent || checkOutLatitude != null) {
      map['check_out_latitude'] = Variable<double>(checkOutLatitude);
    }
    if (!nullToAbsent || checkOutLongitude != null) {
      map['check_out_longitude'] = Variable<double>(checkOutLongitude);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      userId: Value(userId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      locationType: Value(locationType),
      status: Value(status),
      date: Value(date),
      checkInTime: checkInTime == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInTime),
      checkOutTime: checkOutTime == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutTime),
      checkInLatitude: checkInLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInLatitude),
      checkInLongitude: checkInLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInLongitude),
      checkOutLatitude: checkOutLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutLatitude),
      checkOutLongitude: checkOutLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutLongitude),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory AttendanceEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEntity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      locationType: serializer.fromJson<String>(json['locationType']),
      status: serializer.fromJson<String>(json['status']),
      date: serializer.fromJson<DateTime>(json['date']),
      checkInTime: serializer.fromJson<DateTime?>(json['checkInTime']),
      checkOutTime: serializer.fromJson<DateTime?>(json['checkOutTime']),
      checkInLatitude: serializer.fromJson<double?>(json['checkInLatitude']),
      checkInLongitude: serializer.fromJson<double?>(json['checkInLongitude']),
      checkOutLatitude: serializer.fromJson<double?>(json['checkOutLatitude']),
      checkOutLongitude:
          serializer.fromJson<double?>(json['checkOutLongitude']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'projectId': serializer.toJson<String?>(projectId),
      'locationType': serializer.toJson<String>(locationType),
      'status': serializer.toJson<String>(status),
      'date': serializer.toJson<DateTime>(date),
      'checkInTime': serializer.toJson<DateTime?>(checkInTime),
      'checkOutTime': serializer.toJson<DateTime?>(checkOutTime),
      'checkInLatitude': serializer.toJson<double?>(checkInLatitude),
      'checkInLongitude': serializer.toJson<double?>(checkInLongitude),
      'checkOutLatitude': serializer.toJson<double?>(checkOutLatitude),
      'checkOutLongitude': serializer.toJson<double?>(checkOutLongitude),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttendanceEntity copyWith(
          {String? id,
          String? userId,
          Value<String?> projectId = const Value.absent(),
          String? locationType,
          String? status,
          DateTime? date,
          Value<DateTime?> checkInTime = const Value.absent(),
          Value<DateTime?> checkOutTime = const Value.absent(),
          Value<double?> checkInLatitude = const Value.absent(),
          Value<double?> checkInLongitude = const Value.absent(),
          Value<double?> checkOutLatitude = const Value.absent(),
          Value<double?> checkOutLongitude = const Value.absent(),
          bool? isSynced,
          DateTime? createdAt}) =>
      AttendanceEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        projectId: projectId.present ? projectId.value : this.projectId,
        locationType: locationType ?? this.locationType,
        status: status ?? this.status,
        date: date ?? this.date,
        checkInTime: checkInTime.present ? checkInTime.value : this.checkInTime,
        checkOutTime:
            checkOutTime.present ? checkOutTime.value : this.checkOutTime,
        checkInLatitude: checkInLatitude.present
            ? checkInLatitude.value
            : this.checkInLatitude,
        checkInLongitude: checkInLongitude.present
            ? checkInLongitude.value
            : this.checkInLongitude,
        checkOutLatitude: checkOutLatitude.present
            ? checkOutLatitude.value
            : this.checkOutLatitude,
        checkOutLongitude: checkOutLongitude.present
            ? checkOutLongitude.value
            : this.checkOutLongitude,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  AttendanceEntity copyWithCompanion(AttendancesCompanion data) {
    return AttendanceEntity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      locationType: data.locationType.present
          ? data.locationType.value
          : this.locationType,
      status: data.status.present ? data.status.value : this.status,
      date: data.date.present ? data.date.value : this.date,
      checkInTime:
          data.checkInTime.present ? data.checkInTime.value : this.checkInTime,
      checkOutTime: data.checkOutTime.present
          ? data.checkOutTime.value
          : this.checkOutTime,
      checkInLatitude: data.checkInLatitude.present
          ? data.checkInLatitude.value
          : this.checkInLatitude,
      checkInLongitude: data.checkInLongitude.present
          ? data.checkInLongitude.value
          : this.checkInLongitude,
      checkOutLatitude: data.checkOutLatitude.present
          ? data.checkOutLatitude.value
          : this.checkOutLatitude,
      checkOutLongitude: data.checkOutLongitude.present
          ? data.checkOutLongitude.value
          : this.checkOutLongitude,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEntity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('projectId: $projectId, ')
          ..write('locationType: $locationType, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('checkInLatitude: $checkInLatitude, ')
          ..write('checkInLongitude: $checkInLongitude, ')
          ..write('checkOutLatitude: $checkOutLatitude, ')
          ..write('checkOutLongitude: $checkOutLongitude, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      projectId,
      locationType,
      status,
      date,
      checkInTime,
      checkOutTime,
      checkInLatitude,
      checkInLongitude,
      checkOutLatitude,
      checkOutLongitude,
      isSynced,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEntity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.projectId == this.projectId &&
          other.locationType == this.locationType &&
          other.status == this.status &&
          other.date == this.date &&
          other.checkInTime == this.checkInTime &&
          other.checkOutTime == this.checkOutTime &&
          other.checkInLatitude == this.checkInLatitude &&
          other.checkInLongitude == this.checkInLongitude &&
          other.checkOutLatitude == this.checkOutLatitude &&
          other.checkOutLongitude == this.checkOutLongitude &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class AttendancesCompanion extends UpdateCompanion<AttendanceEntity> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> projectId;
  final Value<String> locationType;
  final Value<String> status;
  final Value<DateTime> date;
  final Value<DateTime?> checkInTime;
  final Value<DateTime?> checkOutTime;
  final Value<double?> checkInLatitude;
  final Value<double?> checkInLongitude;
  final Value<double?> checkOutLatitude;
  final Value<double?> checkOutLongitude;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.locationType = const Value.absent(),
    this.status = const Value.absent(),
    this.date = const Value.absent(),
    this.checkInTime = const Value.absent(),
    this.checkOutTime = const Value.absent(),
    this.checkInLatitude = const Value.absent(),
    this.checkInLongitude = const Value.absent(),
    this.checkOutLatitude = const Value.absent(),
    this.checkOutLongitude = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendancesCompanion.insert({
    required String id,
    required String userId,
    this.projectId = const Value.absent(),
    required String locationType,
    this.status = const Value.absent(),
    required DateTime date,
    this.checkInTime = const Value.absent(),
    this.checkOutTime = const Value.absent(),
    this.checkInLatitude = const Value.absent(),
    this.checkInLongitude = const Value.absent(),
    this.checkOutLatitude = const Value.absent(),
    this.checkOutLongitude = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        locationType = Value(locationType),
        date = Value(date);
  static Insertable<AttendanceEntity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? projectId,
    Expression<String>? locationType,
    Expression<String>? status,
    Expression<DateTime>? date,
    Expression<DateTime>? checkInTime,
    Expression<DateTime>? checkOutTime,
    Expression<double>? checkInLatitude,
    Expression<double>? checkInLongitude,
    Expression<double>? checkOutLatitude,
    Expression<double>? checkOutLongitude,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (projectId != null) 'project_id': projectId,
      if (locationType != null) 'location_type': locationType,
      if (status != null) 'status': status,
      if (date != null) 'date': date,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      if (checkInLatitude != null) 'check_in_latitude': checkInLatitude,
      if (checkInLongitude != null) 'check_in_longitude': checkInLongitude,
      if (checkOutLatitude != null) 'check_out_latitude': checkOutLatitude,
      if (checkOutLongitude != null) 'check_out_longitude': checkOutLongitude,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendancesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? projectId,
      Value<String>? locationType,
      Value<String>? status,
      Value<DateTime>? date,
      Value<DateTime?>? checkInTime,
      Value<DateTime?>? checkOutTime,
      Value<double?>? checkInLatitude,
      Value<double?>? checkInLongitude,
      Value<double?>? checkOutLatitude,
      Value<double?>? checkOutLongitude,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AttendancesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      locationType: locationType ?? this.locationType,
      status: status ?? this.status,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (locationType.present) {
      map['location_type'] = Variable<String>(locationType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (checkInTime.present) {
      map['check_in_time'] = Variable<DateTime>(checkInTime.value);
    }
    if (checkOutTime.present) {
      map['check_out_time'] = Variable<DateTime>(checkOutTime.value);
    }
    if (checkInLatitude.present) {
      map['check_in_latitude'] = Variable<double>(checkInLatitude.value);
    }
    if (checkInLongitude.present) {
      map['check_in_longitude'] = Variable<double>(checkInLongitude.value);
    }
    if (checkOutLatitude.present) {
      map['check_out_latitude'] = Variable<double>(checkOutLatitude.value);
    }
    if (checkOutLongitude.present) {
      map['check_out_longitude'] = Variable<double>(checkOutLongitude.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('projectId: $projectId, ')
          ..write('locationType: $locationType, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('checkInLatitude: $checkInLatitude, ')
          ..write('checkInLongitude: $checkInLongitude, ')
          ..write('checkOutLatitude: $checkOutLatitude, ')
          ..write('checkOutLongitude: $checkOutLongitude, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedToIdMeta =
      const VerificationMeta('assignedToId');
  @override
  late final GeneratedColumn<String> assignedToId = GeneratedColumn<String>(
      'assigned_to_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByIdMeta =
      const VerificationMeta('createdById');
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
      'created_by_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('TODO'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MEDIUM'));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
      'progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedDateMeta =
      const VerificationMeta('completedDate');
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>('completed_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _estimatedHoursMeta =
      const VerificationMeta('estimatedHours');
  @override
  late final GeneratedColumn<double> estimatedHours = GeneratedColumn<double>(
      'estimated_hours', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _actualHoursMeta =
      const VerificationMeta('actualHours');
  @override
  late final GeneratedColumn<double> actualHours = GeneratedColumn<double>(
      'actual_hours', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        assignedToId,
        createdById,
        title,
        description,
        status,
        priority,
        progress,
        startDate,
        dueDate,
        completedDate,
        estimatedHours,
        actualHours,
        isDirty,
        isDeleted,
        createdAt,
        updatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('assigned_to_id')) {
      context.handle(
          _assignedToIdMeta,
          assignedToId.isAcceptableOrUnknown(
              data['assigned_to_id']!, _assignedToIdMeta));
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
          _createdByIdMeta,
          createdById.isAcceptableOrUnknown(
              data['created_by_id']!, _createdByIdMeta));
    } else if (isInserting) {
      context.missing(_createdByIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('completed_date')) {
      context.handle(
          _completedDateMeta,
          completedDate.isAcceptableOrUnknown(
              data['completed_date']!, _completedDateMeta));
    }
    if (data.containsKey('estimated_hours')) {
      context.handle(
          _estimatedHoursMeta,
          estimatedHours.isAcceptableOrUnknown(
              data['estimated_hours']!, _estimatedHoursMeta));
    }
    if (data.containsKey('actual_hours')) {
      context.handle(
          _actualHoursMeta,
          actualHours.isAcceptableOrUnknown(
              data['actual_hours']!, _actualHoursMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      assignedToId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_to_id']),
      createdById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      completedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}completed_date']),
      estimatedHours: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estimated_hours']),
      actualHours: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}actual_hours'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskEntity extends DataClass implements Insertable<TaskEntity> {
  final String id;
  final String projectId;
  final String? assignedToId;
  final String createdById;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final int progress;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final double? estimatedHours;
  final double actualHours;
  final bool isDirty;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime localUpdatedAt;
  const TaskEntity(
      {required this.id,
      required this.projectId,
      this.assignedToId,
      required this.createdById,
      required this.title,
      this.description,
      required this.status,
      required this.priority,
      required this.progress,
      this.startDate,
      this.dueDate,
      this.completedDate,
      this.estimatedHours,
      required this.actualHours,
      required this.isDirty,
      required this.isDeleted,
      required this.createdAt,
      this.updatedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || assignedToId != null) {
      map['assigned_to_id'] = Variable<String>(assignedToId);
    }
    map['created_by_id'] = Variable<String>(createdById);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    if (!nullToAbsent || estimatedHours != null) {
      map['estimated_hours'] = Variable<double>(estimatedHours);
    }
    map['actual_hours'] = Variable<double>(actualHours);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      projectId: Value(projectId),
      assignedToId: assignedToId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToId),
      createdById: Value(createdById),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      priority: Value(priority),
      progress: Value(progress),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      estimatedHours: estimatedHours == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedHours),
      actualHours: Value(actualHours),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntity(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      assignedToId: serializer.fromJson<String?>(json['assignedToId']),
      createdById: serializer.fromJson<String>(json['createdById']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      progress: serializer.fromJson<int>(json['progress']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      estimatedHours: serializer.fromJson<double?>(json['estimatedHours']),
      actualHours: serializer.fromJson<double>(json['actualHours']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'assignedToId': serializer.toJson<String?>(assignedToId),
      'createdById': serializer.toJson<String>(createdById),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'progress': serializer.toJson<int>(progress),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'estimatedHours': serializer.toJson<double?>(estimatedHours),
      'actualHours': serializer.toJson<double>(actualHours),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  TaskEntity copyWith(
          {String? id,
          String? projectId,
          Value<String?> assignedToId = const Value.absent(),
          String? createdById,
          String? title,
          Value<String?> description = const Value.absent(),
          String? status,
          String? priority,
          int? progress,
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> completedDate = const Value.absent(),
          Value<double?> estimatedHours = const Value.absent(),
          double? actualHours,
          bool? isDirty,
          bool? isDeleted,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          DateTime? localUpdatedAt}) =>
      TaskEntity(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        assignedToId:
            assignedToId.present ? assignedToId.value : this.assignedToId,
        createdById: createdById ?? this.createdById,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        progress: progress ?? this.progress,
        startDate: startDate.present ? startDate.value : this.startDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        completedDate:
            completedDate.present ? completedDate.value : this.completedDate,
        estimatedHours:
            estimatedHours.present ? estimatedHours.value : this.estimatedHours,
        actualHours: actualHours ?? this.actualHours,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  TaskEntity copyWithCompanion(TasksCompanion data) {
    return TaskEntity(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      assignedToId: data.assignedToId.present
          ? data.assignedToId.value
          : this.assignedToId,
      createdById:
          data.createdById.present ? data.createdById.value : this.createdById,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      progress: data.progress.present ? data.progress.value : this.progress,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      estimatedHours: data.estimatedHours.present
          ? data.estimatedHours.value
          : this.estimatedHours,
      actualHours:
          data.actualHours.present ? data.actualHours.value : this.actualHours,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntity(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('assignedToId: $assignedToId, ')
          ..write('createdById: $createdById, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('progress: $progress, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('actualHours: $actualHours, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      assignedToId,
      createdById,
      title,
      description,
      status,
      priority,
      progress,
      startDate,
      dueDate,
      completedDate,
      estimatedHours,
      actualHours,
      isDirty,
      isDeleted,
      createdAt,
      updatedAt,
      localUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntity &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.assignedToId == this.assignedToId &&
          other.createdById == this.createdById &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.progress == this.progress &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
          other.completedDate == this.completedDate &&
          other.estimatedHours == this.estimatedHours &&
          other.actualHours == this.actualHours &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskEntity> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> assignedToId;
  final Value<String> createdById;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<String> priority;
  final Value<int> progress;
  final Value<DateTime?> startDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> completedDate;
  final Value<double?> estimatedHours;
  final Value<double> actualHours;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> localUpdatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.assignedToId = const Value.absent(),
    this.createdById = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.progress = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.actualHours = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String projectId,
    this.assignedToId = const Value.absent(),
    required String createdById,
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.progress = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.actualHours = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        createdById = Value(createdById),
        title = Value(title);
  static Insertable<TaskEntity> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? assignedToId,
    Expression<String>? createdById,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<int>? progress,
    Expression<DateTime>? startDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? completedDate,
    Expression<double>? estimatedHours,
    Expression<double>? actualHours,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (assignedToId != null) 'assigned_to_id': assignedToId,
      if (createdById != null) 'created_by_id': createdById,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (progress != null) 'progress': progress,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (actualHours != null) 'actual_hours': actualHours,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? assignedToId,
      Value<String>? createdById,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? status,
      Value<String>? priority,
      Value<int>? progress,
      Value<DateTime?>? startDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? completedDate,
      Value<double?>? estimatedHours,
      Value<double>? actualHours,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<DateTime>? localUpdatedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      assignedToId: assignedToId ?? this.assignedToId,
      createdById: createdById ?? this.createdById,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (assignedToId.present) {
      map['assigned_to_id'] = Variable<String>(assignedToId.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (estimatedHours.present) {
      map['estimated_hours'] = Variable<double>(estimatedHours.value);
    }
    if (actualHours.present) {
      map['actual_hours'] = Variable<double>(actualHours.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('assignedToId: $assignedToId, ')
          ..write('createdById: $createdById, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('progress: $progress, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('actualHours: $actualHours, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks
    with TableInfo<$SubtasksTable, SubtaskEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdByIdMeta =
      const VerificationMeta('createdById');
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
      'created_by_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        description,
        isCompleted,
        createdById,
        isDirty,
        isDeleted,
        createdAt,
        updatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(Insertable<SubtaskEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
          _createdByIdMeta,
          createdById.isAcceptableOrUnknown(
              data['created_by_id']!, _createdByIdMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtaskEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtaskEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by_id']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class SubtaskEntity extends DataClass implements Insertable<SubtaskEntity> {
  final String id;
  final String taskId;
  final String description;
  final bool isCompleted;
  final String? createdById;
  final bool isDirty;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime localUpdatedAt;
  const SubtaskEntity(
      {required this.id,
      required this.taskId,
      required this.description,
      required this.isCompleted,
      this.createdById,
      required this.isDirty,
      required this.isDeleted,
      required this.createdAt,
      this.updatedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['description'] = Variable<String>(description);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || createdById != null) {
      map['created_by_id'] = Variable<String>(createdById);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      description: Value(description),
      isCompleted: Value(isCompleted),
      createdById: createdById == null && nullToAbsent
          ? const Value.absent()
          : Value(createdById),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory SubtaskEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtaskEntity(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      description: serializer.fromJson<String>(json['description']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdById: serializer.fromJson<String?>(json['createdById']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'description': serializer.toJson<String>(description),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdById': serializer.toJson<String?>(createdById),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  SubtaskEntity copyWith(
          {String? id,
          String? taskId,
          String? description,
          bool? isCompleted,
          Value<String?> createdById = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          DateTime? localUpdatedAt}) =>
      SubtaskEntity(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        createdById: createdById.present ? createdById.value : this.createdById,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  SubtaskEntity copyWithCompanion(SubtasksCompanion data) {
    return SubtaskEntity(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      description:
          data.description.present ? data.description.value : this.description,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdById:
          data.createdById.present ? data.createdById.value : this.createdById,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubtaskEntity(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdById: $createdById, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, description, isCompleted,
      createdById, isDirty, isDeleted, createdAt, updatedAt, localUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubtaskEntity &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.description == this.description &&
          other.isCompleted == this.isCompleted &&
          other.createdById == this.createdById &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class SubtasksCompanion extends UpdateCompanion<SubtaskEntity> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> description;
  final Value<bool> isCompleted;
  final Value<String?> createdById;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> localUpdatedAt;
  final Value<int> rowid;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdById = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtasksCompanion.insert({
    required String id,
    required String taskId,
    required String description,
    this.isCompleted = const Value.absent(),
    this.createdById = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        description = Value(description);
  static Insertable<SubtaskEntity> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? description,
    Expression<bool>? isCompleted,
    Expression<String>? createdById,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (description != null) 'description': description,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdById != null) 'created_by_id': createdById,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? description,
      Value<bool>? isCompleted,
      Value<String?>? createdById,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<DateTime>? localUpdatedAt,
      Value<int>? rowid}) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdById: createdById ?? this.createdById,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdById: $createdById, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyProgressReportsTable extends DailyProgressReports
    with TableInfo<$DailyProgressReportsTable, DPREntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyProgressReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reportNoMeta =
      const VerificationMeta('reportNo');
  @override
  late final GeneratedColumn<String> reportNo = GeneratedColumn<String>(
      'report_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preparedByIdMeta =
      const VerificationMeta('preparedById');
  @override
  late final GeneratedColumn<String> preparedById = GeneratedColumn<String>(
      'prepared_by_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _workDescriptionMeta =
      const VerificationMeta('workDescription');
  @override
  late final GeneratedColumn<String> workDescription = GeneratedColumn<String>(
      'work_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weatherMeta =
      const VerificationMeta('weather');
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
      'weather', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<String> temperature = GeneratedColumn<String>(
      'temperature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _humidityMeta =
      const VerificationMeta('humidity');
  @override
  late final GeneratedColumn<String> humidity = GeneratedColumn<String>(
      'humidity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedWorkMeta =
      const VerificationMeta('completedWork');
  @override
  late final GeneratedColumn<String> completedWork = GeneratedColumn<String>(
      'completed_work', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingWorkMeta =
      const VerificationMeta('pendingWork');
  @override
  late final GeneratedColumn<String> pendingWork = GeneratedColumn<String>(
      'pending_work', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _challengesMeta =
      const VerificationMeta('challenges');
  @override
  late final GeneratedColumn<String> challenges = GeneratedColumn<String>(
      'challenges', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalWorkersMeta =
      const VerificationMeta('totalWorkers');
  @override
  late final GeneratedColumn<int> totalWorkers = GeneratedColumn<int>(
      'total_workers', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _supervisorPresentMeta =
      const VerificationMeta('supervisorPresent');
  @override
  late final GeneratedColumn<bool> supervisorPresent = GeneratedColumn<bool>(
      'supervisor_present', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("supervisor_present" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _equipmentUsedMeta =
      const VerificationMeta('equipmentUsed');
  @override
  late final GeneratedColumn<String> equipmentUsed = GeneratedColumn<String>(
      'equipment_used', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsUsedMeta =
      const VerificationMeta('materialsUsed');
  @override
  late final GeneratedColumn<String> materialsUsed = GeneratedColumn<String>(
      'materials_used', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsReceivedMeta =
      const VerificationMeta('materialsReceived');
  @override
  late final GeneratedColumn<String> materialsReceived =
      GeneratedColumn<String>('materials_received', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsRequiredMeta =
      const VerificationMeta('materialsRequired');
  @override
  late final GeneratedColumn<String> materialsRequired =
      GeneratedColumn<String>('materials_required', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _safetyObservationsMeta =
      const VerificationMeta('safetyObservations');
  @override
  late final GeneratedColumn<String> safetyObservations =
      GeneratedColumn<String>('safety_observations', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _incidentsMeta =
      const VerificationMeta('incidents');
  @override
  late final GeneratedColumn<String> incidents = GeneratedColumn<String>(
      'incidents', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _qualityChecksMeta =
      const VerificationMeta('qualityChecks');
  @override
  late final GeneratedColumn<String> qualityChecks = GeneratedColumn<String>(
      'quality_checks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issuesFoundMeta =
      const VerificationMeta('issuesFound');
  @override
  late final GeneratedColumn<String> issuesFound = GeneratedColumn<String>(
      'issues_found', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextDayPlanMeta =
      const VerificationMeta('nextDayPlan');
  @override
  late final GeneratedColumn<String> nextDayPlan = GeneratedColumn<String>(
      'next_day_plan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('TODO'));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        reportNo,
        preparedById,
        date,
        workDescription,
        weather,
        temperature,
        humidity,
        completedWork,
        pendingWork,
        challenges,
        totalWorkers,
        supervisorPresent,
        equipmentUsed,
        materialsUsed,
        materialsReceived,
        materialsRequired,
        safetyObservations,
        incidents,
        qualityChecks,
        issuesFound,
        nextDayPlan,
        status,
        isSynced,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_progress_reports';
  @override
  VerificationContext validateIntegrity(Insertable<DPREntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('report_no')) {
      context.handle(_reportNoMeta,
          reportNo.isAcceptableOrUnknown(data['report_no']!, _reportNoMeta));
    } else if (isInserting) {
      context.missing(_reportNoMeta);
    }
    if (data.containsKey('prepared_by_id')) {
      context.handle(
          _preparedByIdMeta,
          preparedById.isAcceptableOrUnknown(
              data['prepared_by_id']!, _preparedByIdMeta));
    } else if (isInserting) {
      context.missing(_preparedByIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('work_description')) {
      context.handle(
          _workDescriptionMeta,
          workDescription.isAcceptableOrUnknown(
              data['work_description']!, _workDescriptionMeta));
    } else if (isInserting) {
      context.missing(_workDescriptionMeta);
    }
    if (data.containsKey('weather')) {
      context.handle(_weatherMeta,
          weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('humidity')) {
      context.handle(_humidityMeta,
          humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta));
    }
    if (data.containsKey('completed_work')) {
      context.handle(
          _completedWorkMeta,
          completedWork.isAcceptableOrUnknown(
              data['completed_work']!, _completedWorkMeta));
    }
    if (data.containsKey('pending_work')) {
      context.handle(
          _pendingWorkMeta,
          pendingWork.isAcceptableOrUnknown(
              data['pending_work']!, _pendingWorkMeta));
    }
    if (data.containsKey('challenges')) {
      context.handle(
          _challengesMeta,
          challenges.isAcceptableOrUnknown(
              data['challenges']!, _challengesMeta));
    }
    if (data.containsKey('total_workers')) {
      context.handle(
          _totalWorkersMeta,
          totalWorkers.isAcceptableOrUnknown(
              data['total_workers']!, _totalWorkersMeta));
    }
    if (data.containsKey('supervisor_present')) {
      context.handle(
          _supervisorPresentMeta,
          supervisorPresent.isAcceptableOrUnknown(
              data['supervisor_present']!, _supervisorPresentMeta));
    }
    if (data.containsKey('equipment_used')) {
      context.handle(
          _equipmentUsedMeta,
          equipmentUsed.isAcceptableOrUnknown(
              data['equipment_used']!, _equipmentUsedMeta));
    }
    if (data.containsKey('materials_used')) {
      context.handle(
          _materialsUsedMeta,
          materialsUsed.isAcceptableOrUnknown(
              data['materials_used']!, _materialsUsedMeta));
    }
    if (data.containsKey('materials_received')) {
      context.handle(
          _materialsReceivedMeta,
          materialsReceived.isAcceptableOrUnknown(
              data['materials_received']!, _materialsReceivedMeta));
    }
    if (data.containsKey('materials_required')) {
      context.handle(
          _materialsRequiredMeta,
          materialsRequired.isAcceptableOrUnknown(
              data['materials_required']!, _materialsRequiredMeta));
    }
    if (data.containsKey('safety_observations')) {
      context.handle(
          _safetyObservationsMeta,
          safetyObservations.isAcceptableOrUnknown(
              data['safety_observations']!, _safetyObservationsMeta));
    }
    if (data.containsKey('incidents')) {
      context.handle(_incidentsMeta,
          incidents.isAcceptableOrUnknown(data['incidents']!, _incidentsMeta));
    }
    if (data.containsKey('quality_checks')) {
      context.handle(
          _qualityChecksMeta,
          qualityChecks.isAcceptableOrUnknown(
              data['quality_checks']!, _qualityChecksMeta));
    }
    if (data.containsKey('issues_found')) {
      context.handle(
          _issuesFoundMeta,
          issuesFound.isAcceptableOrUnknown(
              data['issues_found']!, _issuesFoundMeta));
    }
    if (data.containsKey('next_day_plan')) {
      context.handle(
          _nextDayPlanMeta,
          nextDayPlan.isAcceptableOrUnknown(
              data['next_day_plan']!, _nextDayPlanMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DPREntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DPREntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      reportNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_no'])!,
      preparedById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prepared_by_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      workDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}work_description'])!,
      weather: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weather']),
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}temperature']),
      humidity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}humidity']),
      completedWork: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_work']),
      pendingWork: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pending_work']),
      challenges: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}challenges']),
      totalWorkers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_workers'])!,
      supervisorPresent: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}supervisor_present'])!,
      equipmentUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment_used']),
      materialsUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}materials_used']),
      materialsReceived: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}materials_received']),
      materialsRequired: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}materials_required']),
      safetyObservations: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}safety_observations']),
      incidents: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}incidents']),
      qualityChecks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quality_checks']),
      issuesFound: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issues_found']),
      nextDayPlan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_day_plan']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $DailyProgressReportsTable createAlias(String alias) {
    return $DailyProgressReportsTable(attachedDatabase, alias);
  }
}

class DPREntity extends DataClass implements Insertable<DPREntity> {
  final String id;
  final String projectId;
  final String reportNo;
  final String preparedById;
  final DateTime date;
  final String workDescription;
  final String? weather;
  final String? temperature;
  final String? humidity;
  final String? completedWork;
  final String? pendingWork;
  final String? challenges;
  final int totalWorkers;
  final bool supervisorPresent;
  final String? equipmentUsed;
  final String? materialsUsed;
  final String? materialsReceived;
  final String? materialsRequired;
  final String? safetyObservations;
  final String? incidents;
  final String? qualityChecks;
  final String? issuesFound;
  final String? nextDayPlan;
  final String status;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const DPREntity(
      {required this.id,
      required this.projectId,
      required this.reportNo,
      required this.preparedById,
      required this.date,
      required this.workDescription,
      this.weather,
      this.temperature,
      this.humidity,
      this.completedWork,
      this.pendingWork,
      this.challenges,
      required this.totalWorkers,
      required this.supervisorPresent,
      this.equipmentUsed,
      this.materialsUsed,
      this.materialsReceived,
      this.materialsRequired,
      this.safetyObservations,
      this.incidents,
      this.qualityChecks,
      this.issuesFound,
      this.nextDayPlan,
      required this.status,
      required this.isSynced,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['report_no'] = Variable<String>(reportNo);
    map['prepared_by_id'] = Variable<String>(preparedById);
    map['date'] = Variable<DateTime>(date);
    map['work_description'] = Variable<String>(workDescription);
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<String>(temperature);
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<String>(humidity);
    }
    if (!nullToAbsent || completedWork != null) {
      map['completed_work'] = Variable<String>(completedWork);
    }
    if (!nullToAbsent || pendingWork != null) {
      map['pending_work'] = Variable<String>(pendingWork);
    }
    if (!nullToAbsent || challenges != null) {
      map['challenges'] = Variable<String>(challenges);
    }
    map['total_workers'] = Variable<int>(totalWorkers);
    map['supervisor_present'] = Variable<bool>(supervisorPresent);
    if (!nullToAbsent || equipmentUsed != null) {
      map['equipment_used'] = Variable<String>(equipmentUsed);
    }
    if (!nullToAbsent || materialsUsed != null) {
      map['materials_used'] = Variable<String>(materialsUsed);
    }
    if (!nullToAbsent || materialsReceived != null) {
      map['materials_received'] = Variable<String>(materialsReceived);
    }
    if (!nullToAbsent || materialsRequired != null) {
      map['materials_required'] = Variable<String>(materialsRequired);
    }
    if (!nullToAbsent || safetyObservations != null) {
      map['safety_observations'] = Variable<String>(safetyObservations);
    }
    if (!nullToAbsent || incidents != null) {
      map['incidents'] = Variable<String>(incidents);
    }
    if (!nullToAbsent || qualityChecks != null) {
      map['quality_checks'] = Variable<String>(qualityChecks);
    }
    if (!nullToAbsent || issuesFound != null) {
      map['issues_found'] = Variable<String>(issuesFound);
    }
    if (!nullToAbsent || nextDayPlan != null) {
      map['next_day_plan'] = Variable<String>(nextDayPlan);
    }
    map['status'] = Variable<String>(status);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  DailyProgressReportsCompanion toCompanion(bool nullToAbsent) {
    return DailyProgressReportsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      reportNo: Value(reportNo),
      preparedById: Value(preparedById),
      date: Value(date),
      workDescription: Value(workDescription),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      completedWork: completedWork == null && nullToAbsent
          ? const Value.absent()
          : Value(completedWork),
      pendingWork: pendingWork == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingWork),
      challenges: challenges == null && nullToAbsent
          ? const Value.absent()
          : Value(challenges),
      totalWorkers: Value(totalWorkers),
      supervisorPresent: Value(supervisorPresent),
      equipmentUsed: equipmentUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentUsed),
      materialsUsed: materialsUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsUsed),
      materialsReceived: materialsReceived == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsReceived),
      materialsRequired: materialsRequired == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsRequired),
      safetyObservations: safetyObservations == null && nullToAbsent
          ? const Value.absent()
          : Value(safetyObservations),
      incidents: incidents == null && nullToAbsent
          ? const Value.absent()
          : Value(incidents),
      qualityChecks: qualityChecks == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityChecks),
      issuesFound: issuesFound == null && nullToAbsent
          ? const Value.absent()
          : Value(issuesFound),
      nextDayPlan: nextDayPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDayPlan),
      status: Value(status),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DPREntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DPREntity(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      reportNo: serializer.fromJson<String>(json['reportNo']),
      preparedById: serializer.fromJson<String>(json['preparedById']),
      date: serializer.fromJson<DateTime>(json['date']),
      workDescription: serializer.fromJson<String>(json['workDescription']),
      weather: serializer.fromJson<String?>(json['weather']),
      temperature: serializer.fromJson<String?>(json['temperature']),
      humidity: serializer.fromJson<String?>(json['humidity']),
      completedWork: serializer.fromJson<String?>(json['completedWork']),
      pendingWork: serializer.fromJson<String?>(json['pendingWork']),
      challenges: serializer.fromJson<String?>(json['challenges']),
      totalWorkers: serializer.fromJson<int>(json['totalWorkers']),
      supervisorPresent: serializer.fromJson<bool>(json['supervisorPresent']),
      equipmentUsed: serializer.fromJson<String?>(json['equipmentUsed']),
      materialsUsed: serializer.fromJson<String?>(json['materialsUsed']),
      materialsReceived:
          serializer.fromJson<String?>(json['materialsReceived']),
      materialsRequired:
          serializer.fromJson<String?>(json['materialsRequired']),
      safetyObservations:
          serializer.fromJson<String?>(json['safetyObservations']),
      incidents: serializer.fromJson<String?>(json['incidents']),
      qualityChecks: serializer.fromJson<String?>(json['qualityChecks']),
      issuesFound: serializer.fromJson<String?>(json['issuesFound']),
      nextDayPlan: serializer.fromJson<String?>(json['nextDayPlan']),
      status: serializer.fromJson<String>(json['status']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'reportNo': serializer.toJson<String>(reportNo),
      'preparedById': serializer.toJson<String>(preparedById),
      'date': serializer.toJson<DateTime>(date),
      'workDescription': serializer.toJson<String>(workDescription),
      'weather': serializer.toJson<String?>(weather),
      'temperature': serializer.toJson<String?>(temperature),
      'humidity': serializer.toJson<String?>(humidity),
      'completedWork': serializer.toJson<String?>(completedWork),
      'pendingWork': serializer.toJson<String?>(pendingWork),
      'challenges': serializer.toJson<String?>(challenges),
      'totalWorkers': serializer.toJson<int>(totalWorkers),
      'supervisorPresent': serializer.toJson<bool>(supervisorPresent),
      'equipmentUsed': serializer.toJson<String?>(equipmentUsed),
      'materialsUsed': serializer.toJson<String?>(materialsUsed),
      'materialsReceived': serializer.toJson<String?>(materialsReceived),
      'materialsRequired': serializer.toJson<String?>(materialsRequired),
      'safetyObservations': serializer.toJson<String?>(safetyObservations),
      'incidents': serializer.toJson<String?>(incidents),
      'qualityChecks': serializer.toJson<String?>(qualityChecks),
      'issuesFound': serializer.toJson<String?>(issuesFound),
      'nextDayPlan': serializer.toJson<String?>(nextDayPlan),
      'status': serializer.toJson<String>(status),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DPREntity copyWith(
          {String? id,
          String? projectId,
          String? reportNo,
          String? preparedById,
          DateTime? date,
          String? workDescription,
          Value<String?> weather = const Value.absent(),
          Value<String?> temperature = const Value.absent(),
          Value<String?> humidity = const Value.absent(),
          Value<String?> completedWork = const Value.absent(),
          Value<String?> pendingWork = const Value.absent(),
          Value<String?> challenges = const Value.absent(),
          int? totalWorkers,
          bool? supervisorPresent,
          Value<String?> equipmentUsed = const Value.absent(),
          Value<String?> materialsUsed = const Value.absent(),
          Value<String?> materialsReceived = const Value.absent(),
          Value<String?> materialsRequired = const Value.absent(),
          Value<String?> safetyObservations = const Value.absent(),
          Value<String?> incidents = const Value.absent(),
          Value<String?> qualityChecks = const Value.absent(),
          Value<String?> issuesFound = const Value.absent(),
          Value<String?> nextDayPlan = const Value.absent(),
          String? status,
          bool? isSynced,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      DPREntity(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        reportNo: reportNo ?? this.reportNo,
        preparedById: preparedById ?? this.preparedById,
        date: date ?? this.date,
        workDescription: workDescription ?? this.workDescription,
        weather: weather.present ? weather.value : this.weather,
        temperature: temperature.present ? temperature.value : this.temperature,
        humidity: humidity.present ? humidity.value : this.humidity,
        completedWork:
            completedWork.present ? completedWork.value : this.completedWork,
        pendingWork: pendingWork.present ? pendingWork.value : this.pendingWork,
        challenges: challenges.present ? challenges.value : this.challenges,
        totalWorkers: totalWorkers ?? this.totalWorkers,
        supervisorPresent: supervisorPresent ?? this.supervisorPresent,
        equipmentUsed:
            equipmentUsed.present ? equipmentUsed.value : this.equipmentUsed,
        materialsUsed:
            materialsUsed.present ? materialsUsed.value : this.materialsUsed,
        materialsReceived: materialsReceived.present
            ? materialsReceived.value
            : this.materialsReceived,
        materialsRequired: materialsRequired.present
            ? materialsRequired.value
            : this.materialsRequired,
        safetyObservations: safetyObservations.present
            ? safetyObservations.value
            : this.safetyObservations,
        incidents: incidents.present ? incidents.value : this.incidents,
        qualityChecks:
            qualityChecks.present ? qualityChecks.value : this.qualityChecks,
        issuesFound: issuesFound.present ? issuesFound.value : this.issuesFound,
        nextDayPlan: nextDayPlan.present ? nextDayPlan.value : this.nextDayPlan,
        status: status ?? this.status,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  DPREntity copyWithCompanion(DailyProgressReportsCompanion data) {
    return DPREntity(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      reportNo: data.reportNo.present ? data.reportNo.value : this.reportNo,
      preparedById: data.preparedById.present
          ? data.preparedById.value
          : this.preparedById,
      date: data.date.present ? data.date.value : this.date,
      workDescription: data.workDescription.present
          ? data.workDescription.value
          : this.workDescription,
      weather: data.weather.present ? data.weather.value : this.weather,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      completedWork: data.completedWork.present
          ? data.completedWork.value
          : this.completedWork,
      pendingWork:
          data.pendingWork.present ? data.pendingWork.value : this.pendingWork,
      challenges:
          data.challenges.present ? data.challenges.value : this.challenges,
      totalWorkers: data.totalWorkers.present
          ? data.totalWorkers.value
          : this.totalWorkers,
      supervisorPresent: data.supervisorPresent.present
          ? data.supervisorPresent.value
          : this.supervisorPresent,
      equipmentUsed: data.equipmentUsed.present
          ? data.equipmentUsed.value
          : this.equipmentUsed,
      materialsUsed: data.materialsUsed.present
          ? data.materialsUsed.value
          : this.materialsUsed,
      materialsReceived: data.materialsReceived.present
          ? data.materialsReceived.value
          : this.materialsReceived,
      materialsRequired: data.materialsRequired.present
          ? data.materialsRequired.value
          : this.materialsRequired,
      safetyObservations: data.safetyObservations.present
          ? data.safetyObservations.value
          : this.safetyObservations,
      incidents: data.incidents.present ? data.incidents.value : this.incidents,
      qualityChecks: data.qualityChecks.present
          ? data.qualityChecks.value
          : this.qualityChecks,
      issuesFound:
          data.issuesFound.present ? data.issuesFound.value : this.issuesFound,
      nextDayPlan:
          data.nextDayPlan.present ? data.nextDayPlan.value : this.nextDayPlan,
      status: data.status.present ? data.status.value : this.status,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DPREntity(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('reportNo: $reportNo, ')
          ..write('preparedById: $preparedById, ')
          ..write('date: $date, ')
          ..write('workDescription: $workDescription, ')
          ..write('weather: $weather, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('completedWork: $completedWork, ')
          ..write('pendingWork: $pendingWork, ')
          ..write('challenges: $challenges, ')
          ..write('totalWorkers: $totalWorkers, ')
          ..write('supervisorPresent: $supervisorPresent, ')
          ..write('equipmentUsed: $equipmentUsed, ')
          ..write('materialsUsed: $materialsUsed, ')
          ..write('materialsReceived: $materialsReceived, ')
          ..write('materialsRequired: $materialsRequired, ')
          ..write('safetyObservations: $safetyObservations, ')
          ..write('incidents: $incidents, ')
          ..write('qualityChecks: $qualityChecks, ')
          ..write('issuesFound: $issuesFound, ')
          ..write('nextDayPlan: $nextDayPlan, ')
          ..write('status: $status, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        projectId,
        reportNo,
        preparedById,
        date,
        workDescription,
        weather,
        temperature,
        humidity,
        completedWork,
        pendingWork,
        challenges,
        totalWorkers,
        supervisorPresent,
        equipmentUsed,
        materialsUsed,
        materialsReceived,
        materialsRequired,
        safetyObservations,
        incidents,
        qualityChecks,
        issuesFound,
        nextDayPlan,
        status,
        isSynced,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DPREntity &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.reportNo == this.reportNo &&
          other.preparedById == this.preparedById &&
          other.date == this.date &&
          other.workDescription == this.workDescription &&
          other.weather == this.weather &&
          other.temperature == this.temperature &&
          other.humidity == this.humidity &&
          other.completedWork == this.completedWork &&
          other.pendingWork == this.pendingWork &&
          other.challenges == this.challenges &&
          other.totalWorkers == this.totalWorkers &&
          other.supervisorPresent == this.supervisorPresent &&
          other.equipmentUsed == this.equipmentUsed &&
          other.materialsUsed == this.materialsUsed &&
          other.materialsReceived == this.materialsReceived &&
          other.materialsRequired == this.materialsRequired &&
          other.safetyObservations == this.safetyObservations &&
          other.incidents == this.incidents &&
          other.qualityChecks == this.qualityChecks &&
          other.issuesFound == this.issuesFound &&
          other.nextDayPlan == this.nextDayPlan &&
          other.status == this.status &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyProgressReportsCompanion extends UpdateCompanion<DPREntity> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> reportNo;
  final Value<String> preparedById;
  final Value<DateTime> date;
  final Value<String> workDescription;
  final Value<String?> weather;
  final Value<String?> temperature;
  final Value<String?> humidity;
  final Value<String?> completedWork;
  final Value<String?> pendingWork;
  final Value<String?> challenges;
  final Value<int> totalWorkers;
  final Value<bool> supervisorPresent;
  final Value<String?> equipmentUsed;
  final Value<String?> materialsUsed;
  final Value<String?> materialsReceived;
  final Value<String?> materialsRequired;
  final Value<String?> safetyObservations;
  final Value<String?> incidents;
  final Value<String?> qualityChecks;
  final Value<String?> issuesFound;
  final Value<String?> nextDayPlan;
  final Value<String> status;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const DailyProgressReportsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.reportNo = const Value.absent(),
    this.preparedById = const Value.absent(),
    this.date = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.weather = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.completedWork = const Value.absent(),
    this.pendingWork = const Value.absent(),
    this.challenges = const Value.absent(),
    this.totalWorkers = const Value.absent(),
    this.supervisorPresent = const Value.absent(),
    this.equipmentUsed = const Value.absent(),
    this.materialsUsed = const Value.absent(),
    this.materialsReceived = const Value.absent(),
    this.materialsRequired = const Value.absent(),
    this.safetyObservations = const Value.absent(),
    this.incidents = const Value.absent(),
    this.qualityChecks = const Value.absent(),
    this.issuesFound = const Value.absent(),
    this.nextDayPlan = const Value.absent(),
    this.status = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyProgressReportsCompanion.insert({
    required String id,
    required String projectId,
    required String reportNo,
    required String preparedById,
    required DateTime date,
    required String workDescription,
    this.weather = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.completedWork = const Value.absent(),
    this.pendingWork = const Value.absent(),
    this.challenges = const Value.absent(),
    this.totalWorkers = const Value.absent(),
    this.supervisorPresent = const Value.absent(),
    this.equipmentUsed = const Value.absent(),
    this.materialsUsed = const Value.absent(),
    this.materialsReceived = const Value.absent(),
    this.materialsRequired = const Value.absent(),
    this.safetyObservations = const Value.absent(),
    this.incidents = const Value.absent(),
    this.qualityChecks = const Value.absent(),
    this.issuesFound = const Value.absent(),
    this.nextDayPlan = const Value.absent(),
    this.status = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        reportNo = Value(reportNo),
        preparedById = Value(preparedById),
        date = Value(date),
        workDescription = Value(workDescription);
  static Insertable<DPREntity> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? reportNo,
    Expression<String>? preparedById,
    Expression<DateTime>? date,
    Expression<String>? workDescription,
    Expression<String>? weather,
    Expression<String>? temperature,
    Expression<String>? humidity,
    Expression<String>? completedWork,
    Expression<String>? pendingWork,
    Expression<String>? challenges,
    Expression<int>? totalWorkers,
    Expression<bool>? supervisorPresent,
    Expression<String>? equipmentUsed,
    Expression<String>? materialsUsed,
    Expression<String>? materialsReceived,
    Expression<String>? materialsRequired,
    Expression<String>? safetyObservations,
    Expression<String>? incidents,
    Expression<String>? qualityChecks,
    Expression<String>? issuesFound,
    Expression<String>? nextDayPlan,
    Expression<String>? status,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (reportNo != null) 'report_no': reportNo,
      if (preparedById != null) 'prepared_by_id': preparedById,
      if (date != null) 'date': date,
      if (workDescription != null) 'work_description': workDescription,
      if (weather != null) 'weather': weather,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (completedWork != null) 'completed_work': completedWork,
      if (pendingWork != null) 'pending_work': pendingWork,
      if (challenges != null) 'challenges': challenges,
      if (totalWorkers != null) 'total_workers': totalWorkers,
      if (supervisorPresent != null) 'supervisor_present': supervisorPresent,
      if (equipmentUsed != null) 'equipment_used': equipmentUsed,
      if (materialsUsed != null) 'materials_used': materialsUsed,
      if (materialsReceived != null) 'materials_received': materialsReceived,
      if (materialsRequired != null) 'materials_required': materialsRequired,
      if (safetyObservations != null) 'safety_observations': safetyObservations,
      if (incidents != null) 'incidents': incidents,
      if (qualityChecks != null) 'quality_checks': qualityChecks,
      if (issuesFound != null) 'issues_found': issuesFound,
      if (nextDayPlan != null) 'next_day_plan': nextDayPlan,
      if (status != null) 'status': status,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyProgressReportsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? reportNo,
      Value<String>? preparedById,
      Value<DateTime>? date,
      Value<String>? workDescription,
      Value<String?>? weather,
      Value<String?>? temperature,
      Value<String?>? humidity,
      Value<String?>? completedWork,
      Value<String?>? pendingWork,
      Value<String?>? challenges,
      Value<int>? totalWorkers,
      Value<bool>? supervisorPresent,
      Value<String?>? equipmentUsed,
      Value<String?>? materialsUsed,
      Value<String?>? materialsReceived,
      Value<String?>? materialsRequired,
      Value<String?>? safetyObservations,
      Value<String?>? incidents,
      Value<String?>? qualityChecks,
      Value<String?>? issuesFound,
      Value<String?>? nextDayPlan,
      Value<String>? status,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return DailyProgressReportsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      reportNo: reportNo ?? this.reportNo,
      preparedById: preparedById ?? this.preparedById,
      date: date ?? this.date,
      workDescription: workDescription ?? this.workDescription,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      completedWork: completedWork ?? this.completedWork,
      pendingWork: pendingWork ?? this.pendingWork,
      challenges: challenges ?? this.challenges,
      totalWorkers: totalWorkers ?? this.totalWorkers,
      supervisorPresent: supervisorPresent ?? this.supervisorPresent,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      materialsReceived: materialsReceived ?? this.materialsReceived,
      materialsRequired: materialsRequired ?? this.materialsRequired,
      safetyObservations: safetyObservations ?? this.safetyObservations,
      incidents: incidents ?? this.incidents,
      qualityChecks: qualityChecks ?? this.qualityChecks,
      issuesFound: issuesFound ?? this.issuesFound,
      nextDayPlan: nextDayPlan ?? this.nextDayPlan,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (reportNo.present) {
      map['report_no'] = Variable<String>(reportNo.value);
    }
    if (preparedById.present) {
      map['prepared_by_id'] = Variable<String>(preparedById.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (workDescription.present) {
      map['work_description'] = Variable<String>(workDescription.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<String>(temperature.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<String>(humidity.value);
    }
    if (completedWork.present) {
      map['completed_work'] = Variable<String>(completedWork.value);
    }
    if (pendingWork.present) {
      map['pending_work'] = Variable<String>(pendingWork.value);
    }
    if (challenges.present) {
      map['challenges'] = Variable<String>(challenges.value);
    }
    if (totalWorkers.present) {
      map['total_workers'] = Variable<int>(totalWorkers.value);
    }
    if (supervisorPresent.present) {
      map['supervisor_present'] = Variable<bool>(supervisorPresent.value);
    }
    if (equipmentUsed.present) {
      map['equipment_used'] = Variable<String>(equipmentUsed.value);
    }
    if (materialsUsed.present) {
      map['materials_used'] = Variable<String>(materialsUsed.value);
    }
    if (materialsReceived.present) {
      map['materials_received'] = Variable<String>(materialsReceived.value);
    }
    if (materialsRequired.present) {
      map['materials_required'] = Variable<String>(materialsRequired.value);
    }
    if (safetyObservations.present) {
      map['safety_observations'] = Variable<String>(safetyObservations.value);
    }
    if (incidents.present) {
      map['incidents'] = Variable<String>(incidents.value);
    }
    if (qualityChecks.present) {
      map['quality_checks'] = Variable<String>(qualityChecks.value);
    }
    if (issuesFound.present) {
      map['issues_found'] = Variable<String>(issuesFound.value);
    }
    if (nextDayPlan.present) {
      map['next_day_plan'] = Variable<String>(nextDayPlan.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyProgressReportsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('reportNo: $reportNo, ')
          ..write('preparedById: $preparedById, ')
          ..write('date: $date, ')
          ..write('workDescription: $workDescription, ')
          ..write('weather: $weather, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('completedWork: $completedWork, ')
          ..write('pendingWork: $pendingWork, ')
          ..write('challenges: $challenges, ')
          ..write('totalWorkers: $totalWorkers, ')
          ..write('supervisorPresent: $supervisorPresent, ')
          ..write('equipmentUsed: $equipmentUsed, ')
          ..write('materialsUsed: $materialsUsed, ')
          ..write('materialsReceived: $materialsReceived, ')
          ..write('materialsRequired: $materialsRequired, ')
          ..write('safetyObservations: $safetyObservations, ')
          ..write('incidents: $incidents, ')
          ..write('qualityChecks: $qualityChecks, ')
          ..write('issuesFound: $issuesFound, ')
          ..write('nextDayPlan: $nextDayPlan, ')
          ..write('status: $status, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DprPhotosTable extends DprPhotos
    with TableInfo<$DprPhotosTable, DPRPhotoEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DprPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dprIdMeta = const VerificationMeta('dprId');
  @override
  late final GeneratedColumn<String> dprId = GeneratedColumn<String>(
      'dpr_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES daily_progress_reports (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uploadedByIdMeta =
      const VerificationMeta('uploadedById');
  @override
  late final GeneratedColumn<String> uploadedById = GeneratedColumn<String>(
      'uploaded_by_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dprId,
        title,
        description,
        localPath,
        imageUrl,
        thumbnailUrl,
        uploadedById,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dpr_photos';
  @override
  VerificationContext validateIntegrity(Insertable<DPRPhotoEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dpr_id')) {
      context.handle(
          _dprIdMeta, dprId.isAcceptableOrUnknown(data['dpr_id']!, _dprIdMeta));
    } else if (isInserting) {
      context.missing(_dprIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('uploaded_by_id')) {
      context.handle(
          _uploadedByIdMeta,
          uploadedById.isAcceptableOrUnknown(
              data['uploaded_by_id']!, _uploadedByIdMeta));
    } else if (isInserting) {
      context.missing(_uploadedByIdMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DPRPhotoEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DPRPhotoEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dprId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dpr_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      uploadedById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uploaded_by_id'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DprPhotosTable createAlias(String alias) {
    return $DprPhotosTable(attachedDatabase, alias);
  }
}

class DPRPhotoEntity extends DataClass implements Insertable<DPRPhotoEntity> {
  final String id;
  final String dprId;
  final String? title;
  final String? description;
  final String? localPath;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String uploadedById;
  final bool isSynced;
  final DateTime createdAt;
  const DPRPhotoEntity(
      {required this.id,
      required this.dprId,
      this.title,
      this.description,
      this.localPath,
      this.imageUrl,
      this.thumbnailUrl,
      required this.uploadedById,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dpr_id'] = Variable<String>(dprId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['uploaded_by_id'] = Variable<String>(uploadedById);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DprPhotosCompanion toCompanion(bool nullToAbsent) {
    return DprPhotosCompanion(
      id: Value(id),
      dprId: Value(dprId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      uploadedById: Value(uploadedById),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory DPRPhotoEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DPRPhotoEntity(
      id: serializer.fromJson<String>(json['id']),
      dprId: serializer.fromJson<String>(json['dprId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      uploadedById: serializer.fromJson<String>(json['uploadedById']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dprId': serializer.toJson<String>(dprId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'localPath': serializer.toJson<String?>(localPath),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'uploadedById': serializer.toJson<String>(uploadedById),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DPRPhotoEntity copyWith(
          {String? id,
          String? dprId,
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          String? uploadedById,
          bool? isSynced,
          DateTime? createdAt}) =>
      DPRPhotoEntity(
        id: id ?? this.id,
        dprId: dprId ?? this.dprId,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        localPath: localPath.present ? localPath.value : this.localPath,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        uploadedById: uploadedById ?? this.uploadedById,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  DPRPhotoEntity copyWithCompanion(DprPhotosCompanion data) {
    return DPRPhotoEntity(
      id: data.id.present ? data.id.value : this.id,
      dprId: data.dprId.present ? data.dprId.value : this.dprId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      uploadedById: data.uploadedById.present
          ? data.uploadedById.value
          : this.uploadedById,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DPRPhotoEntity(')
          ..write('id: $id, ')
          ..write('dprId: $dprId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('localPath: $localPath, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('uploadedById: $uploadedById, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dprId, title, description, localPath,
      imageUrl, thumbnailUrl, uploadedById, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DPRPhotoEntity &&
          other.id == this.id &&
          other.dprId == this.dprId &&
          other.title == this.title &&
          other.description == this.description &&
          other.localPath == this.localPath &&
          other.imageUrl == this.imageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.uploadedById == this.uploadedById &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class DprPhotosCompanion extends UpdateCompanion<DPRPhotoEntity> {
  final Value<String> id;
  final Value<String> dprId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> localPath;
  final Value<String?> imageUrl;
  final Value<String?> thumbnailUrl;
  final Value<String> uploadedById;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DprPhotosCompanion({
    this.id = const Value.absent(),
    this.dprId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.localPath = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.uploadedById = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DprPhotosCompanion.insert({
    required String id,
    required String dprId,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.localPath = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    required String uploadedById,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dprId = Value(dprId),
        uploadedById = Value(uploadedById);
  static Insertable<DPRPhotoEntity> custom({
    Expression<String>? id,
    Expression<String>? dprId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? localPath,
    Expression<String>? imageUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? uploadedById,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dprId != null) 'dpr_id': dprId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (localPath != null) 'local_path': localPath,
      if (imageUrl != null) 'image_url': imageUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (uploadedById != null) 'uploaded_by_id': uploadedById,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DprPhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? dprId,
      Value<String?>? title,
      Value<String?>? description,
      Value<String?>? localPath,
      Value<String?>? imageUrl,
      Value<String?>? thumbnailUrl,
      Value<String>? uploadedById,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DprPhotosCompanion(
      id: id ?? this.id,
      dprId: dprId ?? this.dprId,
      title: title ?? this.title,
      description: description ?? this.description,
      localPath: localPath ?? this.localPath,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      uploadedById: uploadedById ?? this.uploadedById,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dprId.present) {
      map['dpr_id'] = Variable<String>(dprId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (uploadedById.present) {
      map['uploaded_by_id'] = Variable<String>(uploadedById.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DprPhotosCompanion(')
          ..write('id: $id, ')
          ..write('dprId: $dprId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('localPath: $localPath, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('uploadedById: $uploadedById, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRegistryTable extends SyncRegistry
    with TableInfo<$SyncRegistryTable, SyncRegistryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRegistryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [model, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_registry';
  @override
  VerificationContext validateIntegrity(Insertable<SyncRegistryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {model};
  @override
  SyncRegistryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRegistryData(
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SyncRegistryTable createAlias(String alias) {
    return $SyncRegistryTable(attachedDatabase, alias);
  }
}

class SyncRegistryData extends DataClass
    implements Insertable<SyncRegistryData> {
  final String model;
  final DateTime? lastSyncedAt;
  const SyncRegistryData({required this.model, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncRegistryCompanion toCompanion(bool nullToAbsent) {
    return SyncRegistryCompanion(
      model: Value(model),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncRegistryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRegistryData(
      model: serializer.fromJson<String>(json['model']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'model': serializer.toJson<String>(model),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncRegistryData copyWith(
          {String? model,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      SyncRegistryData(
        model: model ?? this.model,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SyncRegistryData copyWithCompanion(SyncRegistryCompanion data) {
    return SyncRegistryData(
      model: data.model.present ? data.model.value : this.model,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRegistryData(')
          ..write('model: $model, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(model, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRegistryData &&
          other.model == this.model &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncRegistryCompanion extends UpdateCompanion<SyncRegistryData> {
  final Value<String> model;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SyncRegistryCompanion({
    this.model = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRegistryCompanion.insert({
    required String model,
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : model = Value(model);
  static Insertable<SyncRegistryData> custom({
    Expression<String>? model,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (model != null) 'model': model,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRegistryCompanion copyWith(
      {Value<String>? model,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return SyncRegistryCompanion(
      model: model ?? this.model,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRegistryCompanion(')
          ..write('model: $model, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyIdMeta =
      const VerificationMeta('companyId');
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
      'company_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
      'role_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleNameMeta =
      const VerificationMeta('roleName');
  @override
  late final GeneratedColumn<String> roleName = GeneratedColumn<String>(
      'role_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
      'employee_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _designationMeta =
      const VerificationMeta('designation');
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
      'designation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePictureMeta =
      const VerificationMeta('profilePicture');
  @override
  late final GeneratedColumn<String> profilePicture = GeneratedColumn<String>(
      'profile_picture', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userTypeMeta =
      const VerificationMeta('userType');
  @override
  late final GeneratedColumn<String> userType = GeneratedColumn<String>(
      'user_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _employeeStatusMeta =
      const VerificationMeta('employeeStatus');
  @override
  late final GeneratedColumn<String> employeeStatus = GeneratedColumn<String>(
      'employee_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultLocationMeta =
      const VerificationMeta('defaultLocation');
  @override
  late final GeneratedColumn<String> defaultLocation = GeneratedColumn<String>(
      'default_location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _salaryTypeMeta =
      const VerificationMeta('salaryType');
  @override
  late final GeneratedColumn<String> salaryType = GeneratedColumn<String>(
      'salary_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSystemAdminMeta =
      const VerificationMeta('isSystemAdmin');
  @override
  late final GeneratedColumn<bool> isSystemAdmin = GeneratedColumn<bool>(
      'is_system_admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_system_admin" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      permissions = GeneratedColumn<String>('permissions', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>?>($UsersTable.$converterpermissionsn);
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
      'theme', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('light'));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _lastLoginMeta =
      const VerificationMeta('lastLogin');
  @override
  late final GeneratedColumn<DateTime> lastLogin = GeneratedColumn<DateTime>(
      'last_login', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        phone,
        companyId,
        companyName,
        roleId,
        roleName,
        employeeId,
        designation,
        department,
        profilePicture,
        userType,
        employeeStatus,
        defaultLocation,
        salaryType,
        isActive,
        createdAt,
        updatedAt,
        isSystemAdmin,
        permissions,
        theme,
        language,
        lastLogin
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(_companyIdMeta,
          companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta));
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('role_name')) {
      context.handle(_roleNameMeta,
          roleName.isAcceptableOrUnknown(data['role_name']!, _roleNameMeta));
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    }
    if (data.containsKey('designation')) {
      context.handle(
          _designationMeta,
          designation.isAcceptableOrUnknown(
              data['designation']!, _designationMeta));
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    }
    if (data.containsKey('profile_picture')) {
      context.handle(
          _profilePictureMeta,
          profilePicture.isAcceptableOrUnknown(
              data['profile_picture']!, _profilePictureMeta));
    }
    if (data.containsKey('user_type')) {
      context.handle(_userTypeMeta,
          userType.isAcceptableOrUnknown(data['user_type']!, _userTypeMeta));
    } else if (isInserting) {
      context.missing(_userTypeMeta);
    }
    if (data.containsKey('employee_status')) {
      context.handle(
          _employeeStatusMeta,
          employeeStatus.isAcceptableOrUnknown(
              data['employee_status']!, _employeeStatusMeta));
    } else if (isInserting) {
      context.missing(_employeeStatusMeta);
    }
    if (data.containsKey('default_location')) {
      context.handle(
          _defaultLocationMeta,
          defaultLocation.isAcceptableOrUnknown(
              data['default_location']!, _defaultLocationMeta));
    } else if (isInserting) {
      context.missing(_defaultLocationMeta);
    }
    if (data.containsKey('salary_type')) {
      context.handle(
          _salaryTypeMeta,
          salaryType.isAcceptableOrUnknown(
              data['salary_type']!, _salaryTypeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_system_admin')) {
      context.handle(
          _isSystemAdminMeta,
          isSystemAdmin.isAcceptableOrUnknown(
              data['is_system_admin']!, _isSystemAdminMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
          _themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('last_login')) {
      context.handle(_lastLoginMeta,
          lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      companyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_id']),
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name']),
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role_id'])!,
      roleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role_name']),
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}employee_id']),
      designation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}designation']),
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department']),
      profilePicture: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_picture']),
      userType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_type'])!,
      employeeStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}employee_status'])!,
      defaultLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_location'])!,
      salaryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salary_type']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSystemAdmin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system_admin'])!,
      permissions: $UsersTable.$converterpermissionsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}permissions'])),
      theme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      lastLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterpermissions =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterpermissionsn =
      NullAwareTypeConverter.wrap($converterpermissions);
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? companyId;
  final String? companyName;
  final String roleId;
  final String? roleName;
  final String? employeeId;
  final String? designation;
  final String? department;
  final String? profilePicture;
  final String userType;
  final String employeeStatus;
  final String defaultLocation;
  final String? salaryType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSystemAdmin;
  final List<String>? permissions;
  final String? theme;
  final String? language;
  final DateTime? lastLogin;
  const UserEntity(
      {required this.id,
      required this.name,
      this.email,
      required this.phone,
      this.companyId,
      this.companyName,
      required this.roleId,
      this.roleName,
      this.employeeId,
      this.designation,
      this.department,
      this.profilePicture,
      required this.userType,
      required this.employeeStatus,
      required this.defaultLocation,
      this.salaryType,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      required this.isSystemAdmin,
      this.permissions,
      this.theme,
      this.language,
      this.lastLogin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    if (!nullToAbsent || companyName != null) {
      map['company_name'] = Variable<String>(companyName);
    }
    map['role_id'] = Variable<String>(roleId);
    if (!nullToAbsent || roleName != null) {
      map['role_name'] = Variable<String>(roleName);
    }
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<String>(employeeId);
    }
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    if (!nullToAbsent || profilePicture != null) {
      map['profile_picture'] = Variable<String>(profilePicture);
    }
    map['user_type'] = Variable<String>(userType);
    map['employee_status'] = Variable<String>(employeeStatus);
    map['default_location'] = Variable<String>(defaultLocation);
    if (!nullToAbsent || salaryType != null) {
      map['salary_type'] = Variable<String>(salaryType);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_system_admin'] = Variable<bool>(isSystemAdmin);
    if (!nullToAbsent || permissions != null) {
      map['permissions'] = Variable<String>(
          $UsersTable.$converterpermissionsn.toSql(permissions));
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || lastLogin != null) {
      map['last_login'] = Variable<DateTime>(lastLogin);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone: Value(phone),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      companyName: companyName == null && nullToAbsent
          ? const Value.absent()
          : Value(companyName),
      roleId: Value(roleId),
      roleName: roleName == null && nullToAbsent
          ? const Value.absent()
          : Value(roleName),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
      profilePicture: profilePicture == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicture),
      userType: Value(userType),
      employeeStatus: Value(employeeStatus),
      defaultLocation: Value(defaultLocation),
      salaryType: salaryType == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryType),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSystemAdmin: Value(isSystemAdmin),
      permissions: permissions == null && nullToAbsent
          ? const Value.absent()
          : Value(permissions),
      theme:
          theme == null && nullToAbsent ? const Value.absent() : Value(theme),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      lastLogin: lastLogin == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogin),
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      companyId: serializer.fromJson<String?>(json['companyId']),
      companyName: serializer.fromJson<String?>(json['companyName']),
      roleId: serializer.fromJson<String>(json['roleId']),
      roleName: serializer.fromJson<String?>(json['roleName']),
      employeeId: serializer.fromJson<String?>(json['employeeId']),
      designation: serializer.fromJson<String?>(json['designation']),
      department: serializer.fromJson<String?>(json['department']),
      profilePicture: serializer.fromJson<String?>(json['profilePicture']),
      userType: serializer.fromJson<String>(json['userType']),
      employeeStatus: serializer.fromJson<String>(json['employeeStatus']),
      defaultLocation: serializer.fromJson<String>(json['defaultLocation']),
      salaryType: serializer.fromJson<String?>(json['salaryType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSystemAdmin: serializer.fromJson<bool>(json['isSystemAdmin']),
      permissions: serializer.fromJson<List<String>?>(json['permissions']),
      theme: serializer.fromJson<String?>(json['theme']),
      language: serializer.fromJson<String?>(json['language']),
      lastLogin: serializer.fromJson<DateTime?>(json['lastLogin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String>(phone),
      'companyId': serializer.toJson<String?>(companyId),
      'companyName': serializer.toJson<String?>(companyName),
      'roleId': serializer.toJson<String>(roleId),
      'roleName': serializer.toJson<String?>(roleName),
      'employeeId': serializer.toJson<String?>(employeeId),
      'designation': serializer.toJson<String?>(designation),
      'department': serializer.toJson<String?>(department),
      'profilePicture': serializer.toJson<String?>(profilePicture),
      'userType': serializer.toJson<String>(userType),
      'employeeStatus': serializer.toJson<String>(employeeStatus),
      'defaultLocation': serializer.toJson<String>(defaultLocation),
      'salaryType': serializer.toJson<String?>(salaryType),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSystemAdmin': serializer.toJson<bool>(isSystemAdmin),
      'permissions': serializer.toJson<List<String>?>(permissions),
      'theme': serializer.toJson<String?>(theme),
      'language': serializer.toJson<String?>(language),
      'lastLogin': serializer.toJson<DateTime?>(lastLogin),
    };
  }

  UserEntity copyWith(
          {String? id,
          String? name,
          Value<String?> email = const Value.absent(),
          String? phone,
          Value<String?> companyId = const Value.absent(),
          Value<String?> companyName = const Value.absent(),
          String? roleId,
          Value<String?> roleName = const Value.absent(),
          Value<String?> employeeId = const Value.absent(),
          Value<String?> designation = const Value.absent(),
          Value<String?> department = const Value.absent(),
          Value<String?> profilePicture = const Value.absent(),
          String? userType,
          String? employeeStatus,
          String? defaultLocation,
          Value<String?> salaryType = const Value.absent(),
          bool? isActive,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSystemAdmin,
          Value<List<String>?> permissions = const Value.absent(),
          Value<String?> theme = const Value.absent(),
          Value<String?> language = const Value.absent(),
          Value<DateTime?> lastLogin = const Value.absent()}) =>
      UserEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        phone: phone ?? this.phone,
        companyId: companyId.present ? companyId.value : this.companyId,
        companyName: companyName.present ? companyName.value : this.companyName,
        roleId: roleId ?? this.roleId,
        roleName: roleName.present ? roleName.value : this.roleName,
        employeeId: employeeId.present ? employeeId.value : this.employeeId,
        designation: designation.present ? designation.value : this.designation,
        department: department.present ? department.value : this.department,
        profilePicture:
            profilePicture.present ? profilePicture.value : this.profilePicture,
        userType: userType ?? this.userType,
        employeeStatus: employeeStatus ?? this.employeeStatus,
        defaultLocation: defaultLocation ?? this.defaultLocation,
        salaryType: salaryType.present ? salaryType.value : this.salaryType,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
        permissions: permissions.present ? permissions.value : this.permissions,
        theme: theme.present ? theme.value : this.theme,
        language: language.present ? language.value : this.language,
        lastLogin: lastLogin.present ? lastLogin.value : this.lastLogin,
      );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      roleName: data.roleName.present ? data.roleName.value : this.roleName,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      designation:
          data.designation.present ? data.designation.value : this.designation,
      department:
          data.department.present ? data.department.value : this.department,
      profilePicture: data.profilePicture.present
          ? data.profilePicture.value
          : this.profilePicture,
      userType: data.userType.present ? data.userType.value : this.userType,
      employeeStatus: data.employeeStatus.present
          ? data.employeeStatus.value
          : this.employeeStatus,
      defaultLocation: data.defaultLocation.present
          ? data.defaultLocation.value
          : this.defaultLocation,
      salaryType:
          data.salaryType.present ? data.salaryType.value : this.salaryType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSystemAdmin: data.isSystemAdmin.present
          ? data.isSystemAdmin.value
          : this.isSystemAdmin,
      permissions:
          data.permissions.present ? data.permissions.value : this.permissions,
      theme: data.theme.present ? data.theme.value : this.theme,
      language: data.language.present ? data.language.value : this.language,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('companyId: $companyId, ')
          ..write('companyName: $companyName, ')
          ..write('roleId: $roleId, ')
          ..write('roleName: $roleName, ')
          ..write('employeeId: $employeeId, ')
          ..write('designation: $designation, ')
          ..write('department: $department, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('userType: $userType, ')
          ..write('employeeStatus: $employeeStatus, ')
          ..write('defaultLocation: $defaultLocation, ')
          ..write('salaryType: $salaryType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystemAdmin: $isSystemAdmin, ')
          ..write('permissions: $permissions, ')
          ..write('theme: $theme, ')
          ..write('language: $language, ')
          ..write('lastLogin: $lastLogin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        email,
        phone,
        companyId,
        companyName,
        roleId,
        roleName,
        employeeId,
        designation,
        department,
        profilePicture,
        userType,
        employeeStatus,
        defaultLocation,
        salaryType,
        isActive,
        createdAt,
        updatedAt,
        isSystemAdmin,
        permissions,
        theme,
        language,
        lastLogin
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.companyId == this.companyId &&
          other.companyName == this.companyName &&
          other.roleId == this.roleId &&
          other.roleName == this.roleName &&
          other.employeeId == this.employeeId &&
          other.designation == this.designation &&
          other.department == this.department &&
          other.profilePicture == this.profilePicture &&
          other.userType == this.userType &&
          other.employeeStatus == this.employeeStatus &&
          other.defaultLocation == this.defaultLocation &&
          other.salaryType == this.salaryType &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSystemAdmin == this.isSystemAdmin &&
          other.permissions == this.permissions &&
          other.theme == this.theme &&
          other.language == this.language &&
          other.lastLogin == this.lastLogin);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String> phone;
  final Value<String?> companyId;
  final Value<String?> companyName;
  final Value<String> roleId;
  final Value<String?> roleName;
  final Value<String?> employeeId;
  final Value<String?> designation;
  final Value<String?> department;
  final Value<String?> profilePicture;
  final Value<String> userType;
  final Value<String> employeeStatus;
  final Value<String> defaultLocation;
  final Value<String?> salaryType;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSystemAdmin;
  final Value<List<String>?> permissions;
  final Value<String?> theme;
  final Value<String?> language;
  final Value<DateTime?> lastLogin;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.companyId = const Value.absent(),
    this.companyName = const Value.absent(),
    this.roleId = const Value.absent(),
    this.roleName = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.designation = const Value.absent(),
    this.department = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.userType = const Value.absent(),
    this.employeeStatus = const Value.absent(),
    this.defaultLocation = const Value.absent(),
    this.salaryType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSystemAdmin = const Value.absent(),
    this.permissions = const Value.absent(),
    this.theme = const Value.absent(),
    this.language = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    required String phone,
    this.companyId = const Value.absent(),
    this.companyName = const Value.absent(),
    required String roleId,
    this.roleName = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.designation = const Value.absent(),
    this.department = const Value.absent(),
    this.profilePicture = const Value.absent(),
    required String userType,
    required String employeeStatus,
    required String defaultLocation,
    this.salaryType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSystemAdmin = const Value.absent(),
    this.permissions = const Value.absent(),
    this.theme = const Value.absent(),
    this.language = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone),
        roleId = Value(roleId),
        userType = Value(userType),
        employeeStatus = Value(employeeStatus),
        defaultLocation = Value(defaultLocation);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? companyId,
    Expression<String>? companyName,
    Expression<String>? roleId,
    Expression<String>? roleName,
    Expression<String>? employeeId,
    Expression<String>? designation,
    Expression<String>? department,
    Expression<String>? profilePicture,
    Expression<String>? userType,
    Expression<String>? employeeStatus,
    Expression<String>? defaultLocation,
    Expression<String>? salaryType,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSystemAdmin,
    Expression<String>? permissions,
    Expression<String>? theme,
    Expression<String>? language,
    Expression<DateTime>? lastLogin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (companyId != null) 'company_id': companyId,
      if (companyName != null) 'company_name': companyName,
      if (roleId != null) 'role_id': roleId,
      if (roleName != null) 'role_name': roleName,
      if (employeeId != null) 'employee_id': employeeId,
      if (designation != null) 'designation': designation,
      if (department != null) 'department': department,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (userType != null) 'user_type': userType,
      if (employeeStatus != null) 'employee_status': employeeStatus,
      if (defaultLocation != null) 'default_location': defaultLocation,
      if (salaryType != null) 'salary_type': salaryType,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSystemAdmin != null) 'is_system_admin': isSystemAdmin,
      if (permissions != null) 'permissions': permissions,
      if (theme != null) 'theme': theme,
      if (language != null) 'language': language,
      if (lastLogin != null) 'last_login': lastLogin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String>? phone,
      Value<String?>? companyId,
      Value<String?>? companyName,
      Value<String>? roleId,
      Value<String?>? roleName,
      Value<String?>? employeeId,
      Value<String?>? designation,
      Value<String?>? department,
      Value<String?>? profilePicture,
      Value<String>? userType,
      Value<String>? employeeStatus,
      Value<String>? defaultLocation,
      Value<String?>? salaryType,
      Value<bool>? isActive,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSystemAdmin,
      Value<List<String>?>? permissions,
      Value<String?>? theme,
      Value<String?>? language,
      Value<DateTime?>? lastLogin,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      salaryType: salaryType ?? this.salaryType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      permissions: permissions ?? this.permissions,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      lastLogin: lastLogin ?? this.lastLogin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (roleName.present) {
      map['role_name'] = Variable<String>(roleName.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (profilePicture.present) {
      map['profile_picture'] = Variable<String>(profilePicture.value);
    }
    if (userType.present) {
      map['user_type'] = Variable<String>(userType.value);
    }
    if (employeeStatus.present) {
      map['employee_status'] = Variable<String>(employeeStatus.value);
    }
    if (defaultLocation.present) {
      map['default_location'] = Variable<String>(defaultLocation.value);
    }
    if (salaryType.present) {
      map['salary_type'] = Variable<String>(salaryType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSystemAdmin.present) {
      map['is_system_admin'] = Variable<bool>(isSystemAdmin.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(
          $UsersTable.$converterpermissionsn.toSql(permissions.value));
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<DateTime>(lastLogin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('companyId: $companyId, ')
          ..write('companyName: $companyName, ')
          ..write('roleId: $roleId, ')
          ..write('roleName: $roleName, ')
          ..write('employeeId: $employeeId, ')
          ..write('designation: $designation, ')
          ..write('department: $department, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('userType: $userType, ')
          ..write('employeeStatus: $employeeStatus, ')
          ..write('defaultLocation: $defaultLocation, ')
          ..write('salaryType: $salaryType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystemAdmin: $isSystemAdmin, ')
          ..write('permissions: $permissions, ')
          ..write('theme: $theme, ')
          ..write('language: $language, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $DailyProgressReportsTable dailyProgressReports =
      $DailyProgressReportsTable(this);
  late final $DprPhotosTable dprPhotos = $DprPhotosTable(this);
  late final $SyncRegistryTable syncRegistry = $SyncRegistryTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        projects,
        attendances,
        tasks,
        subtasks,
        dailyProgressReports,
        dprPhotos,
        syncRegistry,
        users
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subtasks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('daily_progress_reports',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('dpr_photos', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String projectId,
  required String name,
  Value<String?> description,
  required String location,
  required double latitude,
  required double longitude,
  Value<double> geofenceRadius,
  required String status,
  Value<bool> isDeleted,
  Value<DateTime?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> name,
  Value<String?> description,
  Value<String> location,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> geofenceRadius,
  Value<String> status,
  Value<bool> isDeleted,
  Value<DateTime?> serverUpdatedAt,
  Value<int> rowid,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get geofenceRadius => $composableBuilder(
      column: $table.geofenceRadius,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get geofenceRadius => $composableBuilder(
      column: $table.geofenceRadius,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get geofenceRadius => $composableBuilder(
      column: $table.geofenceRadius, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectEntity,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (
      ProjectEntity,
      BaseReferences<_$AppDatabase, $ProjectsTable, ProjectEntity>
    ),
    ProjectEntity,
    PrefetchHooks Function()> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> geofenceRadius = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            projectId: projectId,
            name: name,
            description: description,
            location: location,
            latitude: latitude,
            longitude: longitude,
            geofenceRadius: geofenceRadius,
            status: status,
            isDeleted: isDeleted,
            serverUpdatedAt: serverUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String name,
            Value<String?> description = const Value.absent(),
            required String location,
            required double latitude,
            required double longitude,
            Value<double> geofenceRadius = const Value.absent(),
            required String status,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            projectId: projectId,
            name: name,
            description: description,
            location: location,
            latitude: latitude,
            longitude: longitude,
            geofenceRadius: geofenceRadius,
            status: status,
            isDeleted: isDeleted,
            serverUpdatedAt: serverUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectEntity,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (
      ProjectEntity,
      BaseReferences<_$AppDatabase, $ProjectsTable, ProjectEntity>
    ),
    ProjectEntity,
    PrefetchHooks Function()>;
typedef $$AttendancesTableCreateCompanionBuilder = AttendancesCompanion
    Function({
  required String id,
  required String userId,
  Value<String?> projectId,
  required String locationType,
  Value<String> status,
  required DateTime date,
  Value<DateTime?> checkInTime,
  Value<DateTime?> checkOutTime,
  Value<double?> checkInLatitude,
  Value<double?> checkInLongitude,
  Value<double?> checkOutLatitude,
  Value<double?> checkOutLongitude,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AttendancesTableUpdateCompanionBuilder = AttendancesCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> projectId,
  Value<String> locationType,
  Value<String> status,
  Value<DateTime> date,
  Value<DateTime?> checkInTime,
  Value<DateTime?> checkOutTime,
  Value<double?> checkInLatitude,
  Value<double?> checkInLongitude,
  Value<double?> checkOutLatitude,
  Value<double?> checkOutLongitude,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationType => $composableBuilder(
      column: $table.locationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkInTime => $composableBuilder(
      column: $table.checkInTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkOutTime => $composableBuilder(
      column: $table.checkOutTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get checkInLatitude => $composableBuilder(
      column: $table.checkInLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get checkInLongitude => $composableBuilder(
      column: $table.checkInLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get checkOutLatitude => $composableBuilder(
      column: $table.checkOutLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get checkOutLongitude => $composableBuilder(
      column: $table.checkOutLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationType => $composableBuilder(
      column: $table.locationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkInTime => $composableBuilder(
      column: $table.checkInTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkOutTime => $composableBuilder(
      column: $table.checkOutTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get checkInLatitude => $composableBuilder(
      column: $table.checkInLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get checkInLongitude => $composableBuilder(
      column: $table.checkInLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get checkOutLatitude => $composableBuilder(
      column: $table.checkOutLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get checkOutLongitude => $composableBuilder(
      column: $table.checkOutLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get locationType => $composableBuilder(
      column: $table.locationType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInTime => $composableBuilder(
      column: $table.checkInTime, builder: (column) => column);

  GeneratedColumn<DateTime> get checkOutTime => $composableBuilder(
      column: $table.checkOutTime, builder: (column) => column);

  GeneratedColumn<double> get checkInLatitude => $composableBuilder(
      column: $table.checkInLatitude, builder: (column) => column);

  GeneratedColumn<double> get checkInLongitude => $composableBuilder(
      column: $table.checkInLongitude, builder: (column) => column);

  GeneratedColumn<double> get checkOutLatitude => $composableBuilder(
      column: $table.checkOutLatitude, builder: (column) => column);

  GeneratedColumn<double> get checkOutLongitude => $composableBuilder(
      column: $table.checkOutLongitude, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttendancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendancesTable,
    AttendanceEntity,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (
      AttendanceEntity,
      BaseReferences<_$AppDatabase, $AttendancesTable, AttendanceEntity>
    ),
    AttendanceEntity,
    PrefetchHooks Function()> {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> projectId = const Value.absent(),
            Value<String> locationType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> checkInTime = const Value.absent(),
            Value<DateTime?> checkOutTime = const Value.absent(),
            Value<double?> checkInLatitude = const Value.absent(),
            Value<double?> checkInLongitude = const Value.absent(),
            Value<double?> checkOutLatitude = const Value.absent(),
            Value<double?> checkOutLongitude = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendancesCompanion(
            id: id,
            userId: userId,
            projectId: projectId,
            locationType: locationType,
            status: status,
            date: date,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            checkInLatitude: checkInLatitude,
            checkInLongitude: checkInLongitude,
            checkOutLatitude: checkOutLatitude,
            checkOutLongitude: checkOutLongitude,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> projectId = const Value.absent(),
            required String locationType,
            Value<String> status = const Value.absent(),
            required DateTime date,
            Value<DateTime?> checkInTime = const Value.absent(),
            Value<DateTime?> checkOutTime = const Value.absent(),
            Value<double?> checkInLatitude = const Value.absent(),
            Value<double?> checkInLongitude = const Value.absent(),
            Value<double?> checkOutLatitude = const Value.absent(),
            Value<double?> checkOutLongitude = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendancesCompanion.insert(
            id: id,
            userId: userId,
            projectId: projectId,
            locationType: locationType,
            status: status,
            date: date,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            checkInLatitude: checkInLatitude,
            checkInLongitude: checkInLongitude,
            checkOutLatitude: checkOutLatitude,
            checkOutLongitude: checkOutLongitude,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttendancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendancesTable,
    AttendanceEntity,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (
      AttendanceEntity,
      BaseReferences<_$AppDatabase, $AttendancesTable, AttendanceEntity>
    ),
    AttendanceEntity,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String projectId,
  Value<String?> assignedToId,
  required String createdById,
  required String title,
  Value<String?> description,
  Value<String> status,
  Value<String> priority,
  Value<int> progress,
  Value<DateTime?> startDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedDate,
  Value<double?> estimatedHours,
  Value<double> actualHours,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime> localUpdatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> assignedToId,
  Value<String> createdById,
  Value<String> title,
  Value<String?> description,
  Value<String> status,
  Value<String> priority,
  Value<int> progress,
  Value<DateTime?> startDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedDate,
  Value<double?> estimatedHours,
  Value<double> actualHours,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime> localUpdatedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskEntity> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubtasksTable, List<SubtaskEntity>>
      _subtasksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.subtasks,
              aliasName: $_aliasNameGenerator(db.tasks.id, db.subtasks.taskId));

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager($_db, $_db.subtasks)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedToId => $composableBuilder(
      column: $table.assignedToId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get actualHours => $composableBuilder(
      column: $table.actualHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  Expression<bool> subtasksRefs(
      Expression<bool> Function($$SubtasksTableFilterComposer f) f) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableFilterComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedToId => $composableBuilder(
      column: $table.assignedToId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get actualHours => $composableBuilder(
      column: $table.actualHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get assignedToId => $composableBuilder(
      column: $table.assignedToId, builder: (column) => column);

  GeneratedColumn<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => column);

  GeneratedColumn<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours, builder: (column) => column);

  GeneratedColumn<double> get actualHours => $composableBuilder(
      column: $table.actualHours, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  Expression<T> subtasksRefs<T extends Object>(
      Expression<T> Function($$SubtasksTableAnnotationComposer a) f) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableAnnotationComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskEntity,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskEntity, $$TasksTableReferences),
    TaskEntity,
    PrefetchHooks Function({bool subtasksRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> assignedToId = const Value.absent(),
            Value<String> createdById = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> progress = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedDate = const Value.absent(),
            Value<double?> estimatedHours = const Value.absent(),
            Value<double> actualHours = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            projectId: projectId,
            assignedToId: assignedToId,
            createdById: createdById,
            title: title,
            description: description,
            status: status,
            priority: priority,
            progress: progress,
            startDate: startDate,
            dueDate: dueDate,
            completedDate: completedDate,
            estimatedHours: estimatedHours,
            actualHours: actualHours,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> assignedToId = const Value.absent(),
            required String createdById,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> progress = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedDate = const Value.absent(),
            Value<double?> estimatedHours = const Value.absent(),
            Value<double> actualHours = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            projectId: projectId,
            assignedToId: assignedToId,
            createdById: createdById,
            title: title,
            description: description,
            status: status,
            priority: priority,
            progress: progress,
            startDate: startDate,
            dueDate: dueDate,
            completedDate: completedDate,
            estimatedHours: estimatedHours,
            actualHours: actualHours,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({subtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subtasksRefs) db.subtasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtasksRefs)
                    await $_getPrefetchedData<TaskEntity, $TasksTable,
                            SubtaskEntity>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._subtasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).subtasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskEntity,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskEntity, $$TasksTableReferences),
    TaskEntity,
    PrefetchHooks Function({bool subtasksRefs})>;
typedef $$SubtasksTableCreateCompanionBuilder = SubtasksCompanion Function({
  required String id,
  required String taskId,
  required String description,
  Value<bool> isCompleted,
  Value<String?> createdById,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime> localUpdatedAt,
  Value<int> rowid,
});
typedef $$SubtasksTableUpdateCompanionBuilder = SubtasksCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> description,
  Value<bool> isCompleted,
  Value<String?> createdById,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime> localUpdatedAt,
  Value<int> rowid,
});

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, SubtaskEntity> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.subtasks.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskEntity,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskEntity, $$SubtasksTableReferences),
    SubtaskEntity,
    PrefetchHooks Function({bool taskId})> {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> createdById = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubtasksCompanion(
            id: id,
            taskId: taskId,
            description: description,
            isCompleted: isCompleted,
            createdById: createdById,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String description,
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> createdById = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubtasksCompanion.insert(
            id: id,
            taskId: taskId,
            description: description,
            isCompleted: isCompleted,
            createdById: createdById,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubtasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$SubtasksTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$SubtasksTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SubtasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskEntity,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskEntity, $$SubtasksTableReferences),
    SubtaskEntity,
    PrefetchHooks Function({bool taskId})>;
typedef $$DailyProgressReportsTableCreateCompanionBuilder
    = DailyProgressReportsCompanion Function({
  required String id,
  required String projectId,
  required String reportNo,
  required String preparedById,
  required DateTime date,
  required String workDescription,
  Value<String?> weather,
  Value<String?> temperature,
  Value<String?> humidity,
  Value<String?> completedWork,
  Value<String?> pendingWork,
  Value<String?> challenges,
  Value<int> totalWorkers,
  Value<bool> supervisorPresent,
  Value<String?> equipmentUsed,
  Value<String?> materialsUsed,
  Value<String?> materialsReceived,
  Value<String?> materialsRequired,
  Value<String?> safetyObservations,
  Value<String?> incidents,
  Value<String?> qualityChecks,
  Value<String?> issuesFound,
  Value<String?> nextDayPlan,
  Value<String> status,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$DailyProgressReportsTableUpdateCompanionBuilder
    = DailyProgressReportsCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> reportNo,
  Value<String> preparedById,
  Value<DateTime> date,
  Value<String> workDescription,
  Value<String?> weather,
  Value<String?> temperature,
  Value<String?> humidity,
  Value<String?> completedWork,
  Value<String?> pendingWork,
  Value<String?> challenges,
  Value<int> totalWorkers,
  Value<bool> supervisorPresent,
  Value<String?> equipmentUsed,
  Value<String?> materialsUsed,
  Value<String?> materialsReceived,
  Value<String?> materialsRequired,
  Value<String?> safetyObservations,
  Value<String?> incidents,
  Value<String?> qualityChecks,
  Value<String?> issuesFound,
  Value<String?> nextDayPlan,
  Value<String> status,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$DailyProgressReportsTableReferences extends BaseReferences<
    _$AppDatabase, $DailyProgressReportsTable, DPREntity> {
  $$DailyProgressReportsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DprPhotosTable, List<DPRPhotoEntity>>
      _dprPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.dprPhotos,
              aliasName: $_aliasNameGenerator(
                  db.dailyProgressReports.id, db.dprPhotos.dprId));

  $$DprPhotosTableProcessedTableManager get dprPhotosRefs {
    final manager = $$DprPhotosTableTableManager($_db, $_db.dprPhotos)
        .filter((f) => f.dprId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dprPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DailyProgressReportsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyProgressReportsTable> {
  $$DailyProgressReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportNo => $composableBuilder(
      column: $table.reportNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preparedById => $composableBuilder(
      column: $table.preparedById, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weather => $composableBuilder(
      column: $table.weather, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get humidity => $composableBuilder(
      column: $table.humidity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedWork => $composableBuilder(
      column: $table.completedWork, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pendingWork => $composableBuilder(
      column: $table.pendingWork, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get challenges => $composableBuilder(
      column: $table.challenges, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalWorkers => $composableBuilder(
      column: $table.totalWorkers, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get supervisorPresent => $composableBuilder(
      column: $table.supervisorPresent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipmentUsed => $composableBuilder(
      column: $table.equipmentUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsUsed => $composableBuilder(
      column: $table.materialsUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsReceived => $composableBuilder(
      column: $table.materialsReceived,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsRequired => $composableBuilder(
      column: $table.materialsRequired,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get safetyObservations => $composableBuilder(
      column: $table.safetyObservations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get incidents => $composableBuilder(
      column: $table.incidents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qualityChecks => $composableBuilder(
      column: $table.qualityChecks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issuesFound => $composableBuilder(
      column: $table.issuesFound, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextDayPlan => $composableBuilder(
      column: $table.nextDayPlan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> dprPhotosRefs(
      Expression<bool> Function($$DprPhotosTableFilterComposer f) f) {
    final $$DprPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dprPhotos,
        getReferencedColumn: (t) => t.dprId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DprPhotosTableFilterComposer(
              $db: $db,
              $table: $db.dprPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyProgressReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyProgressReportsTable> {
  $$DailyProgressReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportNo => $composableBuilder(
      column: $table.reportNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preparedById => $composableBuilder(
      column: $table.preparedById,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weather => $composableBuilder(
      column: $table.weather, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get humidity => $composableBuilder(
      column: $table.humidity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedWork => $composableBuilder(
      column: $table.completedWork,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pendingWork => $composableBuilder(
      column: $table.pendingWork, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get challenges => $composableBuilder(
      column: $table.challenges, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalWorkers => $composableBuilder(
      column: $table.totalWorkers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get supervisorPresent => $composableBuilder(
      column: $table.supervisorPresent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipmentUsed => $composableBuilder(
      column: $table.equipmentUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsUsed => $composableBuilder(
      column: $table.materialsUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsReceived => $composableBuilder(
      column: $table.materialsReceived,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsRequired => $composableBuilder(
      column: $table.materialsRequired,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get safetyObservations => $composableBuilder(
      column: $table.safetyObservations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get incidents => $composableBuilder(
      column: $table.incidents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qualityChecks => $composableBuilder(
      column: $table.qualityChecks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issuesFound => $composableBuilder(
      column: $table.issuesFound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextDayPlan => $composableBuilder(
      column: $table.nextDayPlan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyProgressReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyProgressReportsTable> {
  $$DailyProgressReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get reportNo =>
      $composableBuilder(column: $table.reportNo, builder: (column) => column);

  GeneratedColumn<String> get preparedById => $composableBuilder(
      column: $table.preparedById, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get workDescription => $composableBuilder(
      column: $table.workDescription, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<String> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<String> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<String> get completedWork => $composableBuilder(
      column: $table.completedWork, builder: (column) => column);

  GeneratedColumn<String> get pendingWork => $composableBuilder(
      column: $table.pendingWork, builder: (column) => column);

  GeneratedColumn<String> get challenges => $composableBuilder(
      column: $table.challenges, builder: (column) => column);

  GeneratedColumn<int> get totalWorkers => $composableBuilder(
      column: $table.totalWorkers, builder: (column) => column);

  GeneratedColumn<bool> get supervisorPresent => $composableBuilder(
      column: $table.supervisorPresent, builder: (column) => column);

  GeneratedColumn<String> get equipmentUsed => $composableBuilder(
      column: $table.equipmentUsed, builder: (column) => column);

  GeneratedColumn<String> get materialsUsed => $composableBuilder(
      column: $table.materialsUsed, builder: (column) => column);

  GeneratedColumn<String> get materialsReceived => $composableBuilder(
      column: $table.materialsReceived, builder: (column) => column);

  GeneratedColumn<String> get materialsRequired => $composableBuilder(
      column: $table.materialsRequired, builder: (column) => column);

  GeneratedColumn<String> get safetyObservations => $composableBuilder(
      column: $table.safetyObservations, builder: (column) => column);

  GeneratedColumn<String> get incidents =>
      $composableBuilder(column: $table.incidents, builder: (column) => column);

  GeneratedColumn<String> get qualityChecks => $composableBuilder(
      column: $table.qualityChecks, builder: (column) => column);

  GeneratedColumn<String> get issuesFound => $composableBuilder(
      column: $table.issuesFound, builder: (column) => column);

  GeneratedColumn<String> get nextDayPlan => $composableBuilder(
      column: $table.nextDayPlan, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dprPhotosRefs<T extends Object>(
      Expression<T> Function($$DprPhotosTableAnnotationComposer a) f) {
    final $$DprPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dprPhotos,
        getReferencedColumn: (t) => t.dprId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DprPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.dprPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyProgressReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyProgressReportsTable,
    DPREntity,
    $$DailyProgressReportsTableFilterComposer,
    $$DailyProgressReportsTableOrderingComposer,
    $$DailyProgressReportsTableAnnotationComposer,
    $$DailyProgressReportsTableCreateCompanionBuilder,
    $$DailyProgressReportsTableUpdateCompanionBuilder,
    (DPREntity, $$DailyProgressReportsTableReferences),
    DPREntity,
    PrefetchHooks Function({bool dprPhotosRefs})> {
  $$DailyProgressReportsTableTableManager(
      _$AppDatabase db, $DailyProgressReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyProgressReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyProgressReportsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyProgressReportsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> reportNo = const Value.absent(),
            Value<String> preparedById = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> workDescription = const Value.absent(),
            Value<String?> weather = const Value.absent(),
            Value<String?> temperature = const Value.absent(),
            Value<String?> humidity = const Value.absent(),
            Value<String?> completedWork = const Value.absent(),
            Value<String?> pendingWork = const Value.absent(),
            Value<String?> challenges = const Value.absent(),
            Value<int> totalWorkers = const Value.absent(),
            Value<bool> supervisorPresent = const Value.absent(),
            Value<String?> equipmentUsed = const Value.absent(),
            Value<String?> materialsUsed = const Value.absent(),
            Value<String?> materialsReceived = const Value.absent(),
            Value<String?> materialsRequired = const Value.absent(),
            Value<String?> safetyObservations = const Value.absent(),
            Value<String?> incidents = const Value.absent(),
            Value<String?> qualityChecks = const Value.absent(),
            Value<String?> issuesFound = const Value.absent(),
            Value<String?> nextDayPlan = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyProgressReportsCompanion(
            id: id,
            projectId: projectId,
            reportNo: reportNo,
            preparedById: preparedById,
            date: date,
            workDescription: workDescription,
            weather: weather,
            temperature: temperature,
            humidity: humidity,
            completedWork: completedWork,
            pendingWork: pendingWork,
            challenges: challenges,
            totalWorkers: totalWorkers,
            supervisorPresent: supervisorPresent,
            equipmentUsed: equipmentUsed,
            materialsUsed: materialsUsed,
            materialsReceived: materialsReceived,
            materialsRequired: materialsRequired,
            safetyObservations: safetyObservations,
            incidents: incidents,
            qualityChecks: qualityChecks,
            issuesFound: issuesFound,
            nextDayPlan: nextDayPlan,
            status: status,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String reportNo,
            required String preparedById,
            required DateTime date,
            required String workDescription,
            Value<String?> weather = const Value.absent(),
            Value<String?> temperature = const Value.absent(),
            Value<String?> humidity = const Value.absent(),
            Value<String?> completedWork = const Value.absent(),
            Value<String?> pendingWork = const Value.absent(),
            Value<String?> challenges = const Value.absent(),
            Value<int> totalWorkers = const Value.absent(),
            Value<bool> supervisorPresent = const Value.absent(),
            Value<String?> equipmentUsed = const Value.absent(),
            Value<String?> materialsUsed = const Value.absent(),
            Value<String?> materialsReceived = const Value.absent(),
            Value<String?> materialsRequired = const Value.absent(),
            Value<String?> safetyObservations = const Value.absent(),
            Value<String?> incidents = const Value.absent(),
            Value<String?> qualityChecks = const Value.absent(),
            Value<String?> issuesFound = const Value.absent(),
            Value<String?> nextDayPlan = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyProgressReportsCompanion.insert(
            id: id,
            projectId: projectId,
            reportNo: reportNo,
            preparedById: preparedById,
            date: date,
            workDescription: workDescription,
            weather: weather,
            temperature: temperature,
            humidity: humidity,
            completedWork: completedWork,
            pendingWork: pendingWork,
            challenges: challenges,
            totalWorkers: totalWorkers,
            supervisorPresent: supervisorPresent,
            equipmentUsed: equipmentUsed,
            materialsUsed: materialsUsed,
            materialsReceived: materialsReceived,
            materialsRequired: materialsRequired,
            safetyObservations: safetyObservations,
            incidents: incidents,
            qualityChecks: qualityChecks,
            issuesFound: issuesFound,
            nextDayPlan: nextDayPlan,
            status: status,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DailyProgressReportsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dprPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dprPhotosRefs) db.dprPhotos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dprPhotosRefs)
                    await $_getPrefetchedData<DPREntity,
                            $DailyProgressReportsTable, DPRPhotoEntity>(
                        currentTable: table,
                        referencedTable: $$DailyProgressReportsTableReferences
                            ._dprPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DailyProgressReportsTableReferences(db, table, p0)
                                .dprPhotosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.dprId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DailyProgressReportsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DailyProgressReportsTable,
        DPREntity,
        $$DailyProgressReportsTableFilterComposer,
        $$DailyProgressReportsTableOrderingComposer,
        $$DailyProgressReportsTableAnnotationComposer,
        $$DailyProgressReportsTableCreateCompanionBuilder,
        $$DailyProgressReportsTableUpdateCompanionBuilder,
        (DPREntity, $$DailyProgressReportsTableReferences),
        DPREntity,
        PrefetchHooks Function({bool dprPhotosRefs})>;
typedef $$DprPhotosTableCreateCompanionBuilder = DprPhotosCompanion Function({
  required String id,
  required String dprId,
  Value<String?> title,
  Value<String?> description,
  Value<String?> localPath,
  Value<String?> imageUrl,
  Value<String?> thumbnailUrl,
  required String uploadedById,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$DprPhotosTableUpdateCompanionBuilder = DprPhotosCompanion Function({
  Value<String> id,
  Value<String> dprId,
  Value<String?> title,
  Value<String?> description,
  Value<String?> localPath,
  Value<String?> imageUrl,
  Value<String?> thumbnailUrl,
  Value<String> uploadedById,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$DprPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $DprPhotosTable, DPRPhotoEntity> {
  $$DprPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DailyProgressReportsTable _dprIdTable(_$AppDatabase db) =>
      db.dailyProgressReports.createAlias(
          $_aliasNameGenerator(db.dprPhotos.dprId, db.dailyProgressReports.id));

  $$DailyProgressReportsTableProcessedTableManager get dprId {
    final $_column = $_itemColumn<String>('dpr_id')!;

    final manager =
        $$DailyProgressReportsTableTableManager($_db, $_db.dailyProgressReports)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dprIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DprPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $DprPhotosTable> {
  $$DprPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadedById => $composableBuilder(
      column: $table.uploadedById, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$DailyProgressReportsTableFilterComposer get dprId {
    final $$DailyProgressReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dprId,
        referencedTable: $db.dailyProgressReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyProgressReportsTableFilterComposer(
              $db: $db,
              $table: $db.dailyProgressReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DprPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $DprPhotosTable> {
  $$DprPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadedById => $composableBuilder(
      column: $table.uploadedById,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$DailyProgressReportsTableOrderingComposer get dprId {
    final $$DailyProgressReportsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.dprId,
            referencedTable: $db.dailyProgressReports,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DailyProgressReportsTableOrderingComposer(
                  $db: $db,
                  $table: $db.dailyProgressReports,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DprPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DprPhotosTable> {
  $$DprPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get uploadedById => $composableBuilder(
      column: $table.uploadedById, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DailyProgressReportsTableAnnotationComposer get dprId {
    final $$DailyProgressReportsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.dprId,
            referencedTable: $db.dailyProgressReports,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DailyProgressReportsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dailyProgressReports,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DprPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DprPhotosTable,
    DPRPhotoEntity,
    $$DprPhotosTableFilterComposer,
    $$DprPhotosTableOrderingComposer,
    $$DprPhotosTableAnnotationComposer,
    $$DprPhotosTableCreateCompanionBuilder,
    $$DprPhotosTableUpdateCompanionBuilder,
    (DPRPhotoEntity, $$DprPhotosTableReferences),
    DPRPhotoEntity,
    PrefetchHooks Function({bool dprId})> {
  $$DprPhotosTableTableManager(_$AppDatabase db, $DprPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DprPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DprPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DprPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dprId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String> uploadedById = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DprPhotosCompanion(
            id: id,
            dprId: dprId,
            title: title,
            description: description,
            localPath: localPath,
            imageUrl: imageUrl,
            thumbnailUrl: thumbnailUrl,
            uploadedById: uploadedById,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dprId,
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            required String uploadedById,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DprPhotosCompanion.insert(
            id: id,
            dprId: dprId,
            title: title,
            description: description,
            localPath: localPath,
            imageUrl: imageUrl,
            thumbnailUrl: thumbnailUrl,
            uploadedById: uploadedById,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DprPhotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dprId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (dprId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dprId,
                    referencedTable: $$DprPhotosTableReferences._dprIdTable(db),
                    referencedColumn:
                        $$DprPhotosTableReferences._dprIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DprPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DprPhotosTable,
    DPRPhotoEntity,
    $$DprPhotosTableFilterComposer,
    $$DprPhotosTableOrderingComposer,
    $$DprPhotosTableAnnotationComposer,
    $$DprPhotosTableCreateCompanionBuilder,
    $$DprPhotosTableUpdateCompanionBuilder,
    (DPRPhotoEntity, $$DprPhotosTableReferences),
    DPRPhotoEntity,
    PrefetchHooks Function({bool dprId})>;
typedef $$SyncRegistryTableCreateCompanionBuilder = SyncRegistryCompanion
    Function({
  required String model,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SyncRegistryTableUpdateCompanionBuilder = SyncRegistryCompanion
    Function({
  Value<String> model,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SyncRegistryTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRegistryTable> {
  $$SyncRegistryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncRegistryTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRegistryTable> {
  $$SyncRegistryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncRegistryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRegistryTable> {
  $$SyncRegistryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SyncRegistryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncRegistryTable,
    SyncRegistryData,
    $$SyncRegistryTableFilterComposer,
    $$SyncRegistryTableOrderingComposer,
    $$SyncRegistryTableAnnotationComposer,
    $$SyncRegistryTableCreateCompanionBuilder,
    $$SyncRegistryTableUpdateCompanionBuilder,
    (
      SyncRegistryData,
      BaseReferences<_$AppDatabase, $SyncRegistryTable, SyncRegistryData>
    ),
    SyncRegistryData,
    PrefetchHooks Function()> {
  $$SyncRegistryTableTableManager(_$AppDatabase db, $SyncRegistryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRegistryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRegistryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRegistryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> model = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncRegistryCompanion(
            model: model,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String model,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncRegistryCompanion.insert(
            model: model,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncRegistryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncRegistryTable,
    SyncRegistryData,
    $$SyncRegistryTableFilterComposer,
    $$SyncRegistryTableOrderingComposer,
    $$SyncRegistryTableAnnotationComposer,
    $$SyncRegistryTableCreateCompanionBuilder,
    $$SyncRegistryTableUpdateCompanionBuilder,
    (
      SyncRegistryData,
      BaseReferences<_$AppDatabase, $SyncRegistryTable, SyncRegistryData>
    ),
    SyncRegistryData,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String name,
  Value<String?> email,
  required String phone,
  Value<String?> companyId,
  Value<String?> companyName,
  required String roleId,
  Value<String?> roleName,
  Value<String?> employeeId,
  Value<String?> designation,
  Value<String?> department,
  Value<String?> profilePicture,
  required String userType,
  required String employeeStatus,
  required String defaultLocation,
  Value<String?> salaryType,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSystemAdmin,
  Value<List<String>?> permissions,
  Value<String?> theme,
  Value<String?> language,
  Value<DateTime?> lastLogin,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> email,
  Value<String> phone,
  Value<String?> companyId,
  Value<String?> companyName,
  Value<String> roleId,
  Value<String?> roleName,
  Value<String?> employeeId,
  Value<String?> designation,
  Value<String?> department,
  Value<String?> profilePicture,
  Value<String> userType,
  Value<String> employeeStatus,
  Value<String> defaultLocation,
  Value<String?> salaryType,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSystemAdmin,
  Value<List<String>?> permissions,
  Value<String?> theme,
  Value<String?> language,
  Value<DateTime?> lastLogin,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyId => $composableBuilder(
      column: $table.companyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roleName => $composableBuilder(
      column: $table.roleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userType => $composableBuilder(
      column: $table.userType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeStatus => $composableBuilder(
      column: $table.employeeStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultLocation => $composableBuilder(
      column: $table.defaultLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salaryType => $composableBuilder(
      column: $table.salaryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystemAdmin => $composableBuilder(
      column: $table.isSystemAdmin, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get permissions => $composableBuilder(
          column: $table.permissions,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyId => $composableBuilder(
      column: $table.companyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roleName => $composableBuilder(
      column: $table.roleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userType => $composableBuilder(
      column: $table.userType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeStatus => $composableBuilder(
      column: $table.employeeStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultLocation => $composableBuilder(
      column: $table.defaultLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salaryType => $composableBuilder(
      column: $table.salaryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystemAdmin => $composableBuilder(
      column: $table.isSystemAdmin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get roleName =>
      $composableBuilder(column: $table.roleName, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture, builder: (column) => column);

  GeneratedColumn<String> get userType =>
      $composableBuilder(column: $table.userType, builder: (column) => column);

  GeneratedColumn<String> get employeeStatus => $composableBuilder(
      column: $table.employeeStatus, builder: (column) => column);

  GeneratedColumn<String> get defaultLocation => $composableBuilder(
      column: $table.defaultLocation, builder: (column) => column);

  GeneratedColumn<String> get salaryType => $composableBuilder(
      column: $table.salaryType, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSystemAdmin => $composableBuilder(
      column: $table.isSystemAdmin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get permissions =>
      $composableBuilder(
          column: $table.permissions, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> companyId = const Value.absent(),
            Value<String?> companyName = const Value.absent(),
            Value<String> roleId = const Value.absent(),
            Value<String?> roleName = const Value.absent(),
            Value<String?> employeeId = const Value.absent(),
            Value<String?> designation = const Value.absent(),
            Value<String?> department = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            Value<String> userType = const Value.absent(),
            Value<String> employeeStatus = const Value.absent(),
            Value<String> defaultLocation = const Value.absent(),
            Value<String?> salaryType = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSystemAdmin = const Value.absent(),
            Value<List<String>?> permissions = const Value.absent(),
            Value<String?> theme = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            phone: phone,
            companyId: companyId,
            companyName: companyName,
            roleId: roleId,
            roleName: roleName,
            employeeId: employeeId,
            designation: designation,
            department: department,
            profilePicture: profilePicture,
            userType: userType,
            employeeStatus: employeeStatus,
            defaultLocation: defaultLocation,
            salaryType: salaryType,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSystemAdmin: isSystemAdmin,
            permissions: permissions,
            theme: theme,
            language: language,
            lastLogin: lastLogin,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> email = const Value.absent(),
            required String phone,
            Value<String?> companyId = const Value.absent(),
            Value<String?> companyName = const Value.absent(),
            required String roleId,
            Value<String?> roleName = const Value.absent(),
            Value<String?> employeeId = const Value.absent(),
            Value<String?> designation = const Value.absent(),
            Value<String?> department = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            required String userType,
            required String employeeStatus,
            required String defaultLocation,
            Value<String?> salaryType = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSystemAdmin = const Value.absent(),
            Value<List<String>?> permissions = const Value.absent(),
            Value<String?> theme = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            phone: phone,
            companyId: companyId,
            companyName: companyName,
            roleId: roleId,
            roleName: roleName,
            employeeId: employeeId,
            designation: designation,
            department: department,
            profilePicture: profilePicture,
            userType: userType,
            employeeStatus: employeeStatus,
            defaultLocation: defaultLocation,
            salaryType: salaryType,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSystemAdmin: isSystemAdmin,
            permissions: permissions,
            theme: theme,
            language: language,
            lastLogin: lastLogin,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$DailyProgressReportsTableTableManager get dailyProgressReports =>
      $$DailyProgressReportsTableTableManager(_db, _db.dailyProgressReports);
  $$DprPhotosTableTableManager get dprPhotos =>
      $$DprPhotosTableTableManager(_db, _db.dprPhotos);
  $$SyncRegistryTableTableManager get syncRegistry =>
      $$SyncRegistryTableTableManager(_db, _db.syncRegistry);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
