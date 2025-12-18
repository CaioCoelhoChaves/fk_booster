mixin Create<Entity, Response> {
  Future<Response> create(Entity entity);
}
