// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biological_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBiologicalStateCollection on Isar {
  IsarCollection<BiologicalState> get biologicalStates => this.collection();
}

const BiologicalStateSchema = CollectionSchema(
  name: r'BiologicalState',
  id: -900559288240813987,
  properties: {
    r'biologicalAgeDelta': PropertySchema(
      id: 0,
      name: r'biologicalAgeDelta',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'overallHealthScore': PropertySchema(
      id: 2,
      name: r'overallHealthScore',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _biologicalStateEstimateSize,
  serialize: _biologicalStateSerialize,
  deserialize: _biologicalStateDeserialize,
  deserializeProp: _biologicalStateDeserializeProp,
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
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _biologicalStateGetId,
  getLinks: _biologicalStateGetLinks,
  attach: _biologicalStateAttach,
  version: '3.1.0+1',
);

int _biologicalStateEstimateSize(
  BiologicalState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _biologicalStateSerialize(
  BiologicalState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.biologicalAgeDelta);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[2], object.overallHealthScore);
  writer.writeString(offsets[3], object.userId);
}

BiologicalState _biologicalStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BiologicalState();
  object.biologicalAgeDelta = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.overallHealthScore = reader.readDouble(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _biologicalStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _biologicalStateGetId(BiologicalState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _biologicalStateGetLinks(BiologicalState object) {
  return [];
}

void _biologicalStateAttach(
    IsarCollection<dynamic> col, Id id, BiologicalState object) {}

extension BiologicalStateQueryWhereSort
    on QueryBuilder<BiologicalState, BiologicalState, QWhere> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhere> anyUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'userId'),
      );
    });
  }
}

extension BiologicalStateQueryWhere
    on QueryBuilder<BiologicalState, BiologicalState, QWhereClause> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause> idBetween(
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdGreaterThan(
    String userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [userId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdLessThan(
    String userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [],
        upper: [userId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdBetween(
    String lowerUserId,
    String upperUserId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [lowerUserId],
        includeLower: includeLower,
        upper: [upperUserId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdStartsWith(String UserIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [UserIdPrefix],
        upper: ['$UserIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [''],
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterWhereClause>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'userId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'userId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'userId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'userId',
              upper: [''],
            ));
      }
    });
  }
}

extension BiologicalStateQueryFilter
    on QueryBuilder<BiologicalState, BiologicalState, QFilterCondition> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      biologicalAgeDeltaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biologicalAgeDelta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      biologicalAgeDeltaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'biologicalAgeDelta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      biologicalAgeDeltaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'biologicalAgeDelta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      biologicalAgeDeltaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'biologicalAgeDelta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      overallHealthScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overallHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      overallHealthScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overallHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      overallHealthScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overallHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      overallHealthScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overallHealthScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
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

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BiologicalStateQueryObject
    on QueryBuilder<BiologicalState, BiologicalState, QFilterCondition> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterFilterCondition>
      metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension BiologicalStateQueryLinks
    on QueryBuilder<BiologicalState, BiologicalState, QFilterCondition> {}

extension BiologicalStateQuerySortBy
    on QueryBuilder<BiologicalState, BiologicalState, QSortBy> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      sortByBiologicalAgeDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biologicalAgeDelta', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      sortByBiologicalAgeDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biologicalAgeDelta', Sort.desc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      sortByOverallHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallHealthScore', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      sortByOverallHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallHealthScore', Sort.desc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BiologicalStateQuerySortThenBy
    on QueryBuilder<BiologicalState, BiologicalState, QSortThenBy> {
  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      thenByBiologicalAgeDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biologicalAgeDelta', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      thenByBiologicalAgeDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biologicalAgeDelta', Sort.desc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      thenByOverallHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallHealthScore', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      thenByOverallHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallHealthScore', Sort.desc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BiologicalStateQueryWhereDistinct
    on QueryBuilder<BiologicalState, BiologicalState, QDistinct> {
  QueryBuilder<BiologicalState, BiologicalState, QDistinct>
      distinctByBiologicalAgeDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biologicalAgeDelta');
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QDistinct>
      distinctByOverallHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overallHealthScore');
    });
  }

  QueryBuilder<BiologicalState, BiologicalState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BiologicalStateQueryProperty
    on QueryBuilder<BiologicalState, BiologicalState, QQueryProperty> {
  QueryBuilder<BiologicalState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BiologicalState, double, QQueryOperations>
      biologicalAgeDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biologicalAgeDelta');
    });
  }

  QueryBuilder<BiologicalState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<BiologicalState, double, QQueryOperations>
      overallHealthScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overallHealthScore');
    });
  }

  QueryBuilder<BiologicalState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCircadianStateCollection on Isar {
  IsarCollection<CircadianState> get circadianStates => this.collection();
}

const CircadianStateSchema = CollectionSchema(
  name: r'CircadianState',
  id: 4498375116815429165,
  properties: {
    r'alignmentScore': PropertySchema(
      id: 0,
      name: r'alignmentScore',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'phaseShiftHours': PropertySchema(
      id: 2,
      name: r'phaseShiftHours',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _circadianStateEstimateSize,
  serialize: _circadianStateSerialize,
  deserialize: _circadianStateDeserialize,
  deserializeProp: _circadianStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _circadianStateGetId,
  getLinks: _circadianStateGetLinks,
  attach: _circadianStateAttach,
  version: '3.1.0+1',
);

int _circadianStateEstimateSize(
  CircadianState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _circadianStateSerialize(
  CircadianState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.alignmentScore);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[2], object.phaseShiftHours);
  writer.writeString(offsets[3], object.userId);
}

CircadianState _circadianStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CircadianState();
  object.alignmentScore = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.phaseShiftHours = reader.readDouble(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _circadianStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _circadianStateGetId(CircadianState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _circadianStateGetLinks(CircadianState object) {
  return [];
}

void _circadianStateAttach(
    IsarCollection<dynamic> col, Id id, CircadianState object) {}

extension CircadianStateQueryWhereSort
    on QueryBuilder<CircadianState, CircadianState, QWhere> {
  QueryBuilder<CircadianState, CircadianState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CircadianStateQueryWhere
    on QueryBuilder<CircadianState, CircadianState, QWhereClause> {
  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> idBetween(
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

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterWhereClause>
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

extension CircadianStateQueryFilter
    on QueryBuilder<CircadianState, CircadianState, QFilterCondition> {
  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      alignmentScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      alignmentScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      alignmentScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      alignmentScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alignmentScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      phaseShiftHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phaseShiftHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      phaseShiftHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phaseShiftHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      phaseShiftHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phaseShiftHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      phaseShiftHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phaseShiftHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
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

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension CircadianStateQueryObject
    on QueryBuilder<CircadianState, CircadianState, QFilterCondition> {
  QueryBuilder<CircadianState, CircadianState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension CircadianStateQueryLinks
    on QueryBuilder<CircadianState, CircadianState, QFilterCondition> {}

extension CircadianStateQuerySortBy
    on QueryBuilder<CircadianState, CircadianState, QSortBy> {
  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      sortByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      sortByAlignmentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.desc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      sortByPhaseShiftHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phaseShiftHours', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      sortByPhaseShiftHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phaseShiftHours', Sort.desc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CircadianStateQuerySortThenBy
    on QueryBuilder<CircadianState, CircadianState, QSortThenBy> {
  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      thenByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      thenByAlignmentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.desc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      thenByPhaseShiftHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phaseShiftHours', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      thenByPhaseShiftHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phaseShiftHours', Sort.desc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CircadianState, CircadianState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CircadianStateQueryWhereDistinct
    on QueryBuilder<CircadianState, CircadianState, QDistinct> {
  QueryBuilder<CircadianState, CircadianState, QDistinct>
      distinctByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alignmentScore');
    });
  }

  QueryBuilder<CircadianState, CircadianState, QDistinct>
      distinctByPhaseShiftHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phaseShiftHours');
    });
  }

  QueryBuilder<CircadianState, CircadianState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension CircadianStateQueryProperty
    on QueryBuilder<CircadianState, CircadianState, QQueryProperty> {
  QueryBuilder<CircadianState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CircadianState, double, QQueryOperations>
      alignmentScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alignmentScore');
    });
  }

  QueryBuilder<CircadianState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<CircadianState, double, QQueryOperations>
      phaseShiftHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phaseShiftHours');
    });
  }

  QueryBuilder<CircadianState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecoveryStateCollection on Isar {
  IsarCollection<RecoveryState> get recoveryStates => this.collection();
}

const RecoveryStateSchema = CollectionSchema(
  name: r'RecoveryState',
  id: 4540280494646497156,
  properties: {
    r'cnsRecoveryScore': PropertySchema(
      id: 0,
      name: r'cnsRecoveryScore',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'muscularRecoveryScore': PropertySchema(
      id: 2,
      name: r'muscularRecoveryScore',
      type: IsarType.double,
    ),
    r'overallRecovery': PropertySchema(
      id: 3,
      name: r'overallRecovery',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _recoveryStateEstimateSize,
  serialize: _recoveryStateSerialize,
  deserialize: _recoveryStateDeserialize,
  deserializeProp: _recoveryStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _recoveryStateGetId,
  getLinks: _recoveryStateGetLinks,
  attach: _recoveryStateAttach,
  version: '3.1.0+1',
);

int _recoveryStateEstimateSize(
  RecoveryState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _recoveryStateSerialize(
  RecoveryState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cnsRecoveryScore);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[2], object.muscularRecoveryScore);
  writer.writeDouble(offsets[3], object.overallRecovery);
  writer.writeString(offsets[4], object.userId);
}

RecoveryState _recoveryStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecoveryState();
  object.cnsRecoveryScore = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.muscularRecoveryScore = reader.readDouble(offsets[2]);
  object.overallRecovery = reader.readDouble(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _recoveryStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recoveryStateGetId(RecoveryState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recoveryStateGetLinks(RecoveryState object) {
  return [];
}

void _recoveryStateAttach(
    IsarCollection<dynamic> col, Id id, RecoveryState object) {}

extension RecoveryStateQueryWhereSort
    on QueryBuilder<RecoveryState, RecoveryState, QWhere> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecoveryStateQueryWhere
    on QueryBuilder<RecoveryState, RecoveryState, QWhereClause> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> idBetween(
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterWhereClause>
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

extension RecoveryStateQueryFilter
    on QueryBuilder<RecoveryState, RecoveryState, QFilterCondition> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      cnsRecoveryScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cnsRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      cnsRecoveryScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cnsRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      cnsRecoveryScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cnsRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      cnsRecoveryScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cnsRecoveryScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      muscularRecoveryScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'muscularRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      muscularRecoveryScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'muscularRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      muscularRecoveryScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'muscularRecoveryScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      muscularRecoveryScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'muscularRecoveryScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      overallRecoveryEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overallRecovery',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      overallRecoveryGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overallRecovery',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      overallRecoveryLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overallRecovery',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      overallRecoveryBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overallRecovery',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
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

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension RecoveryStateQueryObject
    on QueryBuilder<RecoveryState, RecoveryState, QFilterCondition> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension RecoveryStateQueryLinks
    on QueryBuilder<RecoveryState, RecoveryState, QFilterCondition> {}

extension RecoveryStateQuerySortBy
    on QueryBuilder<RecoveryState, RecoveryState, QSortBy> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByCnsRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cnsRecoveryScore', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByCnsRecoveryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cnsRecoveryScore', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByMuscularRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscularRecoveryScore', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByMuscularRecoveryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscularRecoveryScore', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByOverallRecovery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRecovery', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      sortByOverallRecoveryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRecovery', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RecoveryStateQuerySortThenBy
    on QueryBuilder<RecoveryState, RecoveryState, QSortThenBy> {
  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByCnsRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cnsRecoveryScore', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByCnsRecoveryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cnsRecoveryScore', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByMuscularRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscularRecoveryScore', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByMuscularRecoveryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscularRecoveryScore', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByOverallRecovery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRecovery', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy>
      thenByOverallRecoveryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRecovery', Sort.desc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RecoveryStateQueryWhereDistinct
    on QueryBuilder<RecoveryState, RecoveryState, QDistinct> {
  QueryBuilder<RecoveryState, RecoveryState, QDistinct>
      distinctByCnsRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cnsRecoveryScore');
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QDistinct>
      distinctByMuscularRecoveryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'muscularRecoveryScore');
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QDistinct>
      distinctByOverallRecovery() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overallRecovery');
    });
  }

  QueryBuilder<RecoveryState, RecoveryState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension RecoveryStateQueryProperty
    on QueryBuilder<RecoveryState, RecoveryState, QQueryProperty> {
  QueryBuilder<RecoveryState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecoveryState, double, QQueryOperations>
      cnsRecoveryScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cnsRecoveryScore');
    });
  }

  QueryBuilder<RecoveryState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<RecoveryState, double, QQueryOperations>
      muscularRecoveryScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'muscularRecoveryScore');
    });
  }

  QueryBuilder<RecoveryState, double, QQueryOperations>
      overallRecoveryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overallRecovery');
    });
  }

  QueryBuilder<RecoveryState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStressLoadStateCollection on Isar {
  IsarCollection<StressLoadState> get stressLoadStates => this.collection();
}

const StressLoadStateSchema = CollectionSchema(
  name: r'StressLoadState',
  id: -8542207182213955852,
  properties: {
    r'acuteStressLoad': PropertySchema(
      id: 0,
      name: r'acuteStressLoad',
      type: IsarType.double,
    ),
    r'allostaticLoad': PropertySchema(
      id: 1,
      name: r'allostaticLoad',
      type: IsarType.double,
    ),
    r'chronicStressLoad': PropertySchema(
      id: 2,
      name: r'chronicStressLoad',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 3,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _stressLoadStateEstimateSize,
  serialize: _stressLoadStateSerialize,
  deserialize: _stressLoadStateDeserialize,
  deserializeProp: _stressLoadStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _stressLoadStateGetId,
  getLinks: _stressLoadStateGetLinks,
  attach: _stressLoadStateAttach,
  version: '3.1.0+1',
);

int _stressLoadStateEstimateSize(
  StressLoadState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _stressLoadStateSerialize(
  StressLoadState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.acuteStressLoad);
  writer.writeDouble(offsets[1], object.allostaticLoad);
  writer.writeDouble(offsets[2], object.chronicStressLoad);
  writer.writeObject<TwinStateMetadata>(
    offsets[3],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[4], object.userId);
}

StressLoadState _stressLoadStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StressLoadState();
  object.acuteStressLoad = reader.readDouble(offsets[0]);
  object.allostaticLoad = reader.readDouble(offsets[1]);
  object.chronicStressLoad = reader.readDouble(offsets[2]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[3],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _stressLoadStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stressLoadStateGetId(StressLoadState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stressLoadStateGetLinks(StressLoadState object) {
  return [];
}

void _stressLoadStateAttach(
    IsarCollection<dynamic> col, Id id, StressLoadState object) {}

extension StressLoadStateQueryWhereSort
    on QueryBuilder<StressLoadState, StressLoadState, QWhere> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StressLoadStateQueryWhere
    on QueryBuilder<StressLoadState, StressLoadState, QWhereClause> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause> idBetween(
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterWhereClause>
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

extension StressLoadStateQueryFilter
    on QueryBuilder<StressLoadState, StressLoadState, QFilterCondition> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      acuteStressLoadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acuteStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      acuteStressLoadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acuteStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      acuteStressLoadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acuteStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      acuteStressLoadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acuteStressLoad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      allostaticLoadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allostaticLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      allostaticLoadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allostaticLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      allostaticLoadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allostaticLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      allostaticLoadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allostaticLoad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      chronicStressLoadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chronicStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      chronicStressLoadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chronicStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      chronicStressLoadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chronicStressLoad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      chronicStressLoadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chronicStressLoad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
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

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension StressLoadStateQueryObject
    on QueryBuilder<StressLoadState, StressLoadState, QFilterCondition> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterFilterCondition>
      metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension StressLoadStateQueryLinks
    on QueryBuilder<StressLoadState, StressLoadState, QFilterCondition> {}

extension StressLoadStateQuerySortBy
    on QueryBuilder<StressLoadState, StressLoadState, QSortBy> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByAcuteStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acuteStressLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByAcuteStressLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acuteStressLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByAllostaticLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allostaticLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByAllostaticLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allostaticLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByChronicStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicStressLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByChronicStressLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicStressLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StressLoadStateQuerySortThenBy
    on QueryBuilder<StressLoadState, StressLoadState, QSortThenBy> {
  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByAcuteStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acuteStressLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByAcuteStressLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acuteStressLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByAllostaticLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allostaticLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByAllostaticLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allostaticLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByChronicStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicStressLoad', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByChronicStressLoadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicStressLoad', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StressLoadStateQueryWhereDistinct
    on QueryBuilder<StressLoadState, StressLoadState, QDistinct> {
  QueryBuilder<StressLoadState, StressLoadState, QDistinct>
      distinctByAcuteStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acuteStressLoad');
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QDistinct>
      distinctByAllostaticLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allostaticLoad');
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QDistinct>
      distinctByChronicStressLoad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chronicStressLoad');
    });
  }

  QueryBuilder<StressLoadState, StressLoadState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension StressLoadStateQueryProperty
    on QueryBuilder<StressLoadState, StressLoadState, QQueryProperty> {
  QueryBuilder<StressLoadState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StressLoadState, double, QQueryOperations>
      acuteStressLoadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acuteStressLoad');
    });
  }

  QueryBuilder<StressLoadState, double, QQueryOperations>
      allostaticLoadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allostaticLoad');
    });
  }

  QueryBuilder<StressLoadState, double, QQueryOperations>
      chronicStressLoadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chronicStressLoad');
    });
  }

  QueryBuilder<StressLoadState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<StressLoadState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHydrationStateCollection on Isar {
  IsarCollection<HydrationState> get hydrationStates => this.collection();
}

const HydrationStateSchema = CollectionSchema(
  name: r'HydrationState',
  id: 6172929186583591612,
  properties: {
    r'electrolyteBalanceProxy': PropertySchema(
      id: 0,
      name: r'electrolyteBalanceProxy',
      type: IsarType.double,
    ),
    r'estimatedHydrationPercent': PropertySchema(
      id: 1,
      name: r'estimatedHydrationPercent',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _hydrationStateEstimateSize,
  serialize: _hydrationStateSerialize,
  deserialize: _hydrationStateDeserialize,
  deserializeProp: _hydrationStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _hydrationStateGetId,
  getLinks: _hydrationStateGetLinks,
  attach: _hydrationStateAttach,
  version: '3.1.0+1',
);

int _hydrationStateEstimateSize(
  HydrationState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _hydrationStateSerialize(
  HydrationState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.electrolyteBalanceProxy);
  writer.writeDouble(offsets[1], object.estimatedHydrationPercent);
  writer.writeObject<TwinStateMetadata>(
    offsets[2],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[3], object.userId);
}

HydrationState _hydrationStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HydrationState();
  object.electrolyteBalanceProxy = reader.readDouble(offsets[0]);
  object.estimatedHydrationPercent = reader.readDouble(offsets[1]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[2],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _hydrationStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hydrationStateGetId(HydrationState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hydrationStateGetLinks(HydrationState object) {
  return [];
}

void _hydrationStateAttach(
    IsarCollection<dynamic> col, Id id, HydrationState object) {}

extension HydrationStateQueryWhereSort
    on QueryBuilder<HydrationState, HydrationState, QWhere> {
  QueryBuilder<HydrationState, HydrationState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HydrationStateQueryWhere
    on QueryBuilder<HydrationState, HydrationState, QWhereClause> {
  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> idBetween(
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

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterWhereClause>
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

extension HydrationStateQueryFilter
    on QueryBuilder<HydrationState, HydrationState, QFilterCondition> {
  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      electrolyteBalanceProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'electrolyteBalanceProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      electrolyteBalanceProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'electrolyteBalanceProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      electrolyteBalanceProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'electrolyteBalanceProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      electrolyteBalanceProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'electrolyteBalanceProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      estimatedHydrationPercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedHydrationPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      estimatedHydrationPercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedHydrationPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      estimatedHydrationPercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedHydrationPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      estimatedHydrationPercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedHydrationPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
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

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension HydrationStateQueryObject
    on QueryBuilder<HydrationState, HydrationState, QFilterCondition> {
  QueryBuilder<HydrationState, HydrationState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension HydrationStateQueryLinks
    on QueryBuilder<HydrationState, HydrationState, QFilterCondition> {}

extension HydrationStateQuerySortBy
    on QueryBuilder<HydrationState, HydrationState, QSortBy> {
  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      sortByElectrolyteBalanceProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electrolyteBalanceProxy', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      sortByElectrolyteBalanceProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electrolyteBalanceProxy', Sort.desc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      sortByEstimatedHydrationPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHydrationPercent', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      sortByEstimatedHydrationPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHydrationPercent', Sort.desc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension HydrationStateQuerySortThenBy
    on QueryBuilder<HydrationState, HydrationState, QSortThenBy> {
  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      thenByElectrolyteBalanceProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electrolyteBalanceProxy', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      thenByElectrolyteBalanceProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electrolyteBalanceProxy', Sort.desc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      thenByEstimatedHydrationPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHydrationPercent', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      thenByEstimatedHydrationPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHydrationPercent', Sort.desc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HydrationState, HydrationState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension HydrationStateQueryWhereDistinct
    on QueryBuilder<HydrationState, HydrationState, QDistinct> {
  QueryBuilder<HydrationState, HydrationState, QDistinct>
      distinctByElectrolyteBalanceProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'electrolyteBalanceProxy');
    });
  }

  QueryBuilder<HydrationState, HydrationState, QDistinct>
      distinctByEstimatedHydrationPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedHydrationPercent');
    });
  }

  QueryBuilder<HydrationState, HydrationState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension HydrationStateQueryProperty
    on QueryBuilder<HydrationState, HydrationState, QQueryProperty> {
  QueryBuilder<HydrationState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HydrationState, double, QQueryOperations>
      electrolyteBalanceProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'electrolyteBalanceProxy');
    });
  }

  QueryBuilder<HydrationState, double, QQueryOperations>
      estimatedHydrationPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedHydrationPercent');
    });
  }

  QueryBuilder<HydrationState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<HydrationState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSleepDebtStateCollection on Isar {
  IsarCollection<SleepDebtState> get sleepDebtStates => this.collection();
}

const SleepDebtStateSchema = CollectionSchema(
  name: r'SleepDebtState',
  id: -6084394968028524215,
  properties: {
    r'accumulatedSleepDebtHours': PropertySchema(
      id: 0,
      name: r'accumulatedSleepDebtHours',
      type: IsarType.double,
    ),
    r'deepSleepDeficitHours': PropertySchema(
      id: 1,
      name: r'deepSleepDeficitHours',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'remDeficitHours': PropertySchema(
      id: 3,
      name: r'remDeficitHours',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _sleepDebtStateEstimateSize,
  serialize: _sleepDebtStateSerialize,
  deserialize: _sleepDebtStateDeserialize,
  deserializeProp: _sleepDebtStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _sleepDebtStateGetId,
  getLinks: _sleepDebtStateGetLinks,
  attach: _sleepDebtStateAttach,
  version: '3.1.0+1',
);

int _sleepDebtStateEstimateSize(
  SleepDebtState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _sleepDebtStateSerialize(
  SleepDebtState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accumulatedSleepDebtHours);
  writer.writeDouble(offsets[1], object.deepSleepDeficitHours);
  writer.writeObject<TwinStateMetadata>(
    offsets[2],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[3], object.remDeficitHours);
  writer.writeString(offsets[4], object.userId);
}

SleepDebtState _sleepDebtStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SleepDebtState();
  object.accumulatedSleepDebtHours = reader.readDouble(offsets[0]);
  object.deepSleepDeficitHours = reader.readDouble(offsets[1]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[2],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.remDeficitHours = reader.readDouble(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _sleepDebtStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sleepDebtStateGetId(SleepDebtState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sleepDebtStateGetLinks(SleepDebtState object) {
  return [];
}

void _sleepDebtStateAttach(
    IsarCollection<dynamic> col, Id id, SleepDebtState object) {}

extension SleepDebtStateQueryWhereSort
    on QueryBuilder<SleepDebtState, SleepDebtState, QWhere> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SleepDebtStateQueryWhere
    on QueryBuilder<SleepDebtState, SleepDebtState, QWhereClause> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> idBetween(
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterWhereClause>
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

extension SleepDebtStateQueryFilter
    on QueryBuilder<SleepDebtState, SleepDebtState, QFilterCondition> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      accumulatedSleepDebtHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accumulatedSleepDebtHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      accumulatedSleepDebtHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accumulatedSleepDebtHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      accumulatedSleepDebtHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accumulatedSleepDebtHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      accumulatedSleepDebtHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accumulatedSleepDebtHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      deepSleepDeficitHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepSleepDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      deepSleepDeficitHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepSleepDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      deepSleepDeficitHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepSleepDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      deepSleepDeficitHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepSleepDeficitHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      remDeficitHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      remDeficitHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      remDeficitHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remDeficitHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      remDeficitHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remDeficitHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
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

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SleepDebtStateQueryObject
    on QueryBuilder<SleepDebtState, SleepDebtState, QFilterCondition> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension SleepDebtStateQueryLinks
    on QueryBuilder<SleepDebtState, SleepDebtState, QFilterCondition> {}

extension SleepDebtStateQuerySortBy
    on QueryBuilder<SleepDebtState, SleepDebtState, QSortBy> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByAccumulatedSleepDebtHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSleepDebtHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByAccumulatedSleepDebtHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSleepDebtHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByDeepSleepDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepDeficitHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByDeepSleepDeficitHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepDeficitHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByRemDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remDeficitHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByRemDeficitHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remDeficitHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SleepDebtStateQuerySortThenBy
    on QueryBuilder<SleepDebtState, SleepDebtState, QSortThenBy> {
  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByAccumulatedSleepDebtHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSleepDebtHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByAccumulatedSleepDebtHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSleepDebtHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByDeepSleepDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepDeficitHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByDeepSleepDeficitHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepDeficitHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByRemDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remDeficitHours', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByRemDeficitHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remDeficitHours', Sort.desc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SleepDebtStateQueryWhereDistinct
    on QueryBuilder<SleepDebtState, SleepDebtState, QDistinct> {
  QueryBuilder<SleepDebtState, SleepDebtState, QDistinct>
      distinctByAccumulatedSleepDebtHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accumulatedSleepDebtHours');
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QDistinct>
      distinctByDeepSleepDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepSleepDeficitHours');
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QDistinct>
      distinctByRemDeficitHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remDeficitHours');
    });
  }

  QueryBuilder<SleepDebtState, SleepDebtState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SleepDebtStateQueryProperty
    on QueryBuilder<SleepDebtState, SleepDebtState, QQueryProperty> {
  QueryBuilder<SleepDebtState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SleepDebtState, double, QQueryOperations>
      accumulatedSleepDebtHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accumulatedSleepDebtHours');
    });
  }

  QueryBuilder<SleepDebtState, double, QQueryOperations>
      deepSleepDeficitHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepSleepDeficitHours');
    });
  }

  QueryBuilder<SleepDebtState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<SleepDebtState, double, QQueryOperations>
      remDeficitHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remDeficitHours');
    });
  }

  QueryBuilder<SleepDebtState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMetabolicStateCollection on Isar {
  IsarCollection<MetabolicState> get metabolicStates => this.collection();
}

const MetabolicStateSchema = CollectionSchema(
  name: r'MetabolicState',
  id: -1125601761992864404,
  properties: {
    r'estimatedGlycogenDepletion': PropertySchema(
      id: 0,
      name: r'estimatedGlycogenDepletion',
      type: IsarType.double,
    ),
    r'metabolicFlexibilityScore': PropertySchema(
      id: 1,
      name: r'metabolicFlexibilityScore',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _metabolicStateEstimateSize,
  serialize: _metabolicStateSerialize,
  deserialize: _metabolicStateDeserialize,
  deserializeProp: _metabolicStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _metabolicStateGetId,
  getLinks: _metabolicStateGetLinks,
  attach: _metabolicStateAttach,
  version: '3.1.0+1',
);

int _metabolicStateEstimateSize(
  MetabolicState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _metabolicStateSerialize(
  MetabolicState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.estimatedGlycogenDepletion);
  writer.writeDouble(offsets[1], object.metabolicFlexibilityScore);
  writer.writeObject<TwinStateMetadata>(
    offsets[2],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[3], object.userId);
}

MetabolicState _metabolicStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MetabolicState();
  object.estimatedGlycogenDepletion = reader.readDouble(offsets[0]);
  object.metabolicFlexibilityScore = reader.readDouble(offsets[1]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[2],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _metabolicStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _metabolicStateGetId(MetabolicState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _metabolicStateGetLinks(MetabolicState object) {
  return [];
}

void _metabolicStateAttach(
    IsarCollection<dynamic> col, Id id, MetabolicState object) {}

extension MetabolicStateQueryWhereSort
    on QueryBuilder<MetabolicState, MetabolicState, QWhere> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MetabolicStateQueryWhere
    on QueryBuilder<MetabolicState, MetabolicState, QWhereClause> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> idBetween(
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterWhereClause>
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

extension MetabolicStateQueryFilter
    on QueryBuilder<MetabolicState, MetabolicState, QFilterCondition> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      estimatedGlycogenDepletionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedGlycogenDepletion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      estimatedGlycogenDepletionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedGlycogenDepletion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      estimatedGlycogenDepletionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedGlycogenDepletion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      estimatedGlycogenDepletionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedGlycogenDepletion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      metabolicFlexibilityScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metabolicFlexibilityScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      metabolicFlexibilityScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metabolicFlexibilityScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      metabolicFlexibilityScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metabolicFlexibilityScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      metabolicFlexibilityScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metabolicFlexibilityScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
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

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension MetabolicStateQueryObject
    on QueryBuilder<MetabolicState, MetabolicState, QFilterCondition> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension MetabolicStateQueryLinks
    on QueryBuilder<MetabolicState, MetabolicState, QFilterCondition> {}

extension MetabolicStateQuerySortBy
    on QueryBuilder<MetabolicState, MetabolicState, QSortBy> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      sortByEstimatedGlycogenDepletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedGlycogenDepletion', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      sortByEstimatedGlycogenDepletionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedGlycogenDepletion', Sort.desc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      sortByMetabolicFlexibilityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metabolicFlexibilityScore', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      sortByMetabolicFlexibilityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metabolicFlexibilityScore', Sort.desc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MetabolicStateQuerySortThenBy
    on QueryBuilder<MetabolicState, MetabolicState, QSortThenBy> {
  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      thenByEstimatedGlycogenDepletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedGlycogenDepletion', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      thenByEstimatedGlycogenDepletionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedGlycogenDepletion', Sort.desc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      thenByMetabolicFlexibilityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metabolicFlexibilityScore', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      thenByMetabolicFlexibilityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metabolicFlexibilityScore', Sort.desc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MetabolicStateQueryWhereDistinct
    on QueryBuilder<MetabolicState, MetabolicState, QDistinct> {
  QueryBuilder<MetabolicState, MetabolicState, QDistinct>
      distinctByEstimatedGlycogenDepletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedGlycogenDepletion');
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QDistinct>
      distinctByMetabolicFlexibilityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metabolicFlexibilityScore');
    });
  }

  QueryBuilder<MetabolicState, MetabolicState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension MetabolicStateQueryProperty
    on QueryBuilder<MetabolicState, MetabolicState, QQueryProperty> {
  QueryBuilder<MetabolicState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MetabolicState, double, QQueryOperations>
      estimatedGlycogenDepletionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedGlycogenDepletion');
    });
  }

  QueryBuilder<MetabolicState, double, QQueryOperations>
      metabolicFlexibilityScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metabolicFlexibilityScore');
    });
  }

  QueryBuilder<MetabolicState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<MetabolicState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCognitiveStateCollection on Isar {
  IsarCollection<CognitiveState> get cognitiveStates => this.collection();
}

const CognitiveStateSchema = CollectionSchema(
  name: r'CognitiveState',
  id: -4948414777930885536,
  properties: {
    r'cognitiveFatigue': PropertySchema(
      id: 0,
      name: r'cognitiveFatigue',
      type: IsarType.double,
    ),
    r'focusCapacity': PropertySchema(
      id: 1,
      name: r'focusCapacity',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _cognitiveStateEstimateSize,
  serialize: _cognitiveStateSerialize,
  deserialize: _cognitiveStateDeserialize,
  deserializeProp: _cognitiveStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _cognitiveStateGetId,
  getLinks: _cognitiveStateGetLinks,
  attach: _cognitiveStateAttach,
  version: '3.1.0+1',
);

int _cognitiveStateEstimateSize(
  CognitiveState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _cognitiveStateSerialize(
  CognitiveState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cognitiveFatigue);
  writer.writeDouble(offsets[1], object.focusCapacity);
  writer.writeObject<TwinStateMetadata>(
    offsets[2],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[3], object.userId);
}

CognitiveState _cognitiveStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CognitiveState();
  object.cognitiveFatigue = reader.readDouble(offsets[0]);
  object.focusCapacity = reader.readDouble(offsets[1]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[2],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _cognitiveStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cognitiveStateGetId(CognitiveState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cognitiveStateGetLinks(CognitiveState object) {
  return [];
}

void _cognitiveStateAttach(
    IsarCollection<dynamic> col, Id id, CognitiveState object) {}

extension CognitiveStateQueryWhereSort
    on QueryBuilder<CognitiveState, CognitiveState, QWhere> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CognitiveStateQueryWhere
    on QueryBuilder<CognitiveState, CognitiveState, QWhereClause> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> idBetween(
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterWhereClause>
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

extension CognitiveStateQueryFilter
    on QueryBuilder<CognitiveState, CognitiveState, QFilterCondition> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      cognitiveFatigueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cognitiveFatigue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      cognitiveFatigueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cognitiveFatigue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      cognitiveFatigueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cognitiveFatigue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      cognitiveFatigueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cognitiveFatigue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      focusCapacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      focusCapacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      focusCapacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      focusCapacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusCapacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
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

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension CognitiveStateQueryObject
    on QueryBuilder<CognitiveState, CognitiveState, QFilterCondition> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension CognitiveStateQueryLinks
    on QueryBuilder<CognitiveState, CognitiveState, QFilterCondition> {}

extension CognitiveStateQuerySortBy
    on QueryBuilder<CognitiveState, CognitiveState, QSortBy> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      sortByCognitiveFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveFatigue', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      sortByCognitiveFatigueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveFatigue', Sort.desc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      sortByFocusCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusCapacity', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      sortByFocusCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusCapacity', Sort.desc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CognitiveStateQuerySortThenBy
    on QueryBuilder<CognitiveState, CognitiveState, QSortThenBy> {
  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      thenByCognitiveFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveFatigue', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      thenByCognitiveFatigueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveFatigue', Sort.desc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      thenByFocusCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusCapacity', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      thenByFocusCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusCapacity', Sort.desc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CognitiveStateQueryWhereDistinct
    on QueryBuilder<CognitiveState, CognitiveState, QDistinct> {
  QueryBuilder<CognitiveState, CognitiveState, QDistinct>
      distinctByCognitiveFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cognitiveFatigue');
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QDistinct>
      distinctByFocusCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusCapacity');
    });
  }

  QueryBuilder<CognitiveState, CognitiveState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension CognitiveStateQueryProperty
    on QueryBuilder<CognitiveState, CognitiveState, QQueryProperty> {
  QueryBuilder<CognitiveState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CognitiveState, double, QQueryOperations>
      cognitiveFatigueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cognitiveFatigue');
    });
  }

  QueryBuilder<CognitiveState, double, QQueryOperations>
      focusCapacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusCapacity');
    });
  }

  QueryBuilder<CognitiveState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<CognitiveState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInflammationProxyStateCollection on Isar {
  IsarCollection<InflammationProxyState> get inflammationProxyStates =>
      this.collection();
}

const InflammationProxyStateSchema = CollectionSchema(
  name: r'InflammationProxyState',
  id: -8259848555900802116,
  properties: {
    r'metadata': PropertySchema(
      id: 0,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'systemicInflammationScore': PropertySchema(
      id: 1,
      name: r'systemicInflammationScore',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 2,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _inflammationProxyStateEstimateSize,
  serialize: _inflammationProxyStateSerialize,
  deserialize: _inflammationProxyStateDeserialize,
  deserializeProp: _inflammationProxyStateDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _inflammationProxyStateGetId,
  getLinks: _inflammationProxyStateGetLinks,
  attach: _inflammationProxyStateAttach,
  version: '3.1.0+1',
);

int _inflammationProxyStateEstimateSize(
  InflammationProxyState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _inflammationProxyStateSerialize(
  InflammationProxyState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<TwinStateMetadata>(
    offsets[0],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[1], object.systemicInflammationScore);
  writer.writeString(offsets[2], object.userId);
}

InflammationProxyState _inflammationProxyStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InflammationProxyState();
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[0],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.systemicInflammationScore = reader.readDouble(offsets[1]);
  object.userId = reader.readString(offsets[2]);
  return object;
}

P _inflammationProxyStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inflammationProxyStateGetId(InflammationProxyState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inflammationProxyStateGetLinks(
    InflammationProxyState object) {
  return [];
}

void _inflammationProxyStateAttach(
    IsarCollection<dynamic> col, Id id, InflammationProxyState object) {}

extension InflammationProxyStateQueryWhereSort
    on QueryBuilder<InflammationProxyState, InflammationProxyState, QWhere> {
  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InflammationProxyStateQueryWhere on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QWhereClause> {
  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
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

extension InflammationProxyStateQueryFilter on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QFilterCondition> {
  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> systemicInflammationScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'systemicInflammationScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> systemicInflammationScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'systemicInflammationScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> systemicInflammationScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'systemicInflammationScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> systemicInflammationScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'systemicInflammationScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
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

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension InflammationProxyStateQueryObject on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QFilterCondition> {
  QueryBuilder<InflammationProxyState, InflammationProxyState,
      QAfterFilterCondition> metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension InflammationProxyStateQueryLinks on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QFilterCondition> {}

extension InflammationProxyStateQuerySortBy
    on QueryBuilder<InflammationProxyState, InflammationProxyState, QSortBy> {
  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      sortBySystemicInflammationScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemicInflammationScore', Sort.asc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      sortBySystemicInflammationScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemicInflammationScore', Sort.desc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension InflammationProxyStateQuerySortThenBy on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QSortThenBy> {
  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenBySystemicInflammationScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemicInflammationScore', Sort.asc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenBySystemicInflammationScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemicInflammationScore', Sort.desc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension InflammationProxyStateQueryWhereDistinct
    on QueryBuilder<InflammationProxyState, InflammationProxyState, QDistinct> {
  QueryBuilder<InflammationProxyState, InflammationProxyState, QDistinct>
      distinctBySystemicInflammationScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'systemicInflammationScore');
    });
  }

  QueryBuilder<InflammationProxyState, InflammationProxyState, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension InflammationProxyStateQueryProperty on QueryBuilder<
    InflammationProxyState, InflammationProxyState, QQueryProperty> {
  QueryBuilder<InflammationProxyState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InflammationProxyState, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<InflammationProxyState, double, QQueryOperations>
      systemicInflammationScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'systemicInflammationScore');
    });
  }

  QueryBuilder<InflammationProxyState, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNutrientDeficiencyProbabilityCollection on Isar {
  IsarCollection<NutrientDeficiencyProbability>
      get nutrientDeficiencyProbabilitys => this.collection();
}

const NutrientDeficiencyProbabilitySchema = CollectionSchema(
  name: r'NutrientDeficiencyProbability',
  id: 1535808146128867763,
  properties: {
    r'metadata': PropertySchema(
      id: 0,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'nutrientProbabilitiesJson': PropertySchema(
      id: 1,
      name: r'nutrientProbabilitiesJson',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 2,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _nutrientDeficiencyProbabilityEstimateSize,
  serialize: _nutrientDeficiencyProbabilitySerialize,
  deserialize: _nutrientDeficiencyProbabilityDeserialize,
  deserializeProp: _nutrientDeficiencyProbabilityDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _nutrientDeficiencyProbabilityGetId,
  getLinks: _nutrientDeficiencyProbabilityGetLinks,
  attach: _nutrientDeficiencyProbabilityAttach,
  version: '3.1.0+1',
);

int _nutrientDeficiencyProbabilityEstimateSize(
  NutrientDeficiencyProbability object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.nutrientProbabilitiesJson.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _nutrientDeficiencyProbabilitySerialize(
  NutrientDeficiencyProbability object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<TwinStateMetadata>(
    offsets[0],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[1], object.nutrientProbabilitiesJson);
  writer.writeString(offsets[2], object.userId);
}

NutrientDeficiencyProbability _nutrientDeficiencyProbabilityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NutrientDeficiencyProbability();
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[0],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.nutrientProbabilitiesJson = reader.readString(offsets[1]);
  object.userId = reader.readString(offsets[2]);
  return object;
}

P _nutrientDeficiencyProbabilityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nutrientDeficiencyProbabilityGetId(NutrientDeficiencyProbability object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nutrientDeficiencyProbabilityGetLinks(
    NutrientDeficiencyProbability object) {
  return [];
}

void _nutrientDeficiencyProbabilityAttach(
    IsarCollection<dynamic> col, Id id, NutrientDeficiencyProbability object) {}

extension NutrientDeficiencyProbabilityQueryWhereSort on QueryBuilder<
    NutrientDeficiencyProbability, NutrientDeficiencyProbability, QWhere> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NutrientDeficiencyProbabilityQueryWhere on QueryBuilder<
    NutrientDeficiencyProbability,
    NutrientDeficiencyProbability,
    QWhereClause> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
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

extension NutrientDeficiencyProbabilityQueryFilter on QueryBuilder<
    NutrientDeficiencyProbability,
    NutrientDeficiencyProbability,
    QFilterCondition> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nutrientProbabilitiesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
          QAfterFilterCondition>
      nutrientProbabilitiesJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nutrientProbabilitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
          QAfterFilterCondition>
      nutrientProbabilitiesJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nutrientProbabilitiesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nutrientProbabilitiesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> nutrientProbabilitiesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nutrientProbabilitiesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
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

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension NutrientDeficiencyProbabilityQueryObject on QueryBuilder<
    NutrientDeficiencyProbability,
    NutrientDeficiencyProbability,
    QFilterCondition> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterFilterCondition> metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension NutrientDeficiencyProbabilityQueryLinks on QueryBuilder<
    NutrientDeficiencyProbability,
    NutrientDeficiencyProbability,
    QFilterCondition> {}

extension NutrientDeficiencyProbabilityQuerySortBy on QueryBuilder<
    NutrientDeficiencyProbability, NutrientDeficiencyProbability, QSortBy> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> sortByNutrientProbabilitiesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutrientProbabilitiesJson', Sort.asc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> sortByNutrientProbabilitiesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutrientProbabilitiesJson', Sort.desc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension NutrientDeficiencyProbabilityQuerySortThenBy on QueryBuilder<
    NutrientDeficiencyProbability, NutrientDeficiencyProbability, QSortThenBy> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenByNutrientProbabilitiesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutrientProbabilitiesJson', Sort.asc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenByNutrientProbabilitiesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutrientProbabilitiesJson', Sort.desc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension NutrientDeficiencyProbabilityQueryWhereDistinct on QueryBuilder<
    NutrientDeficiencyProbability, NutrientDeficiencyProbability, QDistinct> {
  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
          QDistinct>
      distinctByNutrientProbabilitiesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nutrientProbabilitiesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, NutrientDeficiencyProbability,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension NutrientDeficiencyProbabilityQueryProperty on QueryBuilder<
    NutrientDeficiencyProbability,
    NutrientDeficiencyProbability,
    QQueryProperty> {
  QueryBuilder<NutrientDeficiencyProbability, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, TwinStateMetadata,
      QQueryOperations> metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, String, QQueryOperations>
      nutrientProbabilitiesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nutrientProbabilitiesJson');
    });
  }

  QueryBuilder<NutrientDeficiencyProbability, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHormonalBalanceProxyCollection on Isar {
  IsarCollection<HormonalBalanceProxy> get hormonalBalanceProxys =>
      this.collection();
}

const HormonalBalanceProxySchema = CollectionSchema(
  name: r'HormonalBalanceProxy',
  id: -3273530796168867792,
  properties: {
    r'cortisolProxy': PropertySchema(
      id: 0,
      name: r'cortisolProxy',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'testosteroneProxy': PropertySchema(
      id: 2,
      name: r'testosteroneProxy',
      type: IsarType.double,
    ),
    r'thyroidProxy': PropertySchema(
      id: 3,
      name: r'thyroidProxy',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _hormonalBalanceProxyEstimateSize,
  serialize: _hormonalBalanceProxySerialize,
  deserialize: _hormonalBalanceProxyDeserialize,
  deserializeProp: _hormonalBalanceProxyDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _hormonalBalanceProxyGetId,
  getLinks: _hormonalBalanceProxyGetLinks,
  attach: _hormonalBalanceProxyAttach,
  version: '3.1.0+1',
);

int _hormonalBalanceProxyEstimateSize(
  HormonalBalanceProxy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _hormonalBalanceProxySerialize(
  HormonalBalanceProxy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cortisolProxy);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[2], object.testosteroneProxy);
  writer.writeDouble(offsets[3], object.thyroidProxy);
  writer.writeString(offsets[4], object.userId);
}

HormonalBalanceProxy _hormonalBalanceProxyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HormonalBalanceProxy();
  object.cortisolProxy = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.testosteroneProxy = reader.readDouble(offsets[2]);
  object.thyroidProxy = reader.readDouble(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _hormonalBalanceProxyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hormonalBalanceProxyGetId(HormonalBalanceProxy object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hormonalBalanceProxyGetLinks(
    HormonalBalanceProxy object) {
  return [];
}

void _hormonalBalanceProxyAttach(
    IsarCollection<dynamic> col, Id id, HormonalBalanceProxy object) {}

extension HormonalBalanceProxyQueryWhereSort
    on QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QWhere> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HormonalBalanceProxyQueryWhere
    on QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QWhereClause> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterWhereClause>
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

extension HormonalBalanceProxyQueryFilter on QueryBuilder<HormonalBalanceProxy,
    HormonalBalanceProxy, QFilterCondition> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> cortisolProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cortisolProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> cortisolProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cortisolProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> cortisolProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cortisolProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> cortisolProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cortisolProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> testosteroneProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testosteroneProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> testosteroneProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testosteroneProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> testosteroneProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testosteroneProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> testosteroneProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testosteroneProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> thyroidProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thyroidProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> thyroidProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thyroidProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> thyroidProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thyroidProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> thyroidProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thyroidProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
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

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension HormonalBalanceProxyQueryObject on QueryBuilder<HormonalBalanceProxy,
    HormonalBalanceProxy, QFilterCondition> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy,
      QAfterFilterCondition> metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension HormonalBalanceProxyQueryLinks on QueryBuilder<HormonalBalanceProxy,
    HormonalBalanceProxy, QFilterCondition> {}

extension HormonalBalanceProxyQuerySortBy
    on QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QSortBy> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByCortisolProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cortisolProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByCortisolProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cortisolProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByTestosteroneProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testosteroneProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByTestosteroneProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testosteroneProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByThyroidProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thyroidProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByThyroidProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thyroidProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension HormonalBalanceProxyQuerySortThenBy
    on QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QSortThenBy> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByCortisolProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cortisolProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByCortisolProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cortisolProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByTestosteroneProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testosteroneProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByTestosteroneProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testosteroneProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByThyroidProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thyroidProxy', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByThyroidProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thyroidProxy', Sort.desc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension HormonalBalanceProxyQueryWhereDistinct
    on QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QDistinct> {
  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QDistinct>
      distinctByCortisolProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cortisolProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QDistinct>
      distinctByTestosteroneProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testosteroneProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QDistinct>
      distinctByThyroidProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thyroidProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, HormonalBalanceProxy, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension HormonalBalanceProxyQueryProperty on QueryBuilder<
    HormonalBalanceProxy, HormonalBalanceProxy, QQueryProperty> {
  QueryBuilder<HormonalBalanceProxy, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HormonalBalanceProxy, double, QQueryOperations>
      cortisolProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cortisolProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<HormonalBalanceProxy, double, QQueryOperations>
      testosteroneProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testosteroneProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, double, QQueryOperations>
      thyroidProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thyroidProxy');
    });
  }

  QueryBuilder<HormonalBalanceProxy, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGutHealthProxyCollection on Isar {
  IsarCollection<GutHealthProxy> get gutHealthProxys => this.collection();
}

const GutHealthProxySchema = CollectionSchema(
  name: r'GutHealthProxy',
  id: -580940287340701332,
  properties: {
    r'gutPermeabilityProxy': PropertySchema(
      id: 0,
      name: r'gutPermeabilityProxy',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'microbiomeDiversityProxy': PropertySchema(
      id: 2,
      name: r'microbiomeDiversityProxy',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _gutHealthProxyEstimateSize,
  serialize: _gutHealthProxySerialize,
  deserialize: _gutHealthProxyDeserialize,
  deserializeProp: _gutHealthProxyDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _gutHealthProxyGetId,
  getLinks: _gutHealthProxyGetLinks,
  attach: _gutHealthProxyAttach,
  version: '3.1.0+1',
);

int _gutHealthProxyEstimateSize(
  GutHealthProxy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _gutHealthProxySerialize(
  GutHealthProxy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.gutPermeabilityProxy);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[2], object.microbiomeDiversityProxy);
  writer.writeString(offsets[3], object.userId);
}

GutHealthProxy _gutHealthProxyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GutHealthProxy();
  object.gutPermeabilityProxy = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.microbiomeDiversityProxy = reader.readDouble(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _gutHealthProxyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gutHealthProxyGetId(GutHealthProxy object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gutHealthProxyGetLinks(GutHealthProxy object) {
  return [];
}

void _gutHealthProxyAttach(
    IsarCollection<dynamic> col, Id id, GutHealthProxy object) {}

extension GutHealthProxyQueryWhereSort
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QWhere> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GutHealthProxyQueryWhere
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QWhereClause> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> idBetween(
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterWhereClause>
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

extension GutHealthProxyQueryFilter
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QFilterCondition> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      gutPermeabilityProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gutPermeabilityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      gutPermeabilityProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gutPermeabilityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      gutPermeabilityProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gutPermeabilityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      gutPermeabilityProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gutPermeabilityProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition> idBetween(
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      microbiomeDiversityProxyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'microbiomeDiversityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      microbiomeDiversityProxyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'microbiomeDiversityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      microbiomeDiversityProxyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'microbiomeDiversityProxy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      microbiomeDiversityProxyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'microbiomeDiversityProxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
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

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension GutHealthProxyQueryObject
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QFilterCondition> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterFilterCondition> metadata(
      FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension GutHealthProxyQueryLinks
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QFilterCondition> {}

extension GutHealthProxyQuerySortBy
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QSortBy> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      sortByGutPermeabilityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPermeabilityProxy', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      sortByGutPermeabilityProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPermeabilityProxy', Sort.desc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      sortByMicrobiomeDiversityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'microbiomeDiversityProxy', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      sortByMicrobiomeDiversityProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'microbiomeDiversityProxy', Sort.desc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension GutHealthProxyQuerySortThenBy
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QSortThenBy> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      thenByGutPermeabilityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPermeabilityProxy', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      thenByGutPermeabilityProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPermeabilityProxy', Sort.desc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      thenByMicrobiomeDiversityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'microbiomeDiversityProxy', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      thenByMicrobiomeDiversityProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'microbiomeDiversityProxy', Sort.desc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension GutHealthProxyQueryWhereDistinct
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QDistinct> {
  QueryBuilder<GutHealthProxy, GutHealthProxy, QDistinct>
      distinctByGutPermeabilityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gutPermeabilityProxy');
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QDistinct>
      distinctByMicrobiomeDiversityProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'microbiomeDiversityProxy');
    });
  }

  QueryBuilder<GutHealthProxy, GutHealthProxy, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension GutHealthProxyQueryProperty
    on QueryBuilder<GutHealthProxy, GutHealthProxy, QQueryProperty> {
  QueryBuilder<GutHealthProxy, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GutHealthProxy, double, QQueryOperations>
      gutPermeabilityProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gutPermeabilityProxy');
    });
  }

  QueryBuilder<GutHealthProxy, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<GutHealthProxy, double, QQueryOperations>
      microbiomeDiversityProxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'microbiomeDiversityProxy');
    });
  }

  QueryBuilder<GutHealthProxy, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBehavioralConsistencyScoreCollection on Isar {
  IsarCollection<BehavioralConsistencyScore> get behavioralConsistencyScores =>
      this.collection();
}

const BehavioralConsistencyScoreSchema = CollectionSchema(
  name: r'BehavioralConsistencyScore',
  id: -4806277433492266513,
  properties: {
    r'circadianRhythmConsistency': PropertySchema(
      id: 0,
      name: r'circadianRhythmConsistency',
      type: IsarType.double,
    ),
    r'feedingWindowConsistency': PropertySchema(
      id: 1,
      name: r'feedingWindowConsistency',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'overallConsistency': PropertySchema(
      id: 3,
      name: r'overallConsistency',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _behavioralConsistencyScoreEstimateSize,
  serialize: _behavioralConsistencyScoreSerialize,
  deserialize: _behavioralConsistencyScoreDeserialize,
  deserializeProp: _behavioralConsistencyScoreDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _behavioralConsistencyScoreGetId,
  getLinks: _behavioralConsistencyScoreGetLinks,
  attach: _behavioralConsistencyScoreAttach,
  version: '3.1.0+1',
);

int _behavioralConsistencyScoreEstimateSize(
  BehavioralConsistencyScore object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _behavioralConsistencyScoreSerialize(
  BehavioralConsistencyScore object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.circadianRhythmConsistency);
  writer.writeDouble(offsets[1], object.feedingWindowConsistency);
  writer.writeObject<TwinStateMetadata>(
    offsets[2],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeDouble(offsets[3], object.overallConsistency);
  writer.writeString(offsets[4], object.userId);
}

BehavioralConsistencyScore _behavioralConsistencyScoreDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BehavioralConsistencyScore();
  object.circadianRhythmConsistency = reader.readDouble(offsets[0]);
  object.feedingWindowConsistency = reader.readDouble(offsets[1]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[2],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.overallConsistency = reader.readDouble(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _behavioralConsistencyScoreDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _behavioralConsistencyScoreGetId(BehavioralConsistencyScore object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _behavioralConsistencyScoreGetLinks(
    BehavioralConsistencyScore object) {
  return [];
}

void _behavioralConsistencyScoreAttach(
    IsarCollection<dynamic> col, Id id, BehavioralConsistencyScore object) {}

extension BehavioralConsistencyScoreQueryWhereSort on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QWhere> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BehavioralConsistencyScoreQueryWhere on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QWhereClause> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
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

extension BehavioralConsistencyScoreQueryFilter on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QFilterCondition> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> circadianRhythmConsistencyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'circadianRhythmConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> circadianRhythmConsistencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'circadianRhythmConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> circadianRhythmConsistencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'circadianRhythmConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> circadianRhythmConsistencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'circadianRhythmConsistency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> feedingWindowConsistencyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedingWindowConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> feedingWindowConsistencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedingWindowConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> feedingWindowConsistencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedingWindowConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> feedingWindowConsistencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedingWindowConsistency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> overallConsistencyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overallConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> overallConsistencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overallConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> overallConsistencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overallConsistency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> overallConsistencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overallConsistency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
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

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BehavioralConsistencyScoreQueryObject on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QFilterCondition> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterFilterCondition> metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension BehavioralConsistencyScoreQueryLinks on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QFilterCondition> {}

extension BehavioralConsistencyScoreQuerySortBy on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QSortBy> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByCircadianRhythmConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circadianRhythmConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByCircadianRhythmConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circadianRhythmConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByFeedingWindowConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingWindowConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByFeedingWindowConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingWindowConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByOverallConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByOverallConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BehavioralConsistencyScoreQuerySortThenBy on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QSortThenBy> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByCircadianRhythmConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circadianRhythmConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByCircadianRhythmConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circadianRhythmConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByFeedingWindowConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingWindowConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByFeedingWindowConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingWindowConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByOverallConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallConsistency', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByOverallConsistencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallConsistency', Sort.desc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BehavioralConsistencyScoreQueryWhereDistinct on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QDistinct> {
  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QDistinct> distinctByCircadianRhythmConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'circadianRhythmConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QDistinct> distinctByFeedingWindowConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedingWindowConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QDistinct> distinctByOverallConsistency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overallConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, BehavioralConsistencyScore,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BehavioralConsistencyScoreQueryProperty on QueryBuilder<
    BehavioralConsistencyScore, BehavioralConsistencyScore, QQueryProperty> {
  QueryBuilder<BehavioralConsistencyScore, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, double, QQueryOperations>
      circadianRhythmConsistencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'circadianRhythmConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, double, QQueryOperations>
      feedingWindowConsistencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedingWindowConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, double, QQueryOperations>
      overallConsistencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overallConsistency');
    });
  }

  QueryBuilder<BehavioralConsistencyScore, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecommendationConfidenceCollection on Isar {
  IsarCollection<RecommendationConfidence> get recommendationConfidences =>
      this.collection();
}

const RecommendationConfidenceSchema = CollectionSchema(
  name: r'RecommendationConfidence',
  id: 8612781072116276909,
  properties: {
    r'aiConfidenceScore': PropertySchema(
      id: 0,
      name: r'aiConfidenceScore',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'userId': PropertySchema(
      id: 2,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _recommendationConfidenceEstimateSize,
  serialize: _recommendationConfidenceSerialize,
  deserialize: _recommendationConfidenceDeserialize,
  deserializeProp: _recommendationConfidenceDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _recommendationConfidenceGetId,
  getLinks: _recommendationConfidenceGetLinks,
  attach: _recommendationConfidenceAttach,
  version: '3.1.0+1',
);

int _recommendationConfidenceEstimateSize(
  RecommendationConfidence object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _recommendationConfidenceSerialize(
  RecommendationConfidence object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.aiConfidenceScore);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[2], object.userId);
}

RecommendationConfidence _recommendationConfidenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecommendationConfidence();
  object.aiConfidenceScore = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.userId = reader.readString(offsets[2]);
  return object;
}

P _recommendationConfidenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recommendationConfidenceGetId(RecommendationConfidence object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recommendationConfidenceGetLinks(
    RecommendationConfidence object) {
  return [];
}

void _recommendationConfidenceAttach(
    IsarCollection<dynamic> col, Id id, RecommendationConfidence object) {}

extension RecommendationConfidenceQueryWhereSort on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QWhere> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecommendationConfidenceQueryWhere on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QWhereClause> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
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

extension RecommendationConfidenceQueryFilter on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QFilterCondition> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> aiConfidenceScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiConfidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> aiConfidenceScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiConfidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> aiConfidenceScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiConfidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> aiConfidenceScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiConfidenceScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
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

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension RecommendationConfidenceQueryObject on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QFilterCondition> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence,
      QAfterFilterCondition> metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension RecommendationConfidenceQueryLinks on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QFilterCondition> {}

extension RecommendationConfidenceQuerySortBy on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QSortBy> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      sortByAiConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidenceScore', Sort.asc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      sortByAiConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidenceScore', Sort.desc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RecommendationConfidenceQuerySortThenBy on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QSortThenBy> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenByAiConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidenceScore', Sort.asc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenByAiConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidenceScore', Sort.desc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RecommendationConfidenceQueryWhereDistinct on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QDistinct> {
  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QDistinct>
      distinctByAiConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiConfidenceScore');
    });
  }

  QueryBuilder<RecommendationConfidence, RecommendationConfidence, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension RecommendationConfidenceQueryProperty on QueryBuilder<
    RecommendationConfidence, RecommendationConfidence, QQueryProperty> {
  QueryBuilder<RecommendationConfidence, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecommendationConfidence, double, QQueryOperations>
      aiConfidenceScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiConfidenceScore');
    });
  }

  QueryBuilder<RecommendationConfidence, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<RecommendationConfidence, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUncertaintyScoreCollection on Isar {
  IsarCollection<UncertaintyScore> get uncertaintyScores => this.collection();
}

const UncertaintyScoreSchema = CollectionSchema(
  name: r'UncertaintyScore',
  id: 2325941512894828209,
  properties: {
    r'globalUncertainty': PropertySchema(
      id: 0,
      name: r'globalUncertainty',
      type: IsarType.double,
    ),
    r'metadata': PropertySchema(
      id: 1,
      name: r'metadata',
      type: IsarType.object,
      target: r'TwinStateMetadata',
    ),
    r'missingDataVectorsJson': PropertySchema(
      id: 2,
      name: r'missingDataVectorsJson',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _uncertaintyScoreEstimateSize,
  serialize: _uncertaintyScoreSerialize,
  deserialize: _uncertaintyScoreDeserialize,
  deserializeProp: _uncertaintyScoreDeserializeProp,
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
  embeddedSchemas: {r'TwinStateMetadata': TwinStateMetadataSchema},
  getId: _uncertaintyScoreGetId,
  getLinks: _uncertaintyScoreGetLinks,
  attach: _uncertaintyScoreAttach,
  version: '3.1.0+1',
);

int _uncertaintyScoreEstimateSize(
  UncertaintyScore object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      TwinStateMetadataSchema.estimateSize(
          object.metadata, allOffsets[TwinStateMetadata]!, allOffsets);
  bytesCount += 3 + object.missingDataVectorsJson.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _uncertaintyScoreSerialize(
  UncertaintyScore object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.globalUncertainty);
  writer.writeObject<TwinStateMetadata>(
    offsets[1],
    allOffsets,
    TwinStateMetadataSchema.serialize,
    object.metadata,
  );
  writer.writeString(offsets[2], object.missingDataVectorsJson);
  writer.writeString(offsets[3], object.userId);
}

UncertaintyScore _uncertaintyScoreDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UncertaintyScore();
  object.globalUncertainty = reader.readDouble(offsets[0]);
  object.metadata = reader.readObjectOrNull<TwinStateMetadata>(
        offsets[1],
        TwinStateMetadataSchema.deserialize,
        allOffsets,
      ) ??
      TwinStateMetadata();
  object.missingDataVectorsJson = reader.readString(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _uncertaintyScoreDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<TwinStateMetadata>(
            offset,
            TwinStateMetadataSchema.deserialize,
            allOffsets,
          ) ??
          TwinStateMetadata()) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _uncertaintyScoreGetId(UncertaintyScore object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _uncertaintyScoreGetLinks(UncertaintyScore object) {
  return [];
}

void _uncertaintyScoreAttach(
    IsarCollection<dynamic> col, Id id, UncertaintyScore object) {}

extension UncertaintyScoreQueryWhereSort
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QWhere> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UncertaintyScoreQueryWhere
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QWhereClause> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause> idBetween(
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterWhereClause>
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

extension UncertaintyScoreQueryFilter
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QFilterCondition> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      globalUncertaintyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'globalUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      globalUncertaintyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'globalUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      globalUncertaintyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'globalUncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      globalUncertaintyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'globalUncertainty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missingDataVectorsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missingDataVectorsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missingDataVectorsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missingDataVectorsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      missingDataVectorsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missingDataVectorsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
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

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension UncertaintyScoreQueryObject
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QFilterCondition> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterFilterCondition>
      metadata(FilterQuery<TwinStateMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metadata');
    });
  }
}

extension UncertaintyScoreQueryLinks
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QFilterCondition> {}

extension UncertaintyScoreQuerySortBy
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QSortBy> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByGlobalUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalUncertainty', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByGlobalUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalUncertainty', Sort.desc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByMissingDataVectorsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missingDataVectorsJson', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByMissingDataVectorsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missingDataVectorsJson', Sort.desc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UncertaintyScoreQuerySortThenBy
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QSortThenBy> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByGlobalUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalUncertainty', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByGlobalUncertaintyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalUncertainty', Sort.desc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByMissingDataVectorsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missingDataVectorsJson', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByMissingDataVectorsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missingDataVectorsJson', Sort.desc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UncertaintyScoreQueryWhereDistinct
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QDistinct> {
  QueryBuilder<UncertaintyScore, UncertaintyScore, QDistinct>
      distinctByGlobalUncertainty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'globalUncertainty');
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QDistinct>
      distinctByMissingDataVectorsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missingDataVectorsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UncertaintyScore, UncertaintyScore, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension UncertaintyScoreQueryProperty
    on QueryBuilder<UncertaintyScore, UncertaintyScore, QQueryProperty> {
  QueryBuilder<UncertaintyScore, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UncertaintyScore, double, QQueryOperations>
      globalUncertaintyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'globalUncertainty');
    });
  }

  QueryBuilder<UncertaintyScore, TwinStateMetadata, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<UncertaintyScore, String, QQueryOperations>
      missingDataVectorsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missingDataVectorsJson');
    });
  }

  QueryBuilder<UncertaintyScore, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TwinStateMetadataSchema = Schema(
  name: r'TwinStateMetadata',
  id: -471871294207664550,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'temporalDecayRate': PropertySchema(
      id: 1,
      name: r'temporalDecayRate',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'uncertainty': PropertySchema(
      id: 3,
      name: r'uncertainty',
      type: IsarType.double,
    ),
    r'version': PropertySchema(
      id: 4,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _twinStateMetadataEstimateSize,
  serialize: _twinStateMetadataSerialize,
  deserialize: _twinStateMetadataDeserialize,
  deserializeProp: _twinStateMetadataDeserializeProp,
);

int _twinStateMetadataEstimateSize(
  TwinStateMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _twinStateMetadataSerialize(
  TwinStateMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeDouble(offsets[1], object.temporalDecayRate);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeDouble(offsets[3], object.uncertainty);
  writer.writeLong(offsets[4], object.version);
}

TwinStateMetadata _twinStateMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TwinStateMetadata();
  object.confidence = reader.readDouble(offsets[0]);
  object.temporalDecayRate = reader.readDouble(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  object.uncertainty = reader.readDouble(offsets[3]);
  object.version = reader.readLong(offsets[4]);
  return object;
}

P _twinStateMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TwinStateMetadataQueryFilter
    on QueryBuilder<TwinStateMetadata, TwinStateMetadata, QFilterCondition> {
  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
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

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
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

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
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

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
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

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      temporalDecayRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temporalDecayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      temporalDecayRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temporalDecayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      temporalDecayRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temporalDecayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      temporalDecayRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temporalDecayRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      uncertaintyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      uncertaintyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      uncertaintyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uncertainty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      uncertaintyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uncertainty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<TwinStateMetadata, TwinStateMetadata, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TwinStateMetadataQueryObject
    on QueryBuilder<TwinStateMetadata, TwinStateMetadata, QFilterCondition> {}
