// =============================================================================
// provider/notas_api.dart — a única parte do app que fala com o NOSSO servidor
// =============================================================================
//   listar()  -> GET    /notas       -> 200 + lista
//   criar()   -> POST   /notas       -> 201
//   apagar()  -> DELETE /notas/{id}  -> 204
// =============================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/nota.dart';

// Servidor Node rodando na mesma máquina, SEM barra no final.
// Emulador Android: http://10.0.2.2:3000
const apiUrl = 'https://backend-notas-9dw9.onrender.com';

class NotasApi {
  Future<List<Nota>> listar() async {
    final resposta = await http.get(Uri.parse('$apiUrl/notas'));
    if (resposta.statusCode != 200)
      throw Exception('Erro ${resposta.statusCode}');
    final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List;
    return lista.map((json) => Nota.fromJson(json)).toList();
  }

  Future<void> criar(String titulo, String conteudo) async {
    final resposta = await http.post(
      Uri.parse('$apiUrl/notas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'titulo': titulo, 'conteudo': conteudo}),
    );
    // 400 = título vazio ou longo demais (a validação está no service do Node).
    if (resposta.statusCode != 201)
      throw Exception('Erro ${resposta.statusCode}');
  }

  Future<void> apagar(String id) async {
    final resposta = await http.delete(Uri.parse('$apiUrl/notas/$id'));
    if (resposta.statusCode != 204)
      throw Exception('Erro ${resposta.statusCode}');
  }
}

// "ClientException: Failed to fetch" no Chrome:
//   servidor Node desligado, URL com barra no final, ou falta app.use(cors()).
