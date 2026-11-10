// =============================================================================
// provider/assistente.dart — a conversa com a IA (Firebase AI Logic)
// =============================================================================
// Este arquivo é IGUAL no app de Notas e no app do Mural: só muda o "contexto"
// que a tela passa ao criar o Assistente.
//
// Como funciona:
//   1. O app chama o Gemini DIRETO, sem passar pelo servidor Node. Quem
//      autoriza é o projeto Firebase (firebase_options.dart); não há chave de
//      API no código.
//   2. A "systemInstruction" é a regra fixa da conversa. Colocamos nela os
//      dados que vieram do NOSSO servidor (as notas ou os recados).
//   3. O ChatSession guarda o histórico: cada pergunta nova chega ao modelo
//      junto com as anteriores, e por isso ele "lembra" da conversa.
// =============================================================================

import 'package:firebase_ai/firebase_ai.dart';

// Modelo recomendado pelo Firebase AI Logic (confira na documentação antes da aula:
// https://firebase.google.com/docs/ai-logic/models).
const modeloGemini = 'gemini-3.5-flash-lite';

class Assistente {
  final ChatSession _chat;

  Assistente(String contexto)
      : _chat =
            FirebaseAI.googleAI() // Gemini Developer API (tem plano gratuito)
                .generativeModel(
                  model: modeloGemini,
                  systemInstruction: Content.system(contexto),
                )
                .startChat();

  /// Envia a pergunta e devolve o texto da resposta.
  Future<String> perguntar(String pergunta) async {
    // timeout: sem ele, uma chamada travada deixa a tela em "pensando..." para sempre.
    final resposta = await _chat
        .sendMessage(Content.text(pergunta))
        .timeout(const Duration(seconds: 60));
    // "text" pode ser null (ex.: resposta bloqueada pelo filtro de segurança).
    return resposta.text ?? '(sem resposta)';
  }
}

// DÚVIDAS COMUNS
// • "App Check token is invalid" / 401: o App Check está sendo exigido e o app
//   não mandou token. Veja o roteiro: adiar a obrigatoriedade no console ou
//   registrar o debug token.
// • 429 / "quota exceeded": a turma toda usa o mesmo projeto e passou do
//   limite do plano gratuito. Espere um minuto e tente de novo.
// • TimeoutException depois de 60 s: a chamada não voltou. Veja o Debug Console;
//   teste outro modelo (ex.: 'gemini-3.5-flash-lite', mais rápido) e a internet do emulador.
// • A resposta inventa notas que não existem: reforce na instrução "use SÓ os
//   dados abaixo; se não souber, diga que não sabe".
