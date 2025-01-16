import 'package:fk_booster/fk_booster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements FkHttpClient {}

class MockEntity extends Mock implements FkEntity {}

class MockEntityParser extends Mock implements FkEntityParser<MockEntity> {}

MockEntity returnedMockEntity = MockEntity();

class SaveRestRepository
    extends FkRestApiRepository<MockEntity, MockEntityParser>
    with FkRestCreate<MockEntity, MockEntityParser, MockEntity> {
  const SaveRestRepository({required super.httpClient, required super.parser});

  @override
  String endpoint() => '/api/mock';

  @override
  MockEntity saveFromMap(_) => returnedMockEntity;

  @override
  FkJsonMap saveToMap(_) => {};
}

void main() {
  group('SaveRest Mixin ', () {
    late MockHttpClient httpClient;
    late MockEntityParser parser;
    late SaveRestRepository repository;

    setUp(() {
      httpClient = MockHttpClient();
      parser = MockEntityParser();
      repository = SaveRestRepository(httpClient: httpClient, parser: parser);
    });

    test(
      'Is save() calling HttpClient.post and returning the response '
      'correctly',
      () async {
        // Given
        final entityToSave = MockEntity();

        // When
        when(
          () => httpClient.post(
            repository.endpoint(),
            data: repository.saveToMap(entityToSave),
          ),
        ).thenAnswer(
          (_) => Future.value(
            const FkHttpResponse(data: <String, dynamic>{}, statusCode: 200),
          ),
        );
        final returnedEntity = await repository.save(entityToSave);
        // Then
        verify(
          () => httpClient.post(
            repository.endpoint(),
            data: repository.saveToMap(entityToSave),
          ),
        ).called(1);
        expect(returnedEntity, returnedMockEntity);
      },
    );
  });
}
