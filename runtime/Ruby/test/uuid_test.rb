require '../antlr4/UUID'

u1 = Uuid.fromString('59627784-3BE5-417A-B9EB-8131A7286089')
u2 = Uuid.fromString('59627784-3BE5-417A-B9EB-8131A7286089')
puts u1 == u2