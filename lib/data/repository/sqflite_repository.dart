import 'package:fk_booster/data/parser/entity_parser.dart';
import 'package:fk_booster/data/parser/to_entity_list_parser.dart';
import 'package:fk_booster/domain/repository/repository.dart';
import 'package:sqflite/sqflite.dart';

abstract class SqfliteRepository<Entity> extends Repository<Entity> {
  const SqfliteRepository(this.db);

  final Database db;
  String get table;

  Future<int> sqfliteCreate(Entity entity, ToMap<Entity> toMap) async =>
      db.insert(table, toMap.toMap(entity));

  Future<List<Entity>> sqfliteGetAll(FromMap<Entity> fromMap) async =>
      toEntityListParser(await db.query(table), fromMap.fromMap);
}
