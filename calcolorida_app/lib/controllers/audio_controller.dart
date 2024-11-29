import 'dart:async'; // Import necessário para usar StreamSubscription
import 'package:just_audio/just_audio.dart';
import 'package:calcolorida_app/constants/constants.dart';

AudioPlayer? player; // Instância única do AudioPlayer
Map<int, UriAudioSource> digitToAudioSource = {}; // Mapeia dígitos para UriAudioSource
bool _shouldStop = false; // Variável para controlar a reprodução

// Variáveis para armazenar os callbacks e o total de notas
Function(int noteIndex)? _onNoteStarted;
Function(int noteIndex)? _onNoteFinished;
int _totalNotes = 0;

// Modifique aqui: Adicione o '?' após 'SequenceState?'
StreamSubscription<SequenceState?>? _sequenceStateSubscription;
StreamSubscription<ProcessingState>? _processingStateSubscription;

/// Inicializar as fontes de áudio
Future<void> initializeAudio() async {
  try {
    if (player == null) {
      player = AudioPlayer();

      // Escutar mudanças no estado da sequência
      _sequenceStateSubscription = player!.sequenceStateStream.listen((sequenceState) {
        if (sequenceState != null && _onNoteStarted != null) {
          int currentIndex = sequenceState.currentIndex;
          _onNoteStarted!(currentIndex);
        }
      });

      // Escutar mudanças no estado de processamento
      _processingStateSubscription = player!.processingStateStream.listen((processingState) {
        if (processingState == ProcessingState.completed) {
          // Notificar que a reprodução terminou
          if (_onNoteFinished != null) {
            _onNoteFinished!(_totalNotes - 1);
          }
        }
      });
    }

    // Inicializar as fontes de áudio apenas uma vez
    if (digitToAudioSource.isEmpty) {
      for (int digit = 0; digit <= 9; digit++) {
        String note = digitToNote[digit]!; // Obter o nome da nota
        String audioPathMp3 = 'assets/sounds/${note}_Piano_Acustico.mp3';
        // Criar uma UriAudioSource para cada nota
        UriAudioSource source = AudioSource.asset(audioPathMp3) as UriAudioSource;
        digitToAudioSource[digit] = source;
      }
    }
  } catch (e) {
    print("Erro ao inicializar fontes de áudio: $e");
  }
}

void startPlayback() {
  _shouldStop = false;
}

void stopPlayback() {
  _shouldStop = true;
}

/// Reproduzir a melodia com cada nota tocando por uma duração específica
Future<void> playMelodyAudio({
  required List<int> digits,
  int durationMs = 500,
  Function(int noteIndex)? onNoteStarted,
  Function(int noteIndex)? onNoteFinished,
  Function()? onPlaybackCompleted, //Novo callback
}) async {
  try {
    if (player == null) {
      await initializeAudio();
    }

    // Atualizar os callbacks
    _onNoteStarted = onNoteStarted;
    _onNoteFinished = onNoteFinished;
    _totalNotes = digits.length;

    List<AudioSource> sequence = [];

    for (int i = 0; i < digits.length; i++) {
      int digit = digits[i];
      if (digitToAudioSource.containsKey(digit)) {
        UriAudioSource originalSource = digitToAudioSource[digit]!;

        // Clipping da fonte original
        ClippingAudioSource clippedSource = ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i, // Usaremos a propriedade 'tag' para identificar o índice
        );

        sequence.add(clippedSource);
      }
    }

    // Criar uma sequência concatenada de áudio
    ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: sequence);

    await player!.setAudioSource(playlist);

    // Iniciar a reprodução
    await player!.play();

  } catch (e) {
    print("Erro ao reproduzir a melodia: $e");
  }
}

/// Método para parar o áudio
Future<void> stopAudio() async {
  try {
    await player?.stop(); // Parar o áudio
    await player?.seek(Duration.zero); // Reiniciar para o início
  } catch (e) {
    print("Erro ao parar o áudio: $e");
  }
}

Future<void> disposeAudio() async {
  try {
    await player?.dispose(); // Liberar recursos do player
    await _sequenceStateSubscription?.cancel(); // Cancelar a inscrição
    await _processingStateSubscription?.cancel(); // Cancelar a inscrição
    player = null;
  } catch (e) {
    print("Erro ao liberar o player: $e");
  }
}
