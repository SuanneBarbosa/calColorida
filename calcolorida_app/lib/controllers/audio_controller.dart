import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:calcolorida_app/constants/constants.dart';

AudioPlayer? player; 
Map<int, UriAudioSource> digitToAudioSource = {};
bool _shouldStop = false;

Function(int noteIndex)? _onNoteStarted;
Function(int noteIndex)? _onNoteFinished;
int _totalNotes = 0;
String selectedInstrument = 'piano'; 
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


StreamSubscription<SequenceState?>? _sequenceStateSubscription;
StreamSubscription<ProcessingState>? _processingStateSubscription;


Future<void> initializeAudio() async {
  try {
    if (player == null) {
      player = AudioPlayer();

      
      _sequenceStateSubscription = player!.sequenceStateStream.listen((sequenceState) {
        if (sequenceState != null && _onNoteStarted != null) {
          int currentIndex = sequenceState.currentIndex;
          _onNoteStarted!(currentIndex);
        }
      });
      
      _processingStateSubscription = player!.processingStateStream.listen((processingState) {
        if (processingState == ProcessingState.completed) {
         
          if (_onNoteFinished != null) {
            _onNoteFinished!(_totalNotes - 1);
          }
        }
      });
      
    }
  
    digitToAudioSource.clear();

    
    String fileNamePrefix = instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';

    for (int digit = 0; digit <= 9; digit++) {
      String note = digitToNote[digit]!;
      String audioPath = 'assets/sounds/$selectedInstrument/${note}_$fileNamePrefix.mp3';
     
      UriAudioSource source = AudioSource.asset(audioPath);
      digitToAudioSource[digit] = source;
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


Future<void> playMelodyAudio({
  required List<int> digits,
  int durationMs = 500,
  required int delayMs,
  Function(int noteIndex)? onNoteStarted,
  Function(int noteIndex)? onNoteFinished,
  Function()? onPlaybackCompleted,
}) async {
  try {
    if (player == null) {
      await initializeAudio();
    }

    _onNoteStarted = onNoteStarted;
    _onNoteFinished = onNoteFinished;
    _totalNotes = digits.length;

    List<AudioSource> sequence = [];
    String silenceAudioPath = 'assets/sounds/silence.mp3';
    UriAudioSource silenceAudio = AudioSource.asset(silenceAudioPath);
    for (int i = 0; i < digits.length; i++) {
      int digit = digits[i];
      if (digitToAudioSource.containsKey(digit)) {
        UriAudioSource originalSource = digitToAudioSource[digit]!;
        ClippingAudioSource clippedSource = ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i, 
        );
        sequence.add(clippedSource);
      }
      if(delayMs > 0) {
        ClippingAudioSource clippedSource = ClippingAudioSource(
          child: silenceAudio,
          start: Duration.zero,
          end: Duration(milliseconds: delayMs),
          tag: -1, 
        );
        sequence.add(clippedSource);
      }
    }

    ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: sequence);

    await player!.setAudioSource(playlist);

    _sequenceStateSubscription = player!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onNoteStarted != null) {
        int currentIndex = sequenceState.currentIndex;
        int indexForCallback = delayMs > 0 ? currentIndex ~/ 2 : currentIndex;
          _onNoteStarted!(indexForCallback);
      }
    });

    await player!.play();

  } catch (e) {
    print("Erro ao reproduzir a melodia: $e");
  }
}

Future<void> stopAudio() async {
  try {
    await player?.stop(); 
    await player?.seek(Duration.zero); 
  } catch (e) {
    print("Erro ao parar o áudio: $e");
  }
}

Future<void> disposeAudio() async {
  try {
    await player?.dispose();
    await _sequenceStateSubscription?.cancel(); 
    await _processingStateSubscription?.cancel();
    player = null;
  } catch (e) {
    print("Erro ao liberar o player: $e");
  }

  
}
