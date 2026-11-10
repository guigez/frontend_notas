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
//   4. A resposta vem em STREAM: o texto aparece na tela enquanto o modelo escreve.
// =============================================================================

import 'package:firebase_ai/firebase_ai.dart';

// Modelo "lite": mais rápido e menos disputado que o principal. Com a turma toda
// chamando ao mesmo tempo, o principal ('gemini-3.8-flash') às vezes responde
// 500 "high demand". Lista atual: https://firebase.google.com/docs/ai-logic/models
const modeloGemini = 'gemini-3.5-flash-lite';

class Assistente {
  final ChatSession _chat;

  Assistente(String contexto)
      : _chat = FirebaseAI.googleAI() // Gemini Developer API (tem plano gratuito)
            .generativeModel(
              model: modeloGemini,
              systemInstruction: Content.system(contexto),
            )
            .startChat();

  /// Envia a pergunta e devolve a resposta EM PEDAÇOS, conforme o modelo escreve.
  ///
  /// Future × Stream: o NotasApi.listar() devolve um Future porque a lista chega
  /// inteira, de uma vez. Aqui o texto da IA chega aos poucos, várias vezes,
  /// para uma única pergunta: é o caso típico de Stream.
  Stream<String> perguntarStream(String pergunta) {
    return _chat
        .sendMessageStream(Content.text(pergunta))
        // timeout entre um pedaço e outro: se a resposta travar, o stream lança
        // TimeoutException em vez de deixar a tela em "pensando..." para sempre.
        .timeout(const Duration(seconds: 60))
        // Cada pedaço é um GenerateContentResponse; pegamos só o texto dele.
        // "text" pode ser null (ex.: trecho bloqueado pelo filtro de segurança).
        .map((pedaco) => pedaco.text ?? '');
  }
}

// DÚVIDAS COMUNS
// • "App Check token is invalid" / 401: o App Check está sendo exigido e o app
//   não mandou token. Veja o roteiro: adiar a obrigatoriedade no console ou
//   registrar o debug token.
// • 429 / "quota exceeded": a turma toda usa o mesmo projeto e passou do
//   limite do plano gratuito. Espere um minuto e tente de novo.
// • 500 / 503 "This model is currently experiencing high demand": o Google está
//   sobrecarregado (não é erro nosso). Tente de novo em alguns segundos.
// • TimeoutException depois de 60 s: a chamada não voltou. Veja o Debug Console;
//   teste outro modelo e a internet do emulador.
// • A resposta inventa notas que não existem: reforce na instrução "use SÓ os
//   dados abaixo; se não souber, diga que não sabe".
