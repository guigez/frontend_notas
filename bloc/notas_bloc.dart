// =============================================================================
// bloc/notas_bloc.dart — eventos da tela → estado (mesmo padrão do MuralBloc)
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/nota.dart';
import '../provider/notas_api.dart';

sealed class NotasEvent {}

class CarregarNotas extends NotasEvent {}

class CriarNota extends NotasEvent {
  final String titulo, conteudo;
  CriarNota(this.titulo, this.conteudo);
}

class ApagarNota extends NotasEvent {
  final String id;
  ApagarNota(this.id);
}

class NotasState {
  final List<Nota> notas;
  final bool carregando;
  final String? erro;
  const NotasState({this.notas = const [], this.carregando = false, this.erro});
}

class NotasBloc extends Bloc<NotasEvent, NotasState> {
  final NotasApi api;

  NotasBloc(this.api) : super(const NotasState()) {
    on<CarregarNotas>(_carregar);
    on<CriarNota>(_criar);
    on<ApagarNota>(_apagar);
  }

  Future<void> _carregar(CarregarNotas event, Emitter<NotasState> emit) async {
    emit(NotasState(notas: state.notas, carregando: true));
    try {
      emit(NotasState(notas: await api.listar()));
    } catch (e) {
      emit(NotasState(notas: state.notas, erro: '$e'));
    }
  }

  Future<void> _criar(CriarNota event, Emitter<NotasState> emit) async {
    try {
      await api.criar(event.titulo, event.conteudo);
      add(CarregarNotas());
    } catch (e) {
      emit(NotasState(notas: state.notas, erro: '$e'));
    }
  }

  Future<void> _apagar(ApagarNota event, Emitter<NotasState> emit) async {
    try {
      await api.apagar(event.id);
      add(CarregarNotas());
    } catch (e) {
      emit(NotasState(notas: state.notas, erro: '$e'));
    }
  }
}
