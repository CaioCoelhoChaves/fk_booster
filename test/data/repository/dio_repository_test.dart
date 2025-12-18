import 'package:dio/dio.dart';
import 'package:fk_booster/data/parser/entity_parser.dart';
import 'package:fk_booster/data/repository/dio_repository.dart';
import 'package:fk_booster/domain/entity/entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockEntity extends Entity {
  const MockEntity({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [id, name];
}

class MockEntityParser extends EntityParser<MockEntity>
    with FromMap<MockEntity>, ToMap<MockEntity>, GetId<MockEntity, int> {
  @override
  MockEntity fromMap(Map<String, dynamic> map) {
    return MockEntity(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(MockEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
    };
  }

  @override
  int getId(MockEntity entity) {
    return entity.id;
  }
}

class MockResponseParser extends EntityParser<Map<String, dynamic>>
    with FromMap<Map<String, dynamic>> {
  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return map;
  }
}

class TestDioRepository extends DioRepository<MockEntity> {
  TestDioRepository({required super.dio, required super.baseUrl});
}

void main() {
  group('DioRepository Raw CRUD Methods', () {
    late MockDio mockDio;
    late TestDioRepository repository;
    late MockEntityParser entityParser;
    late MockResponseParser responseParser;

    setUpAll(() {
      registerFallbackValue(RequestOptions());
    });

    setUp(() {
      mockDio = MockDio();
      repository = TestDioRepository(
        dio: mockDio,
        baseUrl: 'https://api.test.com/users',
      );
      entityParser = MockEntityParser();
      responseParser = MockResponseParser();
    });

    group('rawCreate', () {
      test('should successfully create an entity', () async {
        // Arrange
        const entity = MockEntity(id: 1, name: 'John');
        final responseData = {'id': 1, 'name': 'John', 'status': 'created'};
        when(
          () => mockDio.post<dynamic>(
            'https://api.test.com/users',
            data: entityParser.toMap(entity),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawCreate<Map<String, dynamic>>(
          entity: entity,
          entityParser: entityParser,
          responseParser: responseParser,
        );

        // Assert
        expect(result, equals(responseData));
        verify(
          () => mockDio.post<dynamic>(
            'https://api.test.com/users',
            data: entityParser.toMap(entity),
          ),
        ).called(1);
      });

      test('should throw on failed create', () async {
        // Arrange
        const entity = MockEntity(id: 1, name: 'John');
        when(
          () => mockDio.post<dynamic>(
            'https://api.test.com/users',
            data: entityParser.toMap(entity),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawCreate<Map<String, dynamic>>(
            entity: entity,
            entityParser: entityParser,
            responseParser: responseParser,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('rawGetById', () {
      test('should successfully retrieve entity by id', () async {
        // Arrange
        const id = 1;
        final responseData = {'id': 1, 'name': 'John'};
        when(
          () => mockDio.get<dynamic>('https://api.test.com/users/1'),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawGetById<int>(
          id: id,
          idParser: entityParser,
          entityParser: entityParser,
        );

        // Assert
        expect(result.id, equals(1));
        expect(result.name, equals('John'));
        verify(
          () => mockDio.get<dynamic>('https://api.test.com/users/1'),
        ).called(1);
      });

      test('should throw when entity not found', () async {
        // Arrange
        const id = 999;
        when(
          () => mockDio.get<dynamic>('https://api.test.com/users/999'),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawGetById<int>(
            id: id,
            idParser: entityParser,
            entityParser: entityParser,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('rawGetAll', () {
      test('should successfully retrieve all entities', () async {
        // Arrange
        final responseData = [
          {'id': 1, 'name': 'John'},
          {'id': 2, 'name': 'Jane'},
        ];
        when(
          () => mockDio.get<dynamic>('https://api.test.com/users'),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawGetAll(entityParser: entityParser);

        // Assert
        expect(result, isA<List<MockEntity>>());
        expect(result.length, equals(2));
        expect(result[0].name, equals('John'));
        expect(result[1].name, equals('Jane'));
        verify(
          () => mockDio.get<dynamic>('https://api.test.com/users'),
        ).called(1);
      });

      test('should return empty list when no entities found', () async {
        // Arrange
        when(
          () => mockDio.get<dynamic>('https://api.test.com/users'),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: <dynamic>[],
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawGetAll(entityParser: entityParser);

        // Assert
        expect(result, isEmpty);
      });

      test('should throw on network error', () async {
        // Arrange
        when(
          () => mockDio.get<dynamic>('https://api.test.com/users'),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawGetAll(entityParser: entityParser),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('rawUpdate', () {
      test('should successfully update an entity', () async {
        // Arrange
        const entity = MockEntity(id: 1, name: 'Jane');
        final responseData = {'id': 1, 'name': 'Jane', 'status': 'updated'};
        when(
          () => mockDio.put<dynamic>(
            'https://api.test.com/users/1',
            data: entityParser.toMap(entity),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawUpdate<Map<String, dynamic>, int>(
          entity: entity,
          entityParser: entityParser,
          idParser: entityParser,
          responseParser: responseParser,
        );

        // Assert
        expect(result, equals(responseData));
        verify(
          () => mockDio.put<dynamic>(
            'https://api.test.com/users/1',
            data: entityParser.toMap(entity),
          ),
        ).called(1);
      });

      test('should throw when updating non-existent entity', () async {
        // Arrange
        const entity = MockEntity(id: 999, name: 'Ghost');
        when(
          () => mockDio.put<dynamic>(
            'https://api.test.com/users/999',
            data: entityParser.toMap(entity),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawUpdate<Map<String, dynamic>, int>(
            entity: entity,
            entityParser: entityParser,
            idParser: entityParser,
            responseParser: responseParser,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('rawDelete', () {
      test('should successfully delete an entity', () async {
        // Arrange
        const entity = MockEntity(id: 1, name: 'John');
        final responseData = {'id': 1, 'status': 'deleted'};
        when(
          () => mockDio.delete<dynamic>('https://api.test.com/users/1'),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final result = await repository.rawDelete<Map<String, dynamic>, int>(
          entity: entity,
          idParser: entityParser,
          responseParser: responseParser,
        );

        // Assert
        expect(result, equals(responseData));
        verify(
          () => mockDio.delete<dynamic>('https://api.test.com/users/1'),
        ).called(1);
      });

      test('should throw when deleting non-existent entity', () async {
        // Arrange
        const entity = MockEntity(id: 999, name: 'Ghost');
        when(
          () => mockDio.delete<dynamic>('https://api.test.com/users/999'),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawDelete<Map<String, dynamic>, int>(
            entity: entity,
            idParser: entityParser,
            responseParser: responseParser,
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('should throw on network error', () async {
        // Arrange
        const entity = MockEntity(id: 1, name: 'John');
        when(
          () => mockDio.delete<dynamic>('https://api.test.com/users/1'),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => repository.rawDelete<Map<String, dynamic>, int>(
            entity: entity,
            idParser: entityParser,
            responseParser: responseParser,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
