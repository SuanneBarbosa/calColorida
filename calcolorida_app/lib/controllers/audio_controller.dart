
import 'dart:async';
import 'package:just_audio/just_audio.dart' as just;
import 'package:audioplayers/audioplayers.dart'; 
import 'package:calcolorida_app/constants/constants.dart';

String selectedInstrument = 'piano'; 
just.AudioPlayer? mainPlayer;
just.AudioPlayer? challengePlayer;
Map<int, just.UriAudioSource> digitToAudioSourceMain = {};
Map<int, just.UriAudioSource> digitToAudioSourceChallenge = {};

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



AudioPlayer? _keypadSfxPlayer; 

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



Future<void> initializeKeypadAudio() async {
  _keypadSfxPlayer ??= AudioPlayer();
  _keypadSfxPlayer!.setReleaseMode(ReleaseMode.stop);
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
  final soundPath = 'sounds/$selectedInstrument/${noteName}_$fileNamePrefix.mp3';

  try {
      if (_keypadSfxPlayer!.releaseMode != ReleaseMode.stop) {
        _keypadSfxPlayer!.setReleaseMode(ReleaseMode.stop);
    }

    await _keypadSfxPlayer!.play(AssetSource(soundPath));
  } catch (e) {
    print("Erro ao tocar som do keypad ($digit - $soundPath) com audioplayers: $e");
  }
}

Future<void> updateSelectedInstrumentForAudio(String newInstrument) async {
  selectedInstrument = newInstrument;
  print("Instrumento de áudio atualizado para: $newInstrument");
}

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
    if (mainPlayer == null) { 
        print("playMainMelodyAudio: mainPlayer ainda é nulo.");
        return;
    }


    _onMainNoteStarted = onNoteStarted;
    _onMainNoteFinished = onNoteFinished;
    _totalMainNotes = digits.length;

    List<just.AudioSource> sequence = [];
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
      print("playMainMelodyAudio: Nenhuma nota para tocar.");
      onPlaybackCompleted?.call();
      return;
    }

    final playlist = just.ConcatenatingAudioSource(children: sequence);
    await mainPlayer!.setAudioSource(playlist); 
    _mainProcessingStateSubscription?.cancel();
    _mainProcessingStateSubscription = mainPlayer!.processingStateStream.listen((state) {
      if (state == just.ProcessingState.completed) {
        onPlaybackCompleted?.call();
        _mainProcessingStateSubscription?.cancel(); 
      }
    });

    await mainPlayer!.play();
  } catch (e) {
    print("Erro ao reproduzir a melodia MAIN (just_audio): $e");
    onPlaybackCompleted?.call(); 
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
    if (challengePlayer == null) {
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
    await mainPlayer?.seek(Duration.zero);
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

Future<void> disposeAllAudio() async {
  print("Dispondo todos os players de áudio...");
  try {
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
    await _keypadSfxPlayer?.dispose();
    _keypadSfxPlayer = null;
    print("Keypad SFX Player (audioplayers) disposed.");

  } catch (e) {
    print("Erro ao liberar todos os players de áudio: $e");
  }
}