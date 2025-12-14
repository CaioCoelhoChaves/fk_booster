mixin Delete<Entity, Response> {
  Future<Response> delete(Entity entity);
}
