// =============================================================================
// view/notas_page.dart — lista, criação e exclusão de notas + botão do chat
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notas_bloc.dart';
import '../models/nota.dart';
import 'chat_page.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _titulo = TextEditingController();
  final _conteudo = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _conteudo.dispose();
    super.dispose();
  }

  void _criar() {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) return;
    context.read<NotasBloc>().add(CriarNota(titulo, _conteudo.text.trim()));
    _titulo.clear();
    _conteudo.clear();
  }

  /// Monta o texto que vai como "systemInstruction" para a IA:
  /// a regra da conversa + as notas que vieram do servidor Node.
  String _contexto(List<Nota> notas) {
    final linhas = notas.map((n) => '- ${n.titulo}: ${n.conteudo}').join('\n');
    return 'Você é um assistente que responde perguntas sobre as notas do usuário. '
        'Responda em português, em poucas frases. '
        'Use SÓ as notas abaixo; se a resposta não estiver nelas, diga que não sabe.\n\n'
        'Notas (${notas.length}):\n$linhas';
  }

  void _abrirChat() {
    // As notas que já estão na tela (o último GET /notas).
    final notas = context.read<NotasBloc>().state.notas;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatPage(titulo: 'Pergunte às notas', contexto: _contexto(notas)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NotasBloc>().add(CarregarNotas()),
          ),
        ],
      ),
      // Botão flutuante que abre o chat com a IA.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirChat,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Perguntar à IA'),
        tooltip: 'Conversar com a IA sobre as notas',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _titulo,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _conteudo,
                    decoration: const InputDecoration(labelText: 'Conteúdo'),
                    onSubmitted: (_) => _criar(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _criar),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NotasBloc, NotasState>(
              builder: (context, state) {
                if (state.carregando && state.notas.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.erro != null) {
                  return Center(child: Text(state.erro!));
                }
                if (state.notas.isEmpty) {
                  return const Center(child: Text('Nenhuma nota ainda.'));
                }
                return ListView(
                  // Espaço no fim para o botão flutuante não cobrir o último item.
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    for (final n in state.notas)
                      ListTile(
                        title: Text(n.titulo),
                        subtitle: n.conteudo.isEmpty ? null : Text(n.conteudo),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              context.read<NotasBloc>().add(ApagarNota(n.id)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
