// =============================================================================
// models/nota.dart — o formato da nota dentro do app
// =============================================================================
// O servidor Node devolve cada nota assim:
//   {"id": "6aee...", "titulo": "Mercado", "conteudo": "pão", "criadoEm": "2026-...", "atualizadoEm": "..."}
// =============================================================================

class Nota {
  final String
      id; // ObjectId do Mongo, convertido para texto pelo toJSON do model
  final String titulo;
  final String conteudo;
  final DateTime? criadoEm;

  const Nota(
      {required this.id,
      required this.titulo,
      this.conteudo = '',
      this.criadoEm});

  // DÚVIDA COMUM: "type 'Null' is not a subtype of type 'String'"
  //   → o servidor devolveu "_id" em vez de "id": faltou o toJSON no model do Node.
  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        conteudo: json['conteudo'] as String? ?? '',
        // tryParse devolve null se a data vier ausente ou em outro formato.
        criadoEm: DateTime.tryParse(json['criadoEm'] as String? ?? ''),
      );
}
