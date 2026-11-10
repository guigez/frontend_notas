// =============================================================================
// view/chat_page.dart — tela de chat com a IA
// =============================================================================
// Igual no app de Notas e no app do Mural. Recebe:
//   - titulo:   o texto da AppBar
//   - contexto: a instrução + os dados que a IA pode usar
//
// O estado aqui é só de TELA (mensagens e "pensando..."), por isso setState
// basta. Não precisa de BLoC.
// =============================================================================

import 'package:flutter/material.dart';

import '../provider/assistente.dart';

class ChatPage extends StatefulWidget {
  final String titulo;
  final String contexto;

  const ChatPage({super.key, required this.titulo, required this.contexto});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// Uma mensagem na tela: de quem é e o texto.
class _Mensagem {
  final bool doUsuario;
  final String texto;
  const _Mensagem(this.doUsuario, this.texto);
}

class _ChatPageState extends State<ChatPage> {
  final _campo = TextEditingController();
  final _mensagens = <_Mensagem>[];
  late final Assistente _assistente;
  bool _pensando = false;

  @override
  void initState() {
    super.initState();
    // Cria a conversa UMA vez, já com os dados como contexto.
    _assistente = Assistente(widget.contexto);
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final pergunta = _campo.text.trim();
    if (pergunta.isEmpty || _pensando) return;

    setState(() {
      _mensagens.add(_Mensagem(true, pergunta));
      _pensando = true;
    });
    _campo.clear();

    String resposta;
    try {
      resposta = await _assistente.perguntar(pergunta);
    } catch (e) {
      resposta = 'Erro: $e';
    }

    // Depois de um await, a tela pode ter sido fechada: confira antes do setState.
    if (!mounted) return;
    setState(() {
      _mensagens.add(_Mensagem(false, resposta));
      _pensando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_mensagens.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Faça uma pergunta. Ex.: "Resuma tudo em uma frase."',
                        textAlign: TextAlign.center),
                  ),
                for (final m in _mensagens) _balao(m),
                if (_pensando)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('pensando...',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _campo,
                    decoration: const InputDecoration(labelText: 'Pergunta'),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _enviar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Balão alinhado à direita (usuário) ou à esquerda (IA).
  Widget _balao(_Mensagem m) {
    return Align(
      alignment: m.doUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: m.doUsuario ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(m.texto),
      ),
    );
  }
}
