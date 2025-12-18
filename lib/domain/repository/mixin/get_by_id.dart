mixin GetById<Entity, IdType> {
  Future<Entity> getById(IdType id);
}
