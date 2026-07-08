// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_schemas.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarIdentityCollection on Isar {
  IsarCollection<IsarIdentity> get isarIdentitys => this.collection();
}

const IsarIdentitySchema = CollectionSchema(
  name: r'IsarIdentity',
  id: -2524915395877191193,
  properties: {
    r'connectedProviders': PropertySchema(
      id: 0,
      name: r'connectedProviders',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isGuest': PropertySchema(
      id: 2,
      name: r'isGuest',
      type: IsarType.bool,
    ),
    r'uuid': PropertySchema(
      id: 3,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarIdentityEstimateSize,
  serialize: _isarIdentitySerialize,
  deserialize: _isarIdentityDeserialize,
  deserializeProp: _isarIdentityDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarIdentityGetId,
  getLinks: _isarIdentityGetLinks,
  attach: _isarIdentityAttach,
  version: '3.1.0+1',
);

int _isarIdentityEstimateSize(
  IsarIdentity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.connectedProviders.length * 3;
  {
    for (var i = 0; i < object.connectedProviders.length; i++) {
      final value = object.connectedProviders[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _isarIdentitySerialize(
  IsarIdentity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.connectedProviders);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isGuest);
  writer.writeString(offsets[3], object.uuid);
}

IsarIdentity _isarIdentityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarIdentity();
  object.connectedProviders = reader.readStringList(offsets[0]) ?? [];
  object.createdAt = reader.readDateTime(offsets[1]);
  object.isGuest = reader.readBool(offsets[2]);
  object.uuid = reader.readString(offsets[3]);
  return object;
}

P _isarIdentityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarIdentityGetId(IsarIdentity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarIdentityGetLinks(IsarIdentity object) {
  return [];
}

void _isarIdentityAttach(
    IsarCollection<dynamic> col, Id id, IsarIdentity object) {}

extension IsarIdentityByIndex on IsarCollection<IsarIdentity> {
  Future<IsarIdentity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarIdentity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarIdentity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarIdentity?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(IsarIdentity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarIdentity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarIdentity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarIdentity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarIdentityQueryWhereSort
    on QueryBuilder<IsarIdentity, IsarIdentity, QWhere> {
  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarIdentityQueryWhere
    on QueryBuilder<IsarIdentity, IsarIdentity, QWhereClause> {
  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarIdentityQueryFilter
    on QueryBuilder<IsarIdentity, IsarIdentity, QFilterCondition> {
  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'connectedProviders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'connectedProviders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'connectedProviders',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectedProviders',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'connectedProviders',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      connectedProvidersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'connectedProviders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      isGuestEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGuest',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension IsarIdentityQueryObject
    on QueryBuilder<IsarIdentity, IsarIdentity, QFilterCondition> {}

extension IsarIdentityQueryLinks
    on QueryBuilder<IsarIdentity, IsarIdentity, QFilterCondition> {}

extension IsarIdentityQuerySortBy
    on QueryBuilder<IsarIdentity, IsarIdentity, QSortBy> {
  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByIsGuest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuest', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByIsGuestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuest', Sort.desc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarIdentityQuerySortThenBy
    on QueryBuilder<IsarIdentity, IsarIdentity, QSortThenBy> {
  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByIsGuest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuest', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByIsGuestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuest', Sort.desc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarIdentityQueryWhereDistinct
    on QueryBuilder<IsarIdentity, IsarIdentity, QDistinct> {
  QueryBuilder<IsarIdentity, IsarIdentity, QDistinct>
      distinctByConnectedProviders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'connectedProviders');
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QDistinct> distinctByIsGuest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGuest');
    });
  }

  QueryBuilder<IsarIdentity, IsarIdentity, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarIdentityQueryProperty
    on QueryBuilder<IsarIdentity, IsarIdentity, QQueryProperty> {
  QueryBuilder<IsarIdentity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarIdentity, List<String>, QQueryOperations>
      connectedProvidersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'connectedProviders');
    });
  }

  QueryBuilder<IsarIdentity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarIdentity, bool, QQueryOperations> isGuestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGuest');
    });
  }

  QueryBuilder<IsarIdentity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarBiologicalStateCollection on Isar {
  IsarCollection<IsarBiologicalState> get isarBiologicalStates =>
      this.collection();
}

const IsarBiologicalStateSchema = CollectionSchema(
  name: r'IsarBiologicalState',
  id: 8867351303755932818,
  properties: {
    r'causalEventIds': PropertySchema(
      id: 0,
      name: r'causalEventIds',
      type: IsarType.stringList,
    ),
    r'confidenceScore': PropertySchema(
      id: 1,
      name: r'confidenceScore',
      type: IsarType.double,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'serializedData': PropertySchema(
      id: 4,
      name: r'serializedData',
      type: IsarType.string,
    ),
    r'stateId': PropertySchema(
      id: 5,
      name: r'stateId',
      type: IsarType.string,
    ),
    r'stateType': PropertySchema(
      id: 6,
      name: r'stateType',
      type: IsarType.string,
    ),
    r'uncertaintyScore': PropertySchema(
      id: 7,
      name: r'uncertaintyScore',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    ),
    r'validityWindowSeconds': PropertySchema(
      id: 9,
      name: r'validityWindowSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _isarBiologicalStateEstimateSize,
  serialize: _isarBiologicalStateSerialize,
  deserialize: _isarBiologicalStateDeserialize,
  deserializeProp: _isarBiologicalStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'stateId': IndexSchema(
      id: -1428154555284842722,
      name: r'stateId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stateId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'stateType': IndexSchema(
      id: -3921060557000774236,
      name: r'stateType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stateType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarBiologicalStateGetId,
  getLinks: _isarBiologicalStateGetLinks,
  attach: _isarBiologicalStateAttach,
  version: '3.1.0+1',
);

int _isarBiologicalStateEstimateSize(
  IsarBiologicalState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.causalEventIds.length * 3;
  {
    for (var i = 0; i < object.causalEventIds.length; i++) {
      final value = object.causalEventIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.serializedData.length * 3;
  bytesCount += 3 + object.stateId.length * 3;
  bytesCount += 3 + object.stateType.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _isarBiologicalStateSerialize(
  IsarBiologicalState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.causalEventIds);
  writer.writeDouble(offsets[1], object.confidenceScore);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeString(offsets[4], object.serializedData);
  writer.writeString(offsets[5], object.stateId);
  writer.writeString(offsets[6], object.stateType);
  writer.writeDouble(offsets[7], object.uncertaintyScore);
  writer.writeString(offsets[8], object.userId);
  writer.writeLong(offsets[9], object.validityWindowSeconds);
}

IsarBiologicalState _isarBiologicalStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarBiologicalState();
  object.causalEventIds = reader.readStringList(offsets[0]) ?? [];
  object.confidenceScore = reader.readDouble(offsets[1]);
  object.isSynced = reader.readBool(offsets[2]);
  object.lastUpdated = reader.readDateTime(offsets[3]);
  object.serializedData = reader.readString(offsets[4]);
  object.stateId = reader.readString(offsets[5]);
  object.stateType = reader.readString(offsets[6]);
  object.uncertaintyScore = reader.readDouble(offsets[7]);
  object.userId = reader.readString(offsets[8]);
  object.validityWindowSeconds = reader.readLong(offsets[9]);
  return object;
}

P _isarBiologicalStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarBiologicalStateGetId(IsarBiologicalState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarBiologicalStateGetLinks(
    IsarBiologicalState object) {
  return [];
}

void _isarBiologicalStateAttach(
    IsarCollection<dynamic> col, Id id, IsarBiologicalState object) {}

extension IsarBiologicalStateQueryWhereSort
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QWhere> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension IsarBiologicalStateQueryWhere
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QWhereClause> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      stateIdEqualTo(String stateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stateId',
        value: [stateId],
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      stateIdNotEqualTo(String stateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [],
              upper: [stateId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [stateId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [stateId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [],
              upper: [stateId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      stateTypeEqualTo(String stateType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stateType',
        value: [stateType],
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      stateTypeNotEqualTo(String stateType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateType',
              lower: [],
              upper: [stateType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateType',
              lower: [stateType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateType',
              lower: [stateType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateType',
              lower: [],
              upper: [stateType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarBiologicalStateQueryFilter on QueryBuilder<IsarBiologicalState,
    IsarBiologicalState, QFilterCondition> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'causalEventIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'causalEventIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'causalEventIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'causalEventIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'causalEventIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      causalEventIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'causalEventIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      confidenceScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      confidenceScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      confidenceScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      confidenceScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidenceScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serializedData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serializedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serializedData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      serializedDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serializedData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      stateTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      uncertaintyScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uncertaintyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      uncertaintyScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uncertaintyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      uncertaintyScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uncertaintyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      uncertaintyScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uncertaintyScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      validityWindowSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validityWindowSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      validityWindowSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'validityWindowSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      validityWindowSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'validityWindowSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterFilterCondition>
      validityWindowSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'validityWindowSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarBiologicalStateQueryObject on QueryBuilder<IsarBiologicalState,
    IsarBiologicalState, QFilterCondition> {}

extension IsarBiologicalStateQueryLinks on QueryBuilder<IsarBiologicalState,
    IsarBiologicalState, QFilterCondition> {}

extension IsarBiologicalStateQuerySortBy
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QSortBy> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortBySerializedData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedData', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortBySerializedDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedData', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByStateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByStateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByStateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateType', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByStateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateType', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByUncertaintyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uncertaintyScore', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByUncertaintyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uncertaintyScore', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByValidityWindowSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validityWindowSeconds', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      sortByValidityWindowSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validityWindowSeconds', Sort.desc);
    });
  }
}

extension IsarBiologicalStateQuerySortThenBy
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QSortThenBy> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenBySerializedData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedData', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenBySerializedDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedData', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByStateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByStateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByStateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateType', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByStateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateType', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByUncertaintyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uncertaintyScore', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByUncertaintyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uncertaintyScore', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByValidityWindowSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validityWindowSeconds', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QAfterSortBy>
      thenByValidityWindowSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validityWindowSeconds', Sort.desc);
    });
  }
}

extension IsarBiologicalStateQueryWhereDistinct
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct> {
  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByCausalEventIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'causalEventIds');
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidenceScore');
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctBySerializedData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serializedData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByStateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByStateType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByUncertaintyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uncertaintyScore');
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalState, IsarBiologicalState, QDistinct>
      distinctByValidityWindowSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validityWindowSeconds');
    });
  }
}

extension IsarBiologicalStateQueryProperty
    on QueryBuilder<IsarBiologicalState, IsarBiologicalState, QQueryProperty> {
  QueryBuilder<IsarBiologicalState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarBiologicalState, List<String>, QQueryOperations>
      causalEventIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'causalEventIds');
    });
  }

  QueryBuilder<IsarBiologicalState, double, QQueryOperations>
      confidenceScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidenceScore');
    });
  }

  QueryBuilder<IsarBiologicalState, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<IsarBiologicalState, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<IsarBiologicalState, String, QQueryOperations>
      serializedDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serializedData');
    });
  }

  QueryBuilder<IsarBiologicalState, String, QQueryOperations>
      stateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateId');
    });
  }

  QueryBuilder<IsarBiologicalState, String, QQueryOperations>
      stateTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateType');
    });
  }

  QueryBuilder<IsarBiologicalState, double, QQueryOperations>
      uncertaintyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uncertaintyScore');
    });
  }

  QueryBuilder<IsarBiologicalState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<IsarBiologicalState, int, QQueryOperations>
      validityWindowSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validityWindowSeconds');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarBiologicalEventCollection on Isar {
  IsarCollection<IsarBiologicalEvent> get isarBiologicalEvents =>
      this.collection();
}

const IsarBiologicalEventSchema = CollectionSchema(
  name: r'IsarBiologicalEvent',
  id: -7032638301686359929,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'eventId': PropertySchema(
      id: 1,
      name: r'eventId',
      type: IsarType.string,
    ),
    r'eventType': PropertySchema(
      id: 2,
      name: r'eventType',
      type: IsarType.string,
    ),
    r'impactHorizon': PropertySchema(
      id: 3,
      name: r'impactHorizon',
      type: IsarType.string,
    ),
    r'isReversible': PropertySchema(
      id: 4,
      name: r'isReversible',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'occurredAt': PropertySchema(
      id: 6,
      name: r'occurredAt',
      type: IsarType.dateTime,
    ),
    r'registeredAt': PropertySchema(
      id: 7,
      name: r'registeredAt',
      type: IsarType.dateTime,
    ),
    r'serializedPayload': PropertySchema(
      id: 8,
      name: r'serializedPayload',
      type: IsarType.string,
    ),
    r'severity': PropertySchema(
      id: 9,
      name: r'severity',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 10,
      name: r'source',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarBiologicalEventEstimateSize,
  serialize: _isarBiologicalEventSerialize,
  deserialize: _isarBiologicalEventDeserialize,
  deserializeProp: _isarBiologicalEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventId': IndexSchema(
      id: -2707901133518603130,
      name: r'eventId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'occurredAt': IndexSchema(
      id: 1229694562040044173,
      name: r'occurredAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurredAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarBiologicalEventGetId,
  getLinks: _isarBiologicalEventGetLinks,
  attach: _isarBiologicalEventAttach,
  version: '3.1.0+1',
);

int _isarBiologicalEventEstimateSize(
  IsarBiologicalEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.eventId.length * 3;
  bytesCount += 3 + object.eventType.length * 3;
  bytesCount += 3 + object.impactHorizon.length * 3;
  bytesCount += 3 + object.serializedPayload.length * 3;
  bytesCount += 3 + object.severity.length * 3;
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _isarBiologicalEventSerialize(
  IsarBiologicalEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeString(offsets[1], object.eventId);
  writer.writeString(offsets[2], object.eventType);
  writer.writeString(offsets[3], object.impactHorizon);
  writer.writeBool(offsets[4], object.isReversible);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeDateTime(offsets[6], object.occurredAt);
  writer.writeDateTime(offsets[7], object.registeredAt);
  writer.writeString(offsets[8], object.serializedPayload);
  writer.writeString(offsets[9], object.severity);
  writer.writeString(offsets[10], object.source);
  writer.writeString(offsets[11], object.userId);
}

IsarBiologicalEvent _isarBiologicalEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarBiologicalEvent();
  object.confidence = reader.readDouble(offsets[0]);
  object.eventId = reader.readString(offsets[1]);
  object.eventType = reader.readString(offsets[2]);
  object.impactHorizon = reader.readString(offsets[3]);
  object.isReversible = reader.readBool(offsets[4]);
  object.isSynced = reader.readBool(offsets[5]);
  object.occurredAt = reader.readDateTime(offsets[6]);
  object.registeredAt = reader.readDateTime(offsets[7]);
  object.serializedPayload = reader.readString(offsets[8]);
  object.severity = reader.readString(offsets[9]);
  object.source = reader.readString(offsets[10]);
  object.userId = reader.readString(offsets[11]);
  return object;
}

P _isarBiologicalEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarBiologicalEventGetId(IsarBiologicalEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarBiologicalEventGetLinks(
    IsarBiologicalEvent object) {
  return [];
}

void _isarBiologicalEventAttach(
    IsarCollection<dynamic> col, Id id, IsarBiologicalEvent object) {}

extension IsarBiologicalEventByIndex on IsarCollection<IsarBiologicalEvent> {
  Future<IsarBiologicalEvent?> getByEventId(String eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  IsarBiologicalEvent? getByEventIdSync(String eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(String eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(String eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<IsarBiologicalEvent?>> getAllByEventId(
      List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<IsarBiologicalEvent?> getAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventId', values);
  }

  Future<int> deleteAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventId', values);
  }

  int deleteAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventId', values);
  }

  Future<Id> putByEventId(IsarBiologicalEvent object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(IsarBiologicalEvent object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<IsarBiologicalEvent> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(List<IsarBiologicalEvent> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension IsarBiologicalEventQueryWhereSort
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QWhere> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhere>
      anyOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'occurredAt'),
      );
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension IsarBiologicalEventQueryWhere
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QWhereClause> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      eventIdEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'eventId',
        value: [eventId],
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      eventIdNotEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [],
              upper: [eventId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [eventId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [eventId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [],
              upper: [eventId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      occurredAtEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'occurredAt',
        value: [occurredAt],
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      occurredAtNotEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [],
              upper: [occurredAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [occurredAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [occurredAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [],
              upper: [occurredAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      occurredAtGreaterThan(
    DateTime occurredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [occurredAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      occurredAtLessThan(
    DateTime occurredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [],
        upper: [occurredAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      occurredAtBetween(
    DateTime lowerOccurredAt,
    DateTime upperOccurredAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [lowerOccurredAt],
        includeLower: includeLower,
        upper: [upperOccurredAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarBiologicalEventQueryFilter on QueryBuilder<IsarBiologicalEvent,
    IsarBiologicalEvent, QFilterCondition> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      eventTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'impactHorizon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'impactHorizon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'impactHorizon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'impactHorizon',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      impactHorizonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'impactHorizon',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      isReversibleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isReversible',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      occurredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      occurredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      occurredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      occurredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      registeredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      registeredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'registeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      registeredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'registeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      registeredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'registeredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serializedPayload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serializedPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serializedPayload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      serializedPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serializedPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'severity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'severity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'severity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severity',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      severityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'severity',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension IsarBiologicalEventQueryObject on QueryBuilder<IsarBiologicalEvent,
    IsarBiologicalEvent, QFilterCondition> {}

extension IsarBiologicalEventQueryLinks on QueryBuilder<IsarBiologicalEvent,
    IsarBiologicalEvent, QFilterCondition> {}

extension IsarBiologicalEventQuerySortBy
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QSortBy> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByImpactHorizon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impactHorizon', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByImpactHorizonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impactHorizon', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByIsReversible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReversible', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByIsReversibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReversible', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByRegisteredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySerializedPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedPayload', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySerializedPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedPayload', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarBiologicalEventQuerySortThenBy
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QSortThenBy> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByImpactHorizon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impactHorizon', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByImpactHorizonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impactHorizon', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByIsReversible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReversible', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByIsReversibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReversible', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByRegisteredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySerializedPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedPayload', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySerializedPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedPayload', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarBiologicalEventQueryWhereDistinct
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct> {
  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByEventType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByImpactHorizon({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'impactHorizon',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByIsReversible() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReversible');
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurredAt');
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'registeredAt');
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctBySerializedPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serializedPayload',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctBySeverity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctBySource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarBiologicalEventQueryProperty
    on QueryBuilder<IsarBiologicalEvent, IsarBiologicalEvent, QQueryProperty> {
  QueryBuilder<IsarBiologicalEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarBiologicalEvent, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations>
      eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations>
      eventTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventType');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations>
      impactHorizonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'impactHorizon');
    });
  }

  QueryBuilder<IsarBiologicalEvent, bool, QQueryOperations>
      isReversibleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReversible');
    });
  }

  QueryBuilder<IsarBiologicalEvent, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<IsarBiologicalEvent, DateTime, QQueryOperations>
      occurredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurredAt');
    });
  }

  QueryBuilder<IsarBiologicalEvent, DateTime, QQueryOperations>
      registeredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'registeredAt');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations>
      serializedPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serializedPayload');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations>
      severityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severity');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<IsarBiologicalEvent, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarRecommendationCollection on Isar {
  IsarCollection<IsarRecommendation> get isarRecommendations =>
      this.collection();
}

const IsarRecommendationSchema = CollectionSchema(
  name: r'IsarRecommendation',
  id: -9162009957948134783,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'evidenceCitations': PropertySchema(
      id: 2,
      name: r'evidenceCitations',
      type: IsarType.stringList,
    ),
    r'expiresAt': PropertySchema(
      id: 3,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'generatedAt': PropertySchema(
      id: 4,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'missingData': PropertySchema(
      id: 6,
      name: r'missingData',
      type: IsarType.stringList,
    ),
    r'reasoningChain': PropertySchema(
      id: 7,
      name: r'reasoningChain',
      type: IsarType.stringList,
    ),
    r'recommendationId': PropertySchema(
      id: 8,
      name: r'recommendationId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'supportingObservations': PropertySchema(
      id: 10,
      name: r'supportingObservations',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 13,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarRecommendationEstimateSize,
  serialize: _isarRecommendationSerialize,
  deserialize: _isarRecommendationDeserialize,
  deserializeProp: _isarRecommendationDeserializeProp,
  idName: r'id',
  indexes: {
    r'recommendationId': IndexSchema(
      id: -8056539292150424131,
      name: r'recommendationId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recommendationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarRecommendationGetId,
  getLinks: _isarRecommendationGetLinks,
  attach: _isarRecommendationAttach,
  version: '3.1.0+1',
);

int _isarRecommendationEstimateSize(
  IsarRecommendation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.evidenceCitations.length * 3;
  {
    for (var i = 0; i < object.evidenceCitations.length; i++) {
      final value = object.evidenceCitations[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.missingData.length * 3;
  {
    for (var i = 0; i < object.missingData.length; i++) {
      final value = object.missingData[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.reasoningChain.length * 3;
  {
    for (var i = 0; i < object.reasoningChain.length; i++) {
      final value = object.reasoningChain[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.recommendationId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.supportingObservations.length * 3;
  {
    for (var i = 0; i < object.supportingObservations.length; i++) {
      final value = object.supportingObservations[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _isarRecommendationSerialize(
  IsarRecommendation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeString(offsets[1], object.description);
  writer.writeStringList(offsets[2], object.evidenceCitations);
  writer.writeDateTime(offsets[3], object.expiresAt);
  writer.writeDateTime(offsets[4], object.generatedAt);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeStringList(offsets[6], object.missingData);
  writer.writeStringList(offsets[7], object.reasoningChain);
  writer.writeString(offsets[8], object.recommendationId);
  writer.writeString(offsets[9], object.status);
  writer.writeStringList(offsets[10], object.supportingObservations);
  writer.writeString(offsets[11], object.title);
  writer.writeString(offsets[12], object.type);
  writer.writeString(offsets[13], object.userId);
}

IsarRecommendation _isarRecommendationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarRecommendation();
  object.confidence = reader.readDouble(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.evidenceCitations = reader.readStringList(offsets[2]) ?? [];
  object.expiresAt = reader.readDateTime(offsets[3]);
  object.generatedAt = reader.readDateTime(offsets[4]);
  object.isSynced = reader.readBool(offsets[5]);
  object.missingData = reader.readStringList(offsets[6]) ?? [];
  object.reasoningChain = reader.readStringList(offsets[7]) ?? [];
  object.recommendationId = reader.readString(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.supportingObservations = reader.readStringList(offsets[10]) ?? [];
  object.title = reader.readString(offsets[11]);
  object.type = reader.readString(offsets[12]);
  object.userId = reader.readString(offsets[13]);
  return object;
}

P _isarRecommendationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarRecommendationGetId(IsarRecommendation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarRecommendationGetLinks(
    IsarRecommendation object) {
  return [];
}

void _isarRecommendationAttach(
    IsarCollection<dynamic> col, Id id, IsarRecommendation object) {}

extension IsarRecommendationByIndex on IsarCollection<IsarRecommendation> {
  Future<IsarRecommendation?> getByRecommendationId(String recommendationId) {
    return getByIndex(r'recommendationId', [recommendationId]);
  }

  IsarRecommendation? getByRecommendationIdSync(String recommendationId) {
    return getByIndexSync(r'recommendationId', [recommendationId]);
  }

  Future<bool> deleteByRecommendationId(String recommendationId) {
    return deleteByIndex(r'recommendationId', [recommendationId]);
  }

  bool deleteByRecommendationIdSync(String recommendationId) {
    return deleteByIndexSync(r'recommendationId', [recommendationId]);
  }

  Future<List<IsarRecommendation?>> getAllByRecommendationId(
      List<String> recommendationIdValues) {
    final values = recommendationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recommendationId', values);
  }

  List<IsarRecommendation?> getAllByRecommendationIdSync(
      List<String> recommendationIdValues) {
    final values = recommendationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'recommendationId', values);
  }

  Future<int> deleteAllByRecommendationId(List<String> recommendationIdValues) {
    final values = recommendationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'recommendationId', values);
  }

  int deleteAllByRecommendationIdSync(List<String> recommendationIdValues) {
    final values = recommendationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'recommendationId', values);
  }

  Future<Id> putByRecommendationId(IsarRecommendation object) {
    return putByIndex(r'recommendationId', object);
  }

  Id putByRecommendationIdSync(IsarRecommendation object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'recommendationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecommendationId(List<IsarRecommendation> objects) {
    return putAllByIndex(r'recommendationId', objects);
  }

  List<Id> putAllByRecommendationIdSync(List<IsarRecommendation> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recommendationId', objects,
        saveLinks: saveLinks);
  }
}

extension IsarRecommendationQueryWhereSort
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QWhere> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension IsarRecommendationQueryWhere
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QWhereClause> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      recommendationIdEqualTo(String recommendationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recommendationId',
        value: [recommendationId],
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      recommendationIdNotEqualTo(String recommendationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recommendationId',
              lower: [],
              upper: [recommendationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recommendationId',
              lower: [recommendationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recommendationId',
              lower: [recommendationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recommendationId',
              lower: [],
              upper: [recommendationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarRecommendationQueryFilter
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QFilterCondition> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'evidenceCitations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'evidenceCitations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'evidenceCitations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceCitations',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'evidenceCitations',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      evidenceCitationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceCitations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      expiresAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      expiresAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      expiresAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      expiresAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      generatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      generatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missingData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missingData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missingData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missingData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missingData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      missingDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'missingData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reasoningChain',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reasoningChain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reasoningChain',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasoningChain',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reasoningChain',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      reasoningChainLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reasoningChain',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendationId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      recommendationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendationId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supportingObservations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supportingObservations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supportingObservations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supportingObservations',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supportingObservations',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      supportingObservationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supportingObservations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension IsarRecommendationQueryObject
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QFilterCondition> {}

extension IsarRecommendationQueryLinks
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QFilterCondition> {}

extension IsarRecommendationQuerySortBy
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QSortBy> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByRecommendationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendationId', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByRecommendationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendationId', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarRecommendationQuerySortThenBy
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QSortThenBy> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByRecommendationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendationId', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByRecommendationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendationId', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarRecommendationQueryWhereDistinct
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct> {
  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByEvidenceCitations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evidenceCitations');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByMissingData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missingData');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByReasoningChain() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reasoningChain');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByRecommendationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctBySupportingObservations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supportingObservations');
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecommendation, IsarRecommendation, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarRecommendationQueryProperty
    on QueryBuilder<IsarRecommendation, IsarRecommendation, QQueryProperty> {
  QueryBuilder<IsarRecommendation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarRecommendation, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<IsarRecommendation, List<String>, QQueryOperations>
      evidenceCitationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evidenceCitations');
    });
  }

  QueryBuilder<IsarRecommendation, DateTime, QQueryOperations>
      expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<IsarRecommendation, DateTime, QQueryOperations>
      generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<IsarRecommendation, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<IsarRecommendation, List<String>, QQueryOperations>
      missingDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missingData');
    });
  }

  QueryBuilder<IsarRecommendation, List<String>, QQueryOperations>
      reasoningChainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reasoningChain');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations>
      recommendationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendationId');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarRecommendation, List<String>, QQueryOperations>
      supportingObservationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supportingObservations');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<IsarRecommendation, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarWearableSnapshotCollection on Isar {
  IsarCollection<IsarWearableSnapshot> get isarWearableSnapshots =>
      this.collection();
}

const IsarWearableSnapshotSchema = CollectionSchema(
  name: r'IsarWearableSnapshot',
  id: 4232046679045198268,
  properties: {
    r'processedByEngine': PropertySchema(
      id: 0,
      name: r'processedByEngine',
      type: IsarType.bool,
    ),
    r'rawJsonPayload': PropertySchema(
      id: 1,
      name: r'rawJsonPayload',
      type: IsarType.string,
    ),
    r'snapshotTime': PropertySchema(
      id: 2,
      name: r'snapshotTime',
      type: IsarType.dateTime,
    ),
    r'source': PropertySchema(
      id: 3,
      name: r'source',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarWearableSnapshotEstimateSize,
  serialize: _isarWearableSnapshotSerialize,
  deserialize: _isarWearableSnapshotDeserialize,
  deserializeProp: _isarWearableSnapshotDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'processedByEngine': IndexSchema(
      id: -8884642815061099715,
      name: r'processedByEngine',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'processedByEngine',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarWearableSnapshotGetId,
  getLinks: _isarWearableSnapshotGetLinks,
  attach: _isarWearableSnapshotAttach,
  version: '3.1.0+1',
);

int _isarWearableSnapshotEstimateSize(
  IsarWearableSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _isarWearableSnapshotSerialize(
  IsarWearableSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.processedByEngine);
  writer.writeString(offsets[1], object.rawJsonPayload);
  writer.writeDateTime(offsets[2], object.snapshotTime);
  writer.writeString(offsets[3], object.source);
  writer.writeString(offsets[4], object.userId);
}

IsarWearableSnapshot _isarWearableSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarWearableSnapshot();
  object.processedByEngine = reader.readBool(offsets[0]);
  object.rawJsonPayload = reader.readString(offsets[1]);
  object.snapshotTime = reader.readDateTime(offsets[2]);
  object.source = reader.readString(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _isarWearableSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarWearableSnapshotGetId(IsarWearableSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarWearableSnapshotGetLinks(
    IsarWearableSnapshot object) {
  return [];
}

void _isarWearableSnapshotAttach(
    IsarCollection<dynamic> col, Id id, IsarWearableSnapshot object) {}

extension IsarWearableSnapshotQueryWhereSort
    on QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QWhere> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhere>
      anyProcessedByEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'processedByEngine'),
      );
    });
  }
}

extension IsarWearableSnapshotQueryWhere
    on QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QWhereClause> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      processedByEngineEqualTo(bool processedByEngine) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'processedByEngine',
        value: [processedByEngine],
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterWhereClause>
      processedByEngineNotEqualTo(bool processedByEngine) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'processedByEngine',
              lower: [],
              upper: [processedByEngine],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'processedByEngine',
              lower: [processedByEngine],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'processedByEngine',
              lower: [processedByEngine],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'processedByEngine',
              lower: [],
              upper: [processedByEngine],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarWearableSnapshotQueryFilter on QueryBuilder<IsarWearableSnapshot,
    IsarWearableSnapshot, QFilterCondition> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> processedByEngineEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedByEngine',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawJsonPayload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      rawJsonPayloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      rawJsonPayloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawJsonPayload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJsonPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> rawJsonPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawJsonPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> snapshotTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snapshotTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> snapshotTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snapshotTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> snapshotTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snapshotTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> snapshotTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snapshotTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension IsarWearableSnapshotQueryObject on QueryBuilder<IsarWearableSnapshot,
    IsarWearableSnapshot, QFilterCondition> {}

extension IsarWearableSnapshotQueryLinks on QueryBuilder<IsarWearableSnapshot,
    IsarWearableSnapshot, QFilterCondition> {}

extension IsarWearableSnapshotQuerySortBy
    on QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QSortBy> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByProcessedByEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedByEngine', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByProcessedByEngineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedByEngine', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortBySnapshotTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotTime', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortBySnapshotTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotTime', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarWearableSnapshotQuerySortThenBy
    on QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QSortThenBy> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByProcessedByEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedByEngine', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByProcessedByEngineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedByEngine', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenBySnapshotTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotTime', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenBySnapshotTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotTime', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarWearableSnapshotQueryWhereDistinct
    on QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct> {
  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct>
      distinctByProcessedByEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedByEngine');
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct>
      distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawJsonPayload',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct>
      distinctBySnapshotTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snapshotTime');
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct>
      distinctBySource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWearableSnapshot, IsarWearableSnapshot, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarWearableSnapshotQueryProperty on QueryBuilder<
    IsarWearableSnapshot, IsarWearableSnapshot, QQueryProperty> {
  QueryBuilder<IsarWearableSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarWearableSnapshot, bool, QQueryOperations>
      processedByEngineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedByEngine');
    });
  }

  QueryBuilder<IsarWearableSnapshot, String, QQueryOperations>
      rawJsonPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJsonPayload');
    });
  }

  QueryBuilder<IsarWearableSnapshot, DateTime, QQueryOperations>
      snapshotTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snapshotTime');
    });
  }

  QueryBuilder<IsarWearableSnapshot, String, QQueryOperations>
      sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<IsarWearableSnapshot, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarSyncJobCollection on Isar {
  IsarCollection<IsarSyncJob> get isarSyncJobs => this.collection();
}

const IsarSyncJobSchema = CollectionSchema(
  name: r'IsarSyncJob',
  id: -2123335418711345851,
  properties: {
    r'collectionName': PropertySchema(
      id: 0,
      name: r'collectionName',
      type: IsarType.string,
    ),
    r'operation': PropertySchema(
      id: 1,
      name: r'operation',
      type: IsarType.string,
    ),
    r'queuedAt': PropertySchema(
      id: 2,
      name: r'queuedAt',
      type: IsarType.dateTime,
    ),
    r'recordId': PropertySchema(
      id: 3,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 4,
      name: r'retryCount',
      type: IsarType.long,
    )
  },
  estimateSize: _isarSyncJobEstimateSize,
  serialize: _isarSyncJobSerialize,
  deserialize: _isarSyncJobDeserialize,
  deserializeProp: _isarSyncJobDeserializeProp,
  idName: r'id',
  indexes: {
    r'collectionName': IndexSchema(
      id: -4238329797778617380,
      name: r'collectionName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectionName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarSyncJobGetId,
  getLinks: _isarSyncJobGetLinks,
  attach: _isarSyncJobAttach,
  version: '3.1.0+1',
);

int _isarSyncJobEstimateSize(
  IsarSyncJob object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionName.length * 3;
  bytesCount += 3 + object.operation.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  return bytesCount;
}

void _isarSyncJobSerialize(
  IsarSyncJob object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collectionName);
  writer.writeString(offsets[1], object.operation);
  writer.writeDateTime(offsets[2], object.queuedAt);
  writer.writeString(offsets[3], object.recordId);
  writer.writeLong(offsets[4], object.retryCount);
}

IsarSyncJob _isarSyncJobDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarSyncJob();
  object.collectionName = reader.readString(offsets[0]);
  object.operation = reader.readString(offsets[1]);
  object.queuedAt = reader.readDateTime(offsets[2]);
  object.recordId = reader.readString(offsets[3]);
  object.retryCount = reader.readLong(offsets[4]);
  return object;
}

P _isarSyncJobDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarSyncJobGetId(IsarSyncJob object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarSyncJobGetLinks(IsarSyncJob object) {
  return [];
}

void _isarSyncJobAttach(
    IsarCollection<dynamic> col, Id id, IsarSyncJob object) {}

extension IsarSyncJobQueryWhereSort
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QWhere> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarSyncJobQueryWhere
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QWhereClause> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause>
      collectionNameEqualTo(String collectionName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionName',
        value: [collectionName],
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterWhereClause>
      collectionNameNotEqualTo(String collectionName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionName',
              lower: [],
              upper: [collectionName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionName',
              lower: [collectionName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionName',
              lower: [collectionName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionName',
              lower: [],
              upper: [collectionName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarSyncJobQueryFilter
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QFilterCondition> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      collectionNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> queuedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      queuedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      queuedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> queuedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'queuedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> recordIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> recordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> recordIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
      retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarSyncJobQueryObject
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QFilterCondition> {}

extension IsarSyncJobQueryLinks
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QFilterCondition> {}

extension IsarSyncJobQuerySortBy
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QSortBy> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByCollectionName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionName', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy>
      sortByCollectionNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionName', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }
}

extension IsarSyncJobQuerySortThenBy
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QSortThenBy> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByCollectionName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionName', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy>
      thenByCollectionNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionName', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }
}

extension IsarSyncJobQueryWhereDistinct
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> distinctByCollectionName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> distinctByOperation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> distinctByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queuedAt');
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> distinctByRecordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }
}

extension IsarSyncJobQueryProperty
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QQueryProperty> {
  QueryBuilder<IsarSyncJob, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarSyncJob, String, QQueryOperations> collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionName');
    });
  }

  QueryBuilder<IsarSyncJob, String, QQueryOperations> operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }

  QueryBuilder<IsarSyncJob, DateTime, QQueryOperations> queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queuedAt');
    });
  }

  QueryBuilder<IsarSyncJob, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<IsarSyncJob, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarConflictCollection on Isar {
  IsarCollection<IsarConflict> get isarConflicts => this.collection();
}

const IsarConflictSchema = CollectionSchema(
  name: r'IsarConflict',
  id: -738896201470974933,
  properties: {
    r'cloudData': PropertySchema(
      id: 0,
      name: r'cloudData',
      type: IsarType.string,
    ),
    r'detectedAt': PropertySchema(
      id: 1,
      name: r'detectedAt',
      type: IsarType.dateTime,
    ),
    r'entityId': PropertySchema(
      id: 2,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 3,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'localData': PropertySchema(
      id: 4,
      name: r'localData',
      type: IsarType.string,
    )
  },
  estimateSize: _isarConflictEstimateSize,
  serialize: _isarConflictSerialize,
  deserialize: _isarConflictDeserialize,
  deserializeProp: _isarConflictDeserializeProp,
  idName: r'id',
  indexes: {
    r'entityId': IndexSchema(
      id: 745355021660786263,
      name: r'entityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarConflictGetId,
  getLinks: _isarConflictGetLinks,
  attach: _isarConflictAttach,
  version: '3.1.0+1',
);

int _isarConflictEstimateSize(
  IsarConflict object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cloudData.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.localData.length * 3;
  return bytesCount;
}

void _isarConflictSerialize(
  IsarConflict object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cloudData);
  writer.writeDateTime(offsets[1], object.detectedAt);
  writer.writeString(offsets[2], object.entityId);
  writer.writeString(offsets[3], object.entityType);
  writer.writeString(offsets[4], object.localData);
}

IsarConflict _isarConflictDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarConflict();
  object.cloudData = reader.readString(offsets[0]);
  object.detectedAt = reader.readDateTime(offsets[1]);
  object.entityId = reader.readString(offsets[2]);
  object.entityType = reader.readString(offsets[3]);
  object.localData = reader.readString(offsets[4]);
  return object;
}

P _isarConflictDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarConflictGetId(IsarConflict object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarConflictGetLinks(IsarConflict object) {
  return [];
}

void _isarConflictAttach(
    IsarCollection<dynamic> col, Id id, IsarConflict object) {}

extension IsarConflictQueryWhereSort
    on QueryBuilder<IsarConflict, IsarConflict, QWhere> {
  QueryBuilder<IsarConflict, IsarConflict, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarConflictQueryWhere
    on QueryBuilder<IsarConflict, IsarConflict, QWhereClause> {
  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause> entityIdEqualTo(
      String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityId',
        value: [entityId],
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterWhereClause>
      entityIdNotEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarConflictQueryFilter
    on QueryBuilder<IsarConflict, IsarConflict, QFilterCondition> {
  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cloudData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cloudData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cloudData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      cloudDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cloudData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      detectedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      detectedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      detectedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      detectedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localData',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterFilterCondition>
      localDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localData',
        value: '',
      ));
    });
  }
}

extension IsarConflictQueryObject
    on QueryBuilder<IsarConflict, IsarConflict, QFilterCondition> {}

extension IsarConflictQueryLinks
    on QueryBuilder<IsarConflict, IsarConflict, QFilterCondition> {}

extension IsarConflictQuerySortBy
    on QueryBuilder<IsarConflict, IsarConflict, QSortBy> {
  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByCloudData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudData', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByCloudDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudData', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy>
      sortByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByLocalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localData', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> sortByLocalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localData', Sort.desc);
    });
  }
}

extension IsarConflictQuerySortThenBy
    on QueryBuilder<IsarConflict, IsarConflict, QSortThenBy> {
  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByCloudData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudData', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByCloudDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudData', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy>
      thenByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByLocalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localData', Sort.asc);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QAfterSortBy> thenByLocalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localData', Sort.desc);
    });
  }
}

extension IsarConflictQueryWhereDistinct
    on QueryBuilder<IsarConflict, IsarConflict, QDistinct> {
  QueryBuilder<IsarConflict, IsarConflict, QDistinct> distinctByCloudData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QDistinct> distinctByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detectedAt');
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QDistinct> distinctByEntityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QDistinct> distinctByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarConflict, IsarConflict, QDistinct> distinctByLocalData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localData', caseSensitive: caseSensitive);
    });
  }
}

extension IsarConflictQueryProperty
    on QueryBuilder<IsarConflict, IsarConflict, QQueryProperty> {
  QueryBuilder<IsarConflict, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarConflict, String, QQueryOperations> cloudDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudData');
    });
  }

  QueryBuilder<IsarConflict, DateTime, QQueryOperations> detectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detectedAt');
    });
  }

  QueryBuilder<IsarConflict, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<IsarConflict, String, QQueryOperations> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarConflict, String, QQueryOperations> localDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localData');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTimelineFragmentCollection on Isar {
  IsarCollection<IsarTimelineFragment> get isarTimelineFragments =>
      this.collection();
}

const IsarTimelineFragmentSchema = CollectionSchema(
  name: r'IsarTimelineFragment',
  id: 5560753937422871241,
  properties: {
    r'periodEnd': PropertySchema(
      id: 0,
      name: r'periodEnd',
      type: IsarType.dateTime,
    ),
    r'periodStart': PropertySchema(
      id: 1,
      name: r'periodStart',
      type: IsarType.dateTime,
    ),
    r'serializedFragment': PropertySchema(
      id: 2,
      name: r'serializedFragment',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarTimelineFragmentEstimateSize,
  serialize: _isarTimelineFragmentSerialize,
  deserialize: _isarTimelineFragmentDeserialize,
  deserializeProp: _isarTimelineFragmentDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarTimelineFragmentGetId,
  getLinks: _isarTimelineFragmentGetLinks,
  attach: _isarTimelineFragmentAttach,
  version: '3.1.0+1',
);

int _isarTimelineFragmentEstimateSize(
  IsarTimelineFragment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.serializedFragment.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _isarTimelineFragmentSerialize(
  IsarTimelineFragment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.periodEnd);
  writer.writeDateTime(offsets[1], object.periodStart);
  writer.writeString(offsets[2], object.serializedFragment);
  writer.writeString(offsets[3], object.userId);
}

IsarTimelineFragment _isarTimelineFragmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTimelineFragment();
  object.periodEnd = reader.readDateTime(offsets[0]);
  object.periodStart = reader.readDateTime(offsets[1]);
  object.serializedFragment = reader.readString(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _isarTimelineFragmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTimelineFragmentGetId(IsarTimelineFragment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTimelineFragmentGetLinks(
    IsarTimelineFragment object) {
  return [];
}

void _isarTimelineFragmentAttach(
    IsarCollection<dynamic> col, Id id, IsarTimelineFragment object) {}

extension IsarTimelineFragmentQueryWhereSort
    on QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QWhere> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTimelineFragmentQueryWhere
    on QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QWhereClause> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarTimelineFragmentQueryFilter on QueryBuilder<IsarTimelineFragment,
    IsarTimelineFragment, QFilterCondition> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodEndGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodEndLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodEndBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodStart',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodStartGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodStart',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodStartLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodStart',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> periodStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serializedFragment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
          QAfterFilterCondition>
      serializedFragmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serializedFragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
          QAfterFilterCondition>
      serializedFragmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serializedFragment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedFragment',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> serializedFragmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serializedFragment',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension IsarTimelineFragmentQueryObject on QueryBuilder<IsarTimelineFragment,
    IsarTimelineFragment, QFilterCondition> {}

extension IsarTimelineFragmentQueryLinks on QueryBuilder<IsarTimelineFragment,
    IsarTimelineFragment, QFilterCondition> {}

extension IsarTimelineFragmentQuerySortBy
    on QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QSortBy> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortBySerializedFragment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedFragment', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortBySerializedFragmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedFragment', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarTimelineFragmentQuerySortThenBy
    on QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QSortThenBy> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenBySerializedFragment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedFragment', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenBySerializedFragmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedFragment', Sort.desc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension IsarTimelineFragmentQueryWhereDistinct
    on QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QDistinct> {
  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QDistinct>
      distinctByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodEnd');
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QDistinct>
      distinctByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodStart');
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QDistinct>
      distinctBySerializedFragment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serializedFragment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTimelineFragment, IsarTimelineFragment, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarTimelineFragmentQueryProperty on QueryBuilder<
    IsarTimelineFragment, IsarTimelineFragment, QQueryProperty> {
  QueryBuilder<IsarTimelineFragment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTimelineFragment, DateTime, QQueryOperations>
      periodEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodEnd');
    });
  }

  QueryBuilder<IsarTimelineFragment, DateTime, QQueryOperations>
      periodStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodStart');
    });
  }

  QueryBuilder<IsarTimelineFragment, String, QQueryOperations>
      serializedFragmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serializedFragment');
    });
  }

  QueryBuilder<IsarTimelineFragment, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarUncertaintySnapshotCollection on Isar {
  IsarCollection<IsarUncertaintySnapshot> get isarUncertaintySnapshots =>
      this.collection();
}

const IsarUncertaintySnapshotSchema = CollectionSchema(
  name: r'IsarUncertaintySnapshot',
  id: -3703489132548372712,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'posteriorUncertainty': PropertySchema(
      id: 1,
      name: r'posteriorUncertainty',
      type: IsarType.double,
    ),
    r'priorUncertainty': PropertySchema(
      id: 2,
      name: r'priorUncertainty',
      type: IsarType.double,
    ),
    r'stateId': PropertySchema(
      id: 3,
      name: r'stateId',
      type: IsarType.string,
    ),
    r'triggerEventId': PropertySchema(
      id: 4,
      name: r'triggerEventId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarUncertaintySnapshotEstimateSize,
  serialize: _isarUncertaintySnapshotSerialize,
  deserialize: _isarUncertaintySnapshotDeserialize,
  deserializeProp: _isarUncertaintySnapshotDeserializeProp,
  idName: r'id',
  indexes: {
    r'stateId': IndexSchema(
      id: -1428154555284842722,
      name: r'stateId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stateId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarUncertaintySnapshotGetId,
  getLinks: _isarUncertaintySnapshotGetLinks,
  attach: _isarUncertaintySnapshotAttach,
  version: '3.1.0+1',
);

int _isarUncertaintySnapshotEstimateSize(
  IsarUncertaintySnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.stateId.length * 3;
  bytesCount += 3 + object.triggerEventId.length * 3;
  return bytesCount;
}

void _isarUncertaintySnapshotSerialize(
  IsarUncertaintySnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeDouble(offsets[1], object.posteriorUncertainty);
  writer.writeDouble(offsets[2], object.priorUncertainty);
  writer.writeString(offsets[3], object.stateId);
  writer.writeString(offsets[4], object.triggerEventId);
}

IsarUncertaintySnapshot _isarUncertaintySnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarUncertaintySnapshot();
  object.capturedAt = reader.readDateTime(offsets[0]);
  object.posteriorUncertainty = reader.readDouble(offsets[1]);
  object.priorUncertainty = reader.readDouble(offsets[2]);
  object.stateId = reader.readString(offsets[3]);
  object.triggerEventId = reader.readString(offsets[4]);
  return object;
}

P _isarUncertaintySnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarUncertaintySnapshotGetId(IsarUncertaintySnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarUncertaintySnapshotGetLinks(
    IsarUncertaintySnapshot object) {
  return [];
}

void _isarUncertaintySnapshotAttach(
    IsarCollection<dynamic> col, Id id, IsarUncertaintySnapshot object) {}

extension IsarUncertaintySnapshotQueryWhereSort
    on QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QWhere> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarUncertaintySnapshotQueryWhere on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QWhereClause> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> stateIdEqualTo(String stateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stateId',
        value: [stateId],
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterWhereClause> stateIdNotEqualTo(String stateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [],
              upper: [stateId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [stateId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [stateId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stateId',
              lower: [],
              upper: [stateId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarUncertaintySnapshotQueryFilter on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QFilterCondition> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> capturedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> capturedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> capturedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capturedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> posteriorUncertaintyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'posteriorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> posteriorUncertaintyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'posteriorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> posteriorUncertaintyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'posteriorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> posteriorUncertaintyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'posteriorUncertainty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> priorUncertaintyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> priorUncertaintyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> priorUncertaintyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priorUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> priorUncertaintyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priorUncertainty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
          QAfterFilterCondition>
      stateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
          QAfterFilterCondition>
      stateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> stateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerEventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
          QAfterFilterCondition>
      triggerEventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
          QAfterFilterCondition>
      triggerEventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerEventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot,
      QAfterFilterCondition> triggerEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerEventId',
        value: '',
      ));
    });
  }
}

extension IsarUncertaintySnapshotQueryObject on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QFilterCondition> {}

extension IsarUncertaintySnapshotQueryLinks on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QFilterCondition> {}

extension IsarUncertaintySnapshotQuerySortBy
    on QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QSortBy> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByPosteriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posteriorUncertainty', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByPosteriorUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posteriorUncertainty', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByPriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorUncertainty', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByPriorUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorUncertainty', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByStateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByStateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByTriggerEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerEventId', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      sortByTriggerEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerEventId', Sort.desc);
    });
  }
}

extension IsarUncertaintySnapshotQuerySortThenBy on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QSortThenBy> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByPosteriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posteriorUncertainty', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByPosteriorUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posteriorUncertainty', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByPriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorUncertainty', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByPriorUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorUncertainty', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByStateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByStateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateId', Sort.desc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByTriggerEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerEventId', Sort.asc);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QAfterSortBy>
      thenByTriggerEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerEventId', Sort.desc);
    });
  }
}

extension IsarUncertaintySnapshotQueryWhereDistinct on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct> {
  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct>
      distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct>
      distinctByPosteriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'posteriorUncertainty');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct>
      distinctByPriorUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priorUncertainty');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct>
      distinctByStateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, IsarUncertaintySnapshot, QDistinct>
      distinctByTriggerEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerEventId',
          caseSensitive: caseSensitive);
    });
  }
}

extension IsarUncertaintySnapshotQueryProperty on QueryBuilder<
    IsarUncertaintySnapshot, IsarUncertaintySnapshot, QQueryProperty> {
  QueryBuilder<IsarUncertaintySnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, DateTime, QQueryOperations>
      capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, double, QQueryOperations>
      posteriorUncertaintyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'posteriorUncertainty');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, double, QQueryOperations>
      priorUncertaintyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priorUncertainty');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, String, QQueryOperations>
      stateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateId');
    });
  }

  QueryBuilder<IsarUncertaintySnapshot, String, QQueryOperations>
      triggerEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerEventId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarHealthIdentityCollection on Isar {
  IsarCollection<IsarHealthIdentity> get isarHealthIdentitys =>
      this.collection();
}

const IsarHealthIdentitySchema = CollectionSchema(
  name: r'IsarHealthIdentity',
  id: 8484946092595044958,
  properties: {
    r'activityLevel': PropertySchema(
      id: 0,
      name: r'activityLevel',
      type: IsarType.string,
    ),
    r'age': PropertySchema(
      id: 1,
      name: r'age',
      type: IsarType.long,
    ),
    r'alcohol': PropertySchema(
      id: 2,
      name: r'alcohol',
      type: IsarType.string,
    ),
    r'city': PropertySchema(
      id: 3,
      name: r'city',
      type: IsarType.string,
    ),
    r'country': PropertySchema(
      id: 4,
      name: r'country',
      type: IsarType.string,
    ),
    r'dietPreference': PropertySchema(
      id: 5,
      name: r'dietPreference',
      type: IsarType.string,
    ),
    r'exercise': PropertySchema(
      id: 6,
      name: r'exercise',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 7,
      name: r'gender',
      type: IsarType.string,
    ),
    r'hasBloodPressureRisk': PropertySchema(
      id: 8,
      name: r'hasBloodPressureRisk',
      type: IsarType.bool,
    ),
    r'hasCancerRisk': PropertySchema(
      id: 9,
      name: r'hasCancerRisk',
      type: IsarType.bool,
    ),
    r'hasDiabetesRisk': PropertySchema(
      id: 10,
      name: r'hasDiabetesRisk',
      type: IsarType.bool,
    ),
    r'hasHeartDiseaseRisk': PropertySchema(
      id: 11,
      name: r'hasHeartDiseaseRisk',
      type: IsarType.bool,
    ),
    r'hasThyroidRisk': PropertySchema(
      id: 12,
      name: r'hasThyroidRisk',
      type: IsarType.bool,
    ),
    r'height': PropertySchema(
      id: 13,
      name: r'height',
      type: IsarType.double,
    ),
    r'mealTiming': PropertySchema(
      id: 14,
      name: r'mealTiming',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 15,
      name: r'name',
      type: IsarType.string,
    ),
    r'occupation': PropertySchema(
      id: 16,
      name: r'occupation',
      type: IsarType.string,
    ),
    r'primaryGoal': PropertySchema(
      id: 17,
      name: r'primaryGoal',
      type: IsarType.string,
    ),
    r'sleepTime': PropertySchema(
      id: 18,
      name: r'sleepTime',
      type: IsarType.string,
    ),
    r'smoking': PropertySchema(
      id: 19,
      name: r'smoking',
      type: IsarType.string,
    ),
    r'stressLevel': PropertySchema(
      id: 20,
      name: r'stressLevel',
      type: IsarType.long,
    ),
    r'supplements': PropertySchema(
      id: 21,
      name: r'supplements',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 22,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 23,
      name: r'userId',
      type: IsarType.string,
    ),
    r'wakeTime': PropertySchema(
      id: 24,
      name: r'wakeTime',
      type: IsarType.string,
    ),
    r'waterIntake': PropertySchema(
      id: 25,
      name: r'waterIntake',
      type: IsarType.double,
    ),
    r'weight': PropertySchema(
      id: 26,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _isarHealthIdentityEstimateSize,
  serialize: _isarHealthIdentitySerialize,
  deserialize: _isarHealthIdentityDeserialize,
  deserializeProp: _isarHealthIdentityDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarHealthIdentityGetId,
  getLinks: _isarHealthIdentityGetLinks,
  attach: _isarHealthIdentityAttach,
  version: '3.1.0+1',
);

int _isarHealthIdentityEstimateSize(
  IsarHealthIdentity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activityLevel.length * 3;
  bytesCount += 3 + object.alcohol.length * 3;
  bytesCount += 3 + object.city.length * 3;
  bytesCount += 3 + object.country.length * 3;
  bytesCount += 3 + object.dietPreference.length * 3;
  bytesCount += 3 + object.exercise.length * 3;
  bytesCount += 3 + object.gender.length * 3;
  bytesCount += 3 + object.mealTiming.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.occupation.length * 3;
  bytesCount += 3 + object.primaryGoal.length * 3;
  bytesCount += 3 + object.sleepTime.length * 3;
  bytesCount += 3 + object.smoking.length * 3;
  bytesCount += 3 + object.supplements.length * 3;
  {
    for (var i = 0; i < object.supplements.length; i++) {
      final value = object.supplements[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.wakeTime.length * 3;
  return bytesCount;
}

void _isarHealthIdentitySerialize(
  IsarHealthIdentity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityLevel);
  writer.writeLong(offsets[1], object.age);
  writer.writeString(offsets[2], object.alcohol);
  writer.writeString(offsets[3], object.city);
  writer.writeString(offsets[4], object.country);
  writer.writeString(offsets[5], object.dietPreference);
  writer.writeString(offsets[6], object.exercise);
  writer.writeString(offsets[7], object.gender);
  writer.writeBool(offsets[8], object.hasBloodPressureRisk);
  writer.writeBool(offsets[9], object.hasCancerRisk);
  writer.writeBool(offsets[10], object.hasDiabetesRisk);
  writer.writeBool(offsets[11], object.hasHeartDiseaseRisk);
  writer.writeBool(offsets[12], object.hasThyroidRisk);
  writer.writeDouble(offsets[13], object.height);
  writer.writeString(offsets[14], object.mealTiming);
  writer.writeString(offsets[15], object.name);
  writer.writeString(offsets[16], object.occupation);
  writer.writeString(offsets[17], object.primaryGoal);
  writer.writeString(offsets[18], object.sleepTime);
  writer.writeString(offsets[19], object.smoking);
  writer.writeLong(offsets[20], object.stressLevel);
  writer.writeStringList(offsets[21], object.supplements);
  writer.writeDateTime(offsets[22], object.updatedAt);
  writer.writeString(offsets[23], object.userId);
  writer.writeString(offsets[24], object.wakeTime);
  writer.writeDouble(offsets[25], object.waterIntake);
  writer.writeDouble(offsets[26], object.weight);
}

IsarHealthIdentity _isarHealthIdentityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarHealthIdentity();
  object.activityLevel = reader.readString(offsets[0]);
  object.age = reader.readLong(offsets[1]);
  object.alcohol = reader.readString(offsets[2]);
  object.city = reader.readString(offsets[3]);
  object.country = reader.readString(offsets[4]);
  object.dietPreference = reader.readString(offsets[5]);
  object.exercise = reader.readString(offsets[6]);
  object.gender = reader.readString(offsets[7]);
  object.hasBloodPressureRisk = reader.readBool(offsets[8]);
  object.hasCancerRisk = reader.readBool(offsets[9]);
  object.hasDiabetesRisk = reader.readBool(offsets[10]);
  object.hasHeartDiseaseRisk = reader.readBool(offsets[11]);
  object.hasThyroidRisk = reader.readBool(offsets[12]);
  object.height = reader.readDouble(offsets[13]);
  object.mealTiming = reader.readString(offsets[14]);
  object.name = reader.readString(offsets[15]);
  object.occupation = reader.readString(offsets[16]);
  object.primaryGoal = reader.readString(offsets[17]);
  object.sleepTime = reader.readString(offsets[18]);
  object.smoking = reader.readString(offsets[19]);
  object.stressLevel = reader.readLong(offsets[20]);
  object.supplements = reader.readStringList(offsets[21]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[22]);
  object.userId = reader.readString(offsets[23]);
  object.wakeTime = reader.readString(offsets[24]);
  object.waterIntake = reader.readDouble(offsets[25]);
  object.weight = reader.readDouble(offsets[26]);
  return object;
}

P _isarHealthIdentityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readStringList(offset) ?? []) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarHealthIdentityGetId(IsarHealthIdentity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarHealthIdentityGetLinks(
    IsarHealthIdentity object) {
  return [];
}

void _isarHealthIdentityAttach(
    IsarCollection<dynamic> col, Id id, IsarHealthIdentity object) {}

extension IsarHealthIdentityByIndex on IsarCollection<IsarHealthIdentity> {
  Future<IsarHealthIdentity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  IsarHealthIdentity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<IsarHealthIdentity?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<IsarHealthIdentity?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(IsarHealthIdentity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(IsarHealthIdentity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<IsarHealthIdentity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<IsarHealthIdentity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension IsarHealthIdentityQueryWhereSort
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QWhere> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarHealthIdentityQueryWhere
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QWhereClause> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarHealthIdentityQueryFilter
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QFilterCondition> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      activityLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      ageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      ageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      ageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      ageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alcohol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'alcohol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'alcohol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alcohol',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      alcoholIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'alcohol',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'city',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'city',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      cityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'country',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'country',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietPreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dietPreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietPreference',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      dietPreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dietPreference',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exercise',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exercise',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exercise',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exercise',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      exerciseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exercise',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      hasBloodPressureRiskEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasBloodPressureRisk',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      hasCancerRiskEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasCancerRisk',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      hasDiabetesRiskEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasDiabetesRisk',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      hasHeartDiseaseRiskEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasHeartDiseaseRisk',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      hasThyroidRiskEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasThyroidRisk',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      heightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      heightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      heightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      heightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealTiming',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealTiming',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealTiming',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealTiming',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      mealTimingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealTiming',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occupation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'occupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'occupation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occupation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      occupationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'occupation',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryGoal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      primaryGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sleepTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sleepTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepTime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      sleepTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sleepTime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'smoking',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'smoking',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'smoking',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smoking',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      smokingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'smoking',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      stressLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      stressLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      stressLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      stressLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stressLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supplements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplements',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supplements',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      supplementsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'supplements',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wakeTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wakeTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeTime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      wakeTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wakeTime',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      waterIntakeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterIntake',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      waterIntakeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterIntake',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      waterIntakeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterIntake',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      waterIntakeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterIntake',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterFilterCondition>
      weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarHealthIdentityQueryObject
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QFilterCondition> {}

extension IsarHealthIdentityQueryLinks
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QFilterCondition> {}

extension IsarHealthIdentityQuerySortBy
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QSortBy> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByAlcohol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alcohol', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByAlcoholDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alcohol', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByDietPreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByDietPreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByExercise() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercise', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByExerciseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercise', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasBloodPressureRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBloodPressureRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasBloodPressureRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBloodPressureRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasCancerRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCancerRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasCancerRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCancerRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasDiabetesRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDiabetesRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasDiabetesRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDiabetesRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasHeartDiseaseRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHeartDiseaseRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasHeartDiseaseRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHeartDiseaseRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasThyroidRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroidRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHasThyroidRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroidRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByMealTiming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTiming', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByMealTimingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTiming', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occupation', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occupation', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByPrimaryGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByPrimaryGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortBySleepTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortBySleepTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortBySmoking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smoking', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortBySmokingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smoking', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWaterIntakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension IsarHealthIdentityQuerySortThenBy
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QSortThenBy> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByAlcohol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alcohol', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByAlcoholDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alcohol', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByDietPreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByDietPreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByExercise() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercise', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByExerciseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercise', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasBloodPressureRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBloodPressureRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasBloodPressureRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBloodPressureRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasCancerRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCancerRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasCancerRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCancerRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasDiabetesRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDiabetesRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasDiabetesRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDiabetesRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasHeartDiseaseRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHeartDiseaseRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasHeartDiseaseRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHeartDiseaseRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasThyroidRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroidRisk', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHasThyroidRiskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroidRisk', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByMealTiming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTiming', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByMealTimingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTiming', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occupation', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occupation', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByPrimaryGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByPrimaryGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenBySleepTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenBySleepTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenBySmoking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smoking', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenBySmokingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smoking', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWaterIntakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QAfterSortBy>
      thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension IsarHealthIdentityQueryWhereDistinct
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct> {
  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByActivityLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByAlcohol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alcohol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByCity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'city', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByCountry({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByDietPreference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dietPreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByExercise({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exercise', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByGender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHasBloodPressureRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasBloodPressureRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHasCancerRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCancerRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHasDiabetesRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasDiabetesRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHasHeartDiseaseRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasHeartDiseaseRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHasThyroidRisk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasThyroidRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByMealTiming({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealTiming', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByOccupation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occupation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByPrimaryGoal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryGoal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctBySleepTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctBySmoking({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smoking', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stressLevel');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctBySupplements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplements');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByWakeTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterIntake');
    });
  }

  QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QDistinct>
      distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension IsarHealthIdentityQueryProperty
    on QueryBuilder<IsarHealthIdentity, IsarHealthIdentity, QQueryProperty> {
  QueryBuilder<IsarHealthIdentity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      activityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityLevel');
    });
  }

  QueryBuilder<IsarHealthIdentity, int, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> alcoholProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alcohol');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> cityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'city');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      dietPreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dietPreference');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      exerciseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exercise');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<IsarHealthIdentity, bool, QQueryOperations>
      hasBloodPressureRiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasBloodPressureRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, bool, QQueryOperations>
      hasCancerRiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCancerRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, bool, QQueryOperations>
      hasDiabetesRiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasDiabetesRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, bool, QQueryOperations>
      hasHeartDiseaseRiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasHeartDiseaseRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, bool, QQueryOperations>
      hasThyroidRiskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasThyroidRisk');
    });
  }

  QueryBuilder<IsarHealthIdentity, double, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      mealTimingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealTiming');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      occupationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occupation');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      primaryGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryGoal');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      sleepTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTime');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> smokingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smoking');
    });
  }

  QueryBuilder<IsarHealthIdentity, int, QQueryOperations>
      stressLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stressLevel');
    });
  }

  QueryBuilder<IsarHealthIdentity, List<String>, QQueryOperations>
      supplementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplements');
    });
  }

  QueryBuilder<IsarHealthIdentity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<IsarHealthIdentity, String, QQueryOperations>
      wakeTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeTime');
    });
  }

  QueryBuilder<IsarHealthIdentity, double, QQueryOperations>
      waterIntakeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterIntake');
    });
  }

  QueryBuilder<IsarHealthIdentity, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarUnderstandingGraphNodeCollection on Isar {
  IsarCollection<IsarUnderstandingGraphNode> get isarUnderstandingGraphNodes =>
      this.collection();
}

const IsarUnderstandingGraphNodeSchema = CollectionSchema(
  name: r'IsarUnderstandingGraphNode',
  id: 4756179777329027319,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'nodeId': PropertySchema(
      id: 1,
      name: r'nodeId',
      type: IsarType.string,
    ),
    r'nodeKey': PropertySchema(
      id: 2,
      name: r'nodeKey',
      type: IsarType.string,
    ),
    r'serializedMetadata': PropertySchema(
      id: 3,
      name: r'serializedMetadata',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _isarUnderstandingGraphNodeEstimateSize,
  serialize: _isarUnderstandingGraphNodeSerialize,
  deserialize: _isarUnderstandingGraphNodeDeserialize,
  deserializeProp: _isarUnderstandingGraphNodeDeserializeProp,
  idName: r'id',
  indexes: {
    r'nodeId': IndexSchema(
      id: -6491850230428693976,
      name: r'nodeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nodeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nodeKey': IndexSchema(
      id: -9027598276263798449,
      name: r'nodeKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nodeKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarUnderstandingGraphNodeGetId,
  getLinks: _isarUnderstandingGraphNodeGetLinks,
  attach: _isarUnderstandingGraphNodeAttach,
  version: '3.1.0+1',
);

int _isarUnderstandingGraphNodeEstimateSize(
  IsarUnderstandingGraphNode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.nodeId.length * 3;
  bytesCount += 3 + object.nodeKey.length * 3;
  bytesCount += 3 + object.serializedMetadata.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _isarUnderstandingGraphNodeSerialize(
  IsarUnderstandingGraphNode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.nodeId);
  writer.writeString(offsets[2], object.nodeKey);
  writer.writeString(offsets[3], object.serializedMetadata);
  writer.writeString(offsets[4], object.title);
}

IsarUnderstandingGraphNode _isarUnderstandingGraphNodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarUnderstandingGraphNode();
  object.description = reader.readString(offsets[0]);
  object.nodeId = reader.readString(offsets[1]);
  object.nodeKey = reader.readString(offsets[2]);
  object.serializedMetadata = reader.readString(offsets[3]);
  object.title = reader.readString(offsets[4]);
  return object;
}

P _isarUnderstandingGraphNodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarUnderstandingGraphNodeGetId(IsarUnderstandingGraphNode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarUnderstandingGraphNodeGetLinks(
    IsarUnderstandingGraphNode object) {
  return [];
}

void _isarUnderstandingGraphNodeAttach(
    IsarCollection<dynamic> col, Id id, IsarUnderstandingGraphNode object) {}

extension IsarUnderstandingGraphNodeByIndex
    on IsarCollection<IsarUnderstandingGraphNode> {
  Future<IsarUnderstandingGraphNode?> getByNodeId(String nodeId) {
    return getByIndex(r'nodeId', [nodeId]);
  }

  IsarUnderstandingGraphNode? getByNodeIdSync(String nodeId) {
    return getByIndexSync(r'nodeId', [nodeId]);
  }

  Future<bool> deleteByNodeId(String nodeId) {
    return deleteByIndex(r'nodeId', [nodeId]);
  }

  bool deleteByNodeIdSync(String nodeId) {
    return deleteByIndexSync(r'nodeId', [nodeId]);
  }

  Future<List<IsarUnderstandingGraphNode?>> getAllByNodeId(
      List<String> nodeIdValues) {
    final values = nodeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'nodeId', values);
  }

  List<IsarUnderstandingGraphNode?> getAllByNodeIdSync(
      List<String> nodeIdValues) {
    final values = nodeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nodeId', values);
  }

  Future<int> deleteAllByNodeId(List<String> nodeIdValues) {
    final values = nodeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nodeId', values);
  }

  int deleteAllByNodeIdSync(List<String> nodeIdValues) {
    final values = nodeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nodeId', values);
  }

  Future<Id> putByNodeId(IsarUnderstandingGraphNode object) {
    return putByIndex(r'nodeId', object);
  }

  Id putByNodeIdSync(IsarUnderstandingGraphNode object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'nodeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNodeId(List<IsarUnderstandingGraphNode> objects) {
    return putAllByIndex(r'nodeId', objects);
  }

  List<Id> putAllByNodeIdSync(List<IsarUnderstandingGraphNode> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nodeId', objects, saveLinks: saveLinks);
  }
}

extension IsarUnderstandingGraphNodeQueryWhereSort on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QWhere> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarUnderstandingGraphNodeQueryWhere on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QWhereClause> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> nodeIdEqualTo(String nodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nodeId',
        value: [nodeId],
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> nodeIdNotEqualTo(String nodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [],
              upper: [nodeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [nodeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [nodeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [],
              upper: [nodeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> nodeKeyEqualTo(String nodeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nodeKey',
        value: [nodeKey],
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterWhereClause> nodeKeyNotEqualTo(String nodeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeKey',
              lower: [],
              upper: [nodeKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeKey',
              lower: [nodeKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeKey',
              lower: [nodeKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeKey',
              lower: [],
              upper: [nodeKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarUnderstandingGraphNodeQueryFilter on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QFilterCondition> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      nodeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      nodeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nodeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nodeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      nodeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nodeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      nodeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nodeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> nodeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nodeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serializedMetadata',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      serializedMetadataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serializedMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      serializedMetadataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serializedMetadata',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serializedMetadata',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> serializedMetadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serializedMetadata',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension IsarUnderstandingGraphNodeQueryObject on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QFilterCondition> {}

extension IsarUnderstandingGraphNodeQueryLinks on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QFilterCondition> {}

extension IsarUnderstandingGraphNodeQuerySortBy on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QSortBy> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByNodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeKey', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByNodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeKey', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortBySerializedMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedMetadata', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortBySerializedMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedMetadata', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarUnderstandingGraphNodeQuerySortThenBy on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QSortThenBy> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByNodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeKey', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByNodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeKey', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenBySerializedMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedMetadata', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenBySerializedMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serializedMetadata', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarUnderstandingGraphNodeQueryWhereDistinct on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QDistinct> {
  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QDistinct> distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QDistinct> distinctByNodeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nodeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QDistinct> distinctByNodeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nodeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QDistinct> distinctBySerializedMetadata({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serializedMetadata',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, IsarUnderstandingGraphNode,
      QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension IsarUnderstandingGraphNodeQueryProperty on QueryBuilder<
    IsarUnderstandingGraphNode, IsarUnderstandingGraphNode, QQueryProperty> {
  QueryBuilder<IsarUnderstandingGraphNode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, String, QQueryOperations>
      nodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nodeId');
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, String, QQueryOperations>
      nodeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nodeKey');
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, String, QQueryOperations>
      serializedMetadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serializedMetadata');
    });
  }

  QueryBuilder<IsarUnderstandingGraphNode, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarUnderstandingGraphEdgeCollection on Isar {
  IsarCollection<IsarUnderstandingGraphEdge> get isarUnderstandingGraphEdges =>
      this.collection();
}

const IsarUnderstandingGraphEdgeSchema = CollectionSchema(
  name: r'IsarUnderstandingGraphEdge',
  id: -8176518489602080940,
  properties: {
    r'edgeId': PropertySchema(
      id: 0,
      name: r'edgeId',
      type: IsarType.string,
    ),
    r'relationType': PropertySchema(
      id: 1,
      name: r'relationType',
      type: IsarType.string,
    ),
    r'sourceNodeId': PropertySchema(
      id: 2,
      name: r'sourceNodeId',
      type: IsarType.string,
    ),
    r'targetNodeId': PropertySchema(
      id: 3,
      name: r'targetNodeId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarUnderstandingGraphEdgeEstimateSize,
  serialize: _isarUnderstandingGraphEdgeSerialize,
  deserialize: _isarUnderstandingGraphEdgeDeserialize,
  deserializeProp: _isarUnderstandingGraphEdgeDeserializeProp,
  idName: r'id',
  indexes: {
    r'edgeId': IndexSchema(
      id: -5461003074769508651,
      name: r'edgeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'edgeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarUnderstandingGraphEdgeGetId,
  getLinks: _isarUnderstandingGraphEdgeGetLinks,
  attach: _isarUnderstandingGraphEdgeAttach,
  version: '3.1.0+1',
);

int _isarUnderstandingGraphEdgeEstimateSize(
  IsarUnderstandingGraphEdge object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.edgeId.length * 3;
  bytesCount += 3 + object.relationType.length * 3;
  bytesCount += 3 + object.sourceNodeId.length * 3;
  bytesCount += 3 + object.targetNodeId.length * 3;
  return bytesCount;
}

void _isarUnderstandingGraphEdgeSerialize(
  IsarUnderstandingGraphEdge object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.edgeId);
  writer.writeString(offsets[1], object.relationType);
  writer.writeString(offsets[2], object.sourceNodeId);
  writer.writeString(offsets[3], object.targetNodeId);
}

IsarUnderstandingGraphEdge _isarUnderstandingGraphEdgeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarUnderstandingGraphEdge();
  object.edgeId = reader.readString(offsets[0]);
  object.relationType = reader.readString(offsets[1]);
  object.sourceNodeId = reader.readString(offsets[2]);
  object.targetNodeId = reader.readString(offsets[3]);
  return object;
}

P _isarUnderstandingGraphEdgeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarUnderstandingGraphEdgeGetId(IsarUnderstandingGraphEdge object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarUnderstandingGraphEdgeGetLinks(
    IsarUnderstandingGraphEdge object) {
  return [];
}

void _isarUnderstandingGraphEdgeAttach(
    IsarCollection<dynamic> col, Id id, IsarUnderstandingGraphEdge object) {}

extension IsarUnderstandingGraphEdgeByIndex
    on IsarCollection<IsarUnderstandingGraphEdge> {
  Future<IsarUnderstandingGraphEdge?> getByEdgeId(String edgeId) {
    return getByIndex(r'edgeId', [edgeId]);
  }

  IsarUnderstandingGraphEdge? getByEdgeIdSync(String edgeId) {
    return getByIndexSync(r'edgeId', [edgeId]);
  }

  Future<bool> deleteByEdgeId(String edgeId) {
    return deleteByIndex(r'edgeId', [edgeId]);
  }

  bool deleteByEdgeIdSync(String edgeId) {
    return deleteByIndexSync(r'edgeId', [edgeId]);
  }

  Future<List<IsarUnderstandingGraphEdge?>> getAllByEdgeId(
      List<String> edgeIdValues) {
    final values = edgeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'edgeId', values);
  }

  List<IsarUnderstandingGraphEdge?> getAllByEdgeIdSync(
      List<String> edgeIdValues) {
    final values = edgeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'edgeId', values);
  }

  Future<int> deleteAllByEdgeId(List<String> edgeIdValues) {
    final values = edgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'edgeId', values);
  }

  int deleteAllByEdgeIdSync(List<String> edgeIdValues) {
    final values = edgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'edgeId', values);
  }

  Future<Id> putByEdgeId(IsarUnderstandingGraphEdge object) {
    return putByIndex(r'edgeId', object);
  }

  Id putByEdgeIdSync(IsarUnderstandingGraphEdge object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'edgeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEdgeId(List<IsarUnderstandingGraphEdge> objects) {
    return putAllByIndex(r'edgeId', objects);
  }

  List<Id> putAllByEdgeIdSync(List<IsarUnderstandingGraphEdge> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'edgeId', objects, saveLinks: saveLinks);
  }
}

extension IsarUnderstandingGraphEdgeQueryWhereSort on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QWhere> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarUnderstandingGraphEdgeQueryWhere on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QWhereClause> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> edgeIdEqualTo(String edgeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'edgeId',
        value: [edgeId],
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterWhereClause> edgeIdNotEqualTo(String edgeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'edgeId',
              lower: [],
              upper: [edgeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'edgeId',
              lower: [edgeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'edgeId',
              lower: [edgeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'edgeId',
              lower: [],
              upper: [edgeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarUnderstandingGraphEdgeQueryFilter on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QFilterCondition> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'edgeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      edgeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'edgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      edgeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'edgeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'edgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> edgeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'edgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      relationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      relationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> relationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceNodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      sourceNodeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      sourceNodeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceNodeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceNodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> sourceNodeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceNodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetNodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      targetNodeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetNodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
          QAfterFilterCondition>
      targetNodeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetNodeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetNodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterFilterCondition> targetNodeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetNodeId',
        value: '',
      ));
    });
  }
}

extension IsarUnderstandingGraphEdgeQueryObject on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QFilterCondition> {}

extension IsarUnderstandingGraphEdgeQueryLinks on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QFilterCondition> {}

extension IsarUnderstandingGraphEdgeQuerySortBy on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QSortBy> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByEdgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edgeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByEdgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edgeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortBySourceNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortBySourceNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNodeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByTargetNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetNodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> sortByTargetNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetNodeId', Sort.desc);
    });
  }
}

extension IsarUnderstandingGraphEdgeQuerySortThenBy on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QSortThenBy> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByEdgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edgeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByEdgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edgeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenBySourceNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenBySourceNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNodeId', Sort.desc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByTargetNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetNodeId', Sort.asc);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QAfterSortBy> thenByTargetNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetNodeId', Sort.desc);
    });
  }
}

extension IsarUnderstandingGraphEdgeQueryWhereDistinct on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QDistinct> {
  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QDistinct> distinctByEdgeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'edgeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QDistinct> distinctByRelationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QDistinct> distinctBySourceNodeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceNodeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge,
      QDistinct> distinctByTargetNodeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetNodeId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarUnderstandingGraphEdgeQueryProperty on QueryBuilder<
    IsarUnderstandingGraphEdge, IsarUnderstandingGraphEdge, QQueryProperty> {
  QueryBuilder<IsarUnderstandingGraphEdge, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, String, QQueryOperations>
      edgeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'edgeId');
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, String, QQueryOperations>
      relationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationType');
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, String, QQueryOperations>
      sourceNodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceNodeId');
    });
  }

  QueryBuilder<IsarUnderstandingGraphEdge, String, QQueryOperations>
      targetNodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetNodeId');
    });
  }
}
