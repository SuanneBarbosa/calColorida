import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:calcolorida_app/constants/constants.dart';


AudioPlayer? mainPlayer;       
AudioPlayer? challengePlayer;  


Map<int, UriAudioSource> digitToAudioSourceMain = {};

Map<int, UriAudioSource> digitToAudioSourceChallenge = {};


Function(int noteIndex)? _onMainNoteStarted;
Function(int noteIndex)? _onMainNoteFinished;
int _totalMainNotes = 0;


Function(int noteIndex)? _onChallengeNoteStarted;
Function(int noteIndex)? _onChallengeNoteFinished;
int _totalChallengeNotes = 0;


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


StreamSubscription<SequenceState?>? _mainSequenceStateSubscription;
StreamSubscription<ProcessingState>? _mainProcessingStateSubscription;


StreamSubscription<SequenceState?>? _challengeSequenceStateSubscription;
StreamSubscription<ProcessingState>? _challengeProcessingStateSubscription;


Future<void> initializeMainAudio() async {
  if (mainPlayer == null) {
    mainPlayer = AudioPlayer();

    
    _mainSequenceStateSubscription =
        mainPlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onMainNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
       
        _onMainNoteStarted!(currentIndex);
      }
    });

    _mainProcessingStateSubscription =
        mainPlayer!.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        if (_onMainNoteFinished != null) {
          _onMainNoteFinished!(_totalMainNotes - 1);
        }
      }
    });
  }

  
  digitToAudioSourceMain.clear();

  
  final fileNamePrefix =
      instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';

  try {
    for (int digit = 0; digit <= 9; digit++) {
      final note = digitToNote[digit]!; 
      final audioPath =
          'assets/sounds/$selectedInstrument/${note}_$fileNamePrefix.mp3';

      final source = AudioSource.asset(audioPath);
      digitToAudioSourceMain[digit] = source;
    }
  } catch (e) {
    print("Erro ao inicializar fontes de áudio MAIN: $e");
  }
}


Future<void> initializeChallengeAudio() async {
  if (challengePlayer == null) {
    challengePlayer = AudioPlayer();

    
    _challengeSequenceStateSubscription =
        challengePlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onChallengeNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
        _onChallengeNoteStarted!(currentIndex);
      }
    });

    _challengeProcessingStateSubscription =
        challengePlayer!.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        if (_onChallengeNoteFinished != null) {
          _onChallengeNoteFinished!(_totalChallengeNotes - 1);
        }
      }
    });
  }

  digitToAudioSourceChallenge.clear();

  final fileNamePrefix =
      instrumentFileNameMap[selectedInstrument] ?? 'Piano_Acustico';

  try {
    for (int digit = 0; digit <= 9; digit++) {
      final note = digitToNote[digit]!;
      final audioPath =
          'assets/sounds/$selectedInstrument/${note}_$fileNamePrefix.mp3';

      final source = AudioSource.asset(audioPath);
      digitToAudioSourceChallenge[digit] = source;
    }
  } catch (e) {
    print("Erro ao inicializar fontes de áudio CHALLENGE: $e");
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

    _onMainNoteStarted = onNoteStarted;
    _onMainNoteFinished = onNoteFinished;
    _totalMainNotes = digits.length;

    List<AudioSource> sequence = [];
    final silenceAudioPath = 'assets/sounds/silence.mp3';
    final silenceAudio = AudioSource.asset(silenceAudioPath);

    for (int i = 0; i < digits.length; i++) {
      final digit = digits[i];

      if (digitToAudioSourceMain.containsKey(digit)) {
        final originalSource = digitToAudioSourceMain[digit]!;
        final clippedSource = ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i,
        );
        sequence.add(clippedSource);
      }
      if (delayMs > 0) {
        final clippedSilence = ClippingAudioSource(
          child: silenceAudio,
          start: Duration.zero,
          end: Duration(milliseconds: delayMs),
          tag: -1,
        );
        sequence.add(clippedSilence);
      }
    }

    final playlist = ConcatenatingAudioSource(children: sequence);

    
    await mainPlayer!.setAudioSource(playlist);

    
    _mainSequenceStateSubscription =
        mainPlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onMainNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
        final indexForCallback = delayMs > 0 ? currentIndex ~/ 2 : currentIndex;
        _onMainNoteStarted!(indexForCallback);
      }
    });

    
    await mainPlayer!.play();

    
    mainPlayer!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onPlaybackCompleted?.call();
      }
    });
  } catch (e) {
    print("Erro ao reproduzir a melodia MAIN: $e");
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

    _onChallengeNoteStarted = onNoteStarted;
    _onChallengeNoteFinished = onNoteFinished;
    _totalChallengeNotes = digits.length;

    List<AudioSource> sequence = [];
    final silenceAudioPath = 'assets/sounds/silence.mp3';
    final silenceAudio = AudioSource.asset(silenceAudioPath);

    for (int i = 0; i < digits.length; i++) {
      final digit = digits[i];

      if (digitToAudioSourceChallenge.containsKey(digit)) {
        final originalSource = digitToAudioSourceChallenge[digit]!;
        final clippedSource = ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
          tag: i,
        );
        sequence.add(clippedSource);
      }
      if (delayMs > 0) {
        final clippedSilence = ClippingAudioSource(
          child: silenceAudio,
          start: Duration.zero,
          end: Duration(milliseconds: delayMs),
          tag: -1,
        );
        sequence.add(clippedSilence);
      }
    }

    final playlist = ConcatenatingAudioSource(children: sequence);

    await challengePlayer!.setAudioSource(playlist);

    _challengeSequenceStateSubscription =
        challengePlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && _onChallengeNoteStarted != null) {
        final currentIndex = sequenceState.currentIndex;
        final indexForCallback = delayMs > 0 ? currentIndex ~/ 2 : currentIndex;
        _onChallengeNoteStarted!(indexForCallback);
      }
    });

    await challengePlayer!.play();

   
    challengePlayer!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onPlaybackCompleted?.call();
      }
    });
  } catch (e) {
    print("Erro ao reproduzir a melodia CHALLENGE: $e");
  }
}


Future<void> stopMainAudio() async {
  try {
    await mainPlayer?.stop();
    await mainPlayer?.seek(Duration.zero);
  } catch (e) {
    print("Erro ao parar o áudio MAIN: $e");
  }
  // if (mainPlayer != null) {
  //   await mainPlayer!.stop();
  //   await mainPlayer!.seek(Duration.zero);
  // }
}

Future<void> stopChallengeAudio() async {
  try {
    await challengePlayer?.stop();
    await challengePlayer?.seek(Duration.zero);
  } catch (e) {
    print("Erro ao parar o áudio CHALLENGE: $e");
  }
}


Future<void> disposeAllAudio() async {
  try {
    // MAIN
    await mainPlayer?.dispose();
    await _mainSequenceStateSubscription?.cancel();
    await _mainProcessingStateSubscription?.cancel();
    mainPlayer = null;

    // DESAFIO
    await challengePlayer?.dispose();
    await _challengeSequenceStateSubscription?.cancel();
    await _challengeProcessingStateSubscription?.cancel();
    challengePlayer = null;
  } catch (e) {
    print("Erro ao liberar os players: $e");
  }
}
