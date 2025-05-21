// controllers/audio_controller.dart
import 'dart:async';

// Usando alias para just_audio para evitar conflito com AudioPlayer de audioplayers
import 'package:just_audio/just_audio.dart' as just;
import 'package:audioplayers/audioplayers.dart'; // Para os sons do keypad
import 'package:calcolorida_app/constants/constants.dart';
// Removido: import 'package:flutter/services.dart'; // rootBundle não é mais necessário aqui diretamente se audioplayers lida com assets

// --- Variáveis Globais do Controller ---
String selectedInstrument = 'piano'; // Usado por todos os players para carregar os sons corretos

// --- Configurações para just_audio (Melodias do Mosaico e Desafio) ---
just.AudioPlayer? mainPlayer;
just.AudioPlayer? challengePlayer;

Map<int, just.UriAudioSource> digitToAudioSourceMain = {};
Map<int, just.UriAudioSource> digitToAudioSourceChallenge = {};

// Callbacks e Subscriptions para just_audio
Function(int noteIndex)? _onMainNoteStarted;
Function(int noteIndex)? _onMainNoteFinished;
int _totalMainNotes = 0;

Function(int noteIndex)? _onChallengeNoteStarted;
Function(int noteIndex)? _onChallengeNoteFinished;
int _totalChallengeNotes = 0;

StreamSubscription<just.SequenceState?>? _mainSequenceStateSubscription;
StreamSubscription<just.ProcessingState>? _mainProcessingStateSubscription;
StreamSubscription<just.SequenceState?>? _challengeSequenceStateSubscription;
StreamSubscription<just.ProcessingState>? _challengeProcessingStateSubscription;


// --- Configurações para audioplayers (Sons dos Botões do Teclado) ---
AudioPlayer? _keypadSfxPlayer; // Player dedicado para os sons do keypad
                               // Não precisa de AudioCache explícito aqui,
                               // pois o AssetSource lida com o cache internamente
                               // para assets. Se quiséssemos mais controle sobre o cache,
                               // poderíamos usar AudioCache, mas para este caso, AssetSource é suficiente.

Map<String, String> instrumentFileNameMap = {
  'piano': 'Piano_Acustico',
  'baixo': 'Baixo_Eletrico_Dedo',
  'banjo': 'Banjo',
  'flauta': 'Flauta',
  'flautadoce': 'Flauta_Doce',
  'guitarra': 'Guitarra_Eletrica_Limpa',
  'orgao': 'Órgão_Hammond',
  'pianoeletrico': 'Piano_Eletrico_1',
  'sitar': 'Sitar',
  'trompete': 'Trompete',
  'violino': 'Violino',
};

Map<String, String> instrumentDisplayNameMap = {
  'piano': 'Piano Acústico',
  'baixo': 'Baixo Elétrico',
  'banjo': 'Banjo',
  'flauta': 'Flauta',
  'flautadoce': 'Flauta Doce',
  'guitarra': 'Guitarra Elétrica',
  'orgao': 'Órgão Hammond',
  'pianoeletrico': 'Piano Elétrico',
  'sitar': 'Sitar',
  'trompete': 'Trompete',
  'violino': 'Violino',
};

// --- Funções de Inicialização e Controle para audioplayers (Keypad SFX) ---

Future<void> initializeKeypadAudio() async {
  _keypadSfxPlayer ??= AudioPlayer();
  // Configura o player para parar o som anterior ao iniciar um novo,
  // ou liberar recursos após a reprodução. ReleaseMode.stop é bom para feedback rápido.
  _keypadSfxPlayer!.setReleaseMode(ReleaseMode.stop);
  // Não é necessário pré-carregar explicitamente com AssetSource,
  // o player lida com isso. Se houvesse muitos sons diferentes e complexos,
  // ou se quiséssemos controle fino sobre o cache, usaríamos AudioCache.
  // Para sons de botão simples, AssetSource é eficiente.
  print("Keypad SFX Player (audioplayers) inicializado.");
}

Future<void> playKeypadSound(int digit) async {
  if (_keypadSfxPlayer == null) {
    print("Keypad SFX Player não inicializado. Tentando inicializar...");
    await initializeKeypadAudio();
    if (_keypadSfxPlayer == null) {
      print("Falha ao inicializar Keypad SFX Player.");
      return;
    }
  }

  final noteName = digitToNote[digit]!;
  final fileNamePrefix = instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';
  // O AssetSource espera o caminho completo a partir da pasta 'assets/'
  final soundPath = 'sounds/$selectedInstrument/${noteName}_$fileNamePrefix.mp3';

  try {
    // Para garantir que o som anterior pare (se houver um tocando neste player)
   // await _keypadSfxPlayer!.stop();
    // AssetSource é a forma recomendada para tocar assets locais com baixa latência.
      if (_keypadSfxPlayer!.releaseMode != ReleaseMode.stop) {
        _keypadSfxPlayer!.setReleaseMode(ReleaseMode.stop);
    }

    await _keypadSfxPlayer!.play(AssetSource(soundPath));
    // print("Tocando SFX: $soundPath");
  } catch (e) {
    print("Erro ao tocar som do keypad ($digit - $soundPath) com audioplayers: $e");
  }
}

// Esta função será chamada quando o instrumento mudar na UI.
// Ela atualiza a variável global `selectedInstrument` e sinaliza
// que os players (tanto just_audio quanto audioplayers) precisam
// usar os novos sons.
// As funções de inicialização (initializeMainAudio, initializeChallengeAudio, initializeKeypadAudio)
// já leem `selectedInstrument`, então chamá-las novamente após atualizar
// `selectedInstrument` fará com que carreguem os sons corretos.
// O `initializeKeypadAudio` em si não precisa de recarga explícita de assets aqui,
// pois `playKeypadSound` busca o path dinamicamente.
Future<void> updateSelectedInstrumentForAudio(String newInstrument) async {
  selectedInstrument = newInstrument;
  print("Instrumento de áudio atualizado para: $newInstrument");
  // As funções de inicialização/recarregamento dos players (just_audio e audioplayers)
  // devem ser chamadas na UI (CalculatorScreen) após esta atualização.
  // Ex:
  // await audio_controller.updateSelectedInstrumentForAudio(newInstrument);
  // await audio_controller.initializeMainAudio();
  // await audio_controller.initializeChallengeAudio();
  // await audio_controller.initializeKeypadAudio(); // Garante que o player SFX está pronto
}


// --- Funções de Inicialização e Controle para just_audio (Melodias) ---
// (Mantendo a lógica original, apenas usando o alias 'just.')

Future<void> initializeMainAudio() async {
  if (mainPlayer == null) {
    mainPlayer = just.AudioPlayer();
    _mainSequenceStateSubscription =
        mainPlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onMainNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
        _onMainNoteStarted!(currentIndex);
      }
    });
    _mainProcessingStateSubscription =
        mainPlayer!.processingStateStream.listen((processingState) {
      if (processingState == just.ProcessingState.completed) {
        if (_onMainNoteFinished != null) {
          _onMainNoteFinished!(_totalMainNotes - 1);
        }
      }
    });
    print("Main Player (just_audio) inicializado.");
  }

  digitToAudioSourceMain.clear();
  final fileNamePrefix = instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';
  try {
    for (int digit = 0; digit <= 9; digit++) {
      final note = digitToNote[digit]!;
      final audioPath = 'assets/sounds/$selectedInstrument/${note}_$fileNamePrefix.mp3';
      final source = just.AudioSource.asset(audioPath);
      digitToAudioSourceMain[digit] = source;
    }
    // print("Fontes de áudio MAIN (just_audio) carregadas para $selectedInstrument.");
  } catch (e) {
    print("Erro ao inicializar fontes de áudio MAIN (just_audio) para $selectedInstrument: $e");
  }
}

Future<void> initializeChallengeAudio() async {
  if (challengePlayer == null) {
    challengePlayer = just.AudioPlayer();
    _challengeSequenceStateSubscription =
        challengePlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onChallengeNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
        _onChallengeNoteStarted!(currentIndex);
      }
    });
    _challengeProcessingStateSubscription =
        challengePlayer!.processingStateStream.listen((processingState) {
      if (processingState == just.ProcessingState.completed) {
        if (_onChallengeNoteFinished != null) {
          _onChallengeNoteFinished!(_totalChallengeNotes - 1);
        }
      }
    });
    print("Challenge Player (just_audio) inicializado.");
  }

  digitToAudioSourceChallenge.clear();
  final fileNamePrefix = instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';
  try {
    for (int digit = 0; digit <= 9; digit++) {
      final note = digitToNote[digit]!;
      final audioPath = 'assets/sounds/$selectedInstrument/${note}_$fileNamePrefix.mp3';
      final source = just.AudioSource.asset(audioPath);
      digitToAudioSourceChallenge[digit] = source;
    }
    // print("Fontes de áudio CHALLENGE (just_audio) carregadas para $selectedInstrument.");
  } catch (e) {
    print("Erro ao inicializar fontes de áudio CHALLENGE (just_audio) para $selectedInstrument: $e");
  }
}

Future<void> playMainMelodyAudio({
  required List<int> digits,
  int durationMs = 500,
  required int delayMs,
  Function(int noteIndex)? onNoteStarted,
  Function(int noteIndex)? onNoteFinished,
  Function()? onPlaybackCompleted,
}) async {
  try {
    if (mainPlayer == null) {
      await initializeMainAudio();
    }
    if (mainPlayer == null) { // Checagem extra
        print("playMainMelodyAudio: mainPlayer ainda é nulo.");
        return;
    }


    _onMainNoteStarted = onNoteStarted;
    _onMainNoteFinished = onNoteFinished;
    _totalMainNotes = digits.length;

    List<just.AudioSource> sequence = [];
    // O AssetSource aqui para o just_audio player
    final silenceAudio = just.AudioSource.asset('assets/sounds/silence.mp3');

    for (int i = 0; i < digits.length; i++) {
      final digit = digits[i];
      if (digitToAudioSourceMain.containsKey(digit)) {
        final originalSource = digitToAudioSourceMain[digit]!;
        final clippedSource = just.ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i,
        );
        sequence.add(clippedSource);
      }
      if (delayMs > 0 && i < digits.length -1) { // Adiciona silêncio entre as notas, não no final
        final clippedSilence = just.ClippingAudioSource(
          child: silenceAudio,
          start: Duration.zero,
          end: Duration(milliseconds: delayMs),
          tag: -1, // Tag para silêncio
        );
        sequence.add(clippedSilence);
      }
    }

    if (sequence.isEmpty) {
      print("playMainMelodyAudio: Nenhuma nota para tocar.");
      onPlaybackCompleted?.call();
      return;
    }

    final playlist = just.ConcatenatingAudioSource(children: sequence);
    await mainPlayer!.setAudioSource(playlist); // ÚNICA chamada a setAudioSource para a melodia

    // Remover o listener antigo e adicionar um novo para evitar múltiplos callbacks
    _mainProcessingStateSubscription?.cancel();
    _mainProcessingStateSubscription = mainPlayer!.processingStateStream.listen((state) {
      if (state == just.ProcessingState.completed) {
        onPlaybackCompleted?.call();
        _mainProcessingStateSubscription?.cancel(); // Limpa o listener após completar
      }
    });
    // O _mainSequenceStateSubscription já está configurado em initializeMainAudio
    // Pode ser necessário reconfigurá-lo se os callbacks mudarem, ou gerenciá-lo com cuidado.

    await mainPlayer!.play();
  } catch (e) {
    print("Erro ao reproduzir a melodia MAIN (just_audio): $e");
    onPlaybackCompleted?.call(); // Chama o callback de conclusão em caso de erro também
  }
}

Future<void> playChallengeMelodyAudio({
  required List<int> digits,
  int durationMs = 500,
  required int delayMs,
  Function(int noteIndex)? onNoteStarted,
  Function(int noteIndex)? onNoteFinished,
  Function()? onPlaybackCompleted,
}) async {
  try {
    if (challengePlayer == null) {
      await initializeChallengeAudio();
    }
    if (challengePlayer == null) { // Checagem extra
        print("playChallengeMelodyAudio: challengePlayer ainda é nulo.");
        return;
    }

    _onChallengeNoteStarted = onNoteStarted;
    _onChallengeNoteFinished = onNoteFinished;
    _totalChallengeNotes = digits.length;

    List<just.AudioSource> sequence = [];
    final silenceAudio = just.AudioSource.asset('assets/sounds/silence.mp3');

    for (int i = 0; i < digits.length; i++) {
      final digit = digits[i];
      if (digitToAudioSourceChallenge.containsKey(digit)) {
        final originalSource = digitToAudioSourceChallenge[digit]!;
        final clippedSource = just.ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i,
        );
        sequence.add(clippedSource);
      }
      if (delayMs > 0 && i < digits.length -1) {
        final clippedSilence = just.ClippingAudioSource(
          child: silenceAudio,
          start: Duration.zero,
          end: Duration(milliseconds: delayMs),
          tag: -1,
        );
        sequence.add(clippedSilence);
      }
    }

    if (sequence.isEmpty) {
      print("playChallengeMelodyAudio: Nenhuma nota para tocar.");
      onPlaybackCompleted?.call();
      return;
    }

    final playlist = just.ConcatenatingAudioSource(children: sequence);
    await challengePlayer!.setAudioSource(playlist);

    _challengeProcessingStateSubscription?.cancel();
    _challengeProcessingStateSubscription = challengePlayer!.processingStateStream.listen((state) {
      if (state == just.ProcessingState.completed) {
        onPlaybackCompleted?.call();
        _challengeProcessingStateSubscription?.cancel();
      }
    });

    await challengePlayer!.play();
  } catch (e) {
    print("Erro ao reproduzir a melodia CHALLENGE (just_audio): $e");
    onPlaybackCompleted?.call();
  }
}

Future<void> stopMainAudio() async {
  try {
    await mainPlayer?.stop();
    await mainPlayer?.seek(Duration.zero); // Opcional, para resetar a posição
  } catch (e) {
    print("Erro ao parar o áudio MAIN (just_audio): $e");
  }
}

Future<void> stopChallengeAudio() async {
  try {
    await challengePlayer?.stop();
    await challengePlayer?.seek(Duration.zero);
  } catch (e) {
    print("Erro ao parar o áudio CHALLENGE (just_audio): $e");
  }
}

// --- Função de Dispose Geral ---
Future<void> disposeAllAudio() async {
  print("Dispondo todos os players de áudio...");
  try {
    // just_audio players
    await mainPlayer?.dispose();
    _mainSequenceStateSubscription?.cancel();
    _mainProcessingStateSubscription?.cancel();
    mainPlayer = null;
    print("Main Player (just_audio) disposed.");

    await challengePlayer?.dispose();
    _challengeSequenceStateSubscription?.cancel();
    _challengeProcessingStateSubscription?.cancel();
    challengePlayer = null;
    print("Challenge Player (just_audio) disposed.");

    // audioplayers (keypad SFX)
    await _keypadSfxPlayer?.dispose();
    _keypadSfxPlayer = null;
    print("Keypad SFX Player (audioplayers) disposed.");

  } catch (e) {
    print("Erro ao liberar todos os players de áudio: $e");
  }
}