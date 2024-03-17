// ignore_for_file: annotate_overrides

part of 'message.dart';

extension MessageRepositories on Session {
  MessageRepository get messages => MessageRepository._(this);
}

abstract class MessageRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<MessageInsertRequest>,
        ModelRepositoryUpdate<MessageUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory MessageRepository._(Session db) = _MessageRepository;

  Future<MessageView?> queryMessage(int id);
  Future<List<MessageView>> queryMessages([QueryParams? params]);
}

class _MessageRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<MessageInsertRequest>,
        RepositoryUpdateMixin<MessageUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements MessageRepository {
  _MessageRepository(super.db) : super(tableName: 'messages', keyName: 'id');

  @override
  Future<MessageView?> queryMessage(int id) {
    return queryOne(id, MessageViewQueryable());
  }

  @override
  Future<List<MessageView>> queryMessages([QueryParams? params]) {
    return queryMany(MessageViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<MessageInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.execute(
      Sql.named('INSERT INTO "messages" ( "sender_id", "body", "date", "chat_id" )\n'
          'VALUES ${requests.map((r) => '( ${values.add(r.senderId)}:text, ${values.add(r.body)}:text, ${values.add(r.date)}:text, ${values.add(r.chatId)}:int8 )').join(', ')}\n'
          'RETURNING "id"'),
      parameters: values.values,
    );
    var result = rows.map<int>((r) => TextEncoder.i.decode(r.toColumnMap()['id'])).toList();

    return result;
  }

  @override
  Future<void> update(List<MessageUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.execute(
      Sql.named('UPDATE "messages"\n'
          'SET "sender_id" = COALESCE(UPDATED."sender_id", "messages"."sender_id"), "body" = COALESCE(UPDATED."body", "messages"."body"), "date" = COALESCE(UPDATED."date", "messages"."date"), "chat_id" = COALESCE(UPDATED."chat_id", "messages"."chat_id")\n'
          'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.senderId)}:text::text, ${values.add(r.body)}:text::text, ${values.add(r.date)}:text::text, ${values.add(r.chatId)}:int8::int8 )').join(', ')} )\n'
          'AS UPDATED("id", "sender_id", "body", "date", "chat_id")\n'
          'WHERE "messages"."id" = UPDATED."id"'),
      parameters: values.values,
    );
  }
}

class MessageInsertRequest {
  MessageInsertRequest({
    required this.senderId,
    required this.body,
    required this.date,
    this.chatId,
  });

  final String senderId;
  final String body;
  final String date;
  final int? chatId;
}

class MessageUpdateRequest {
  MessageUpdateRequest({
    required this.id,
    this.senderId,
    this.body,
    this.date,
    this.chatId,
  });

  final int id;
  final String? senderId;
  final String? body;
  final String? date;
  final int? chatId;
}

class MessageViewQueryable extends KeyedViewQueryable<MessageView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "messages".*'
      'FROM "messages"';

  @override
  String get tableAlias => 'messages';

  @override
  MessageView decode(TypedMap map) => MessageView(
      id: map.get('id'),
      senderId: map.get('sender_id'),
      body: map.get('body'),
      date: map.get('date'));
}

class MessageView {
  MessageView({
    required this.id,
    required this.senderId,
    required this.body,
    required this.date,
  });

  final int id;
  final String senderId;
  final String body;
  final String date;
}
