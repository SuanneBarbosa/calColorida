import 'package:just_audio/just_audio.dart';
import 'package:calcolorida_app/constants/constants.dart';

AudioPlayer? player; // Instância única do AudioPlayer
Map<int, UriAudioSource> digitToAudioSource = {}; // Mapeia dígitos para UriAudioSource

/// Inicializar as fontes de áudio
Future<void> initializeAudio() async {
  try {
    for (int digit = 0; digit <= 9; digit++) {
      String note = digitToNote[digit]!; // Obter o nome da nota
      String audioPathMp3 = 'assets/sounds/${note}_Piano_Acustico.mp3';
      // Criar uma UriAudioSource para cada nota
      UriAudioSource source = AudioSource.asset(audioPathMp3) as UriAudioSource;
      digitToAudioSource[digit] = source;
    }
  } catch (e) {
    print("Erro ao inicializar fontes de áudio: $e");
  }
}

/// Reproduzir a melodia com cada nota tocando por uma duração específica
Future<void> playMelodyAudio(List<int> digits, {int durationMs = 500}) async {
  try {
    if (player == null) {
      player = AudioPlayer();
    }

    List<AudioSource> sequence = [];

    for (int digit in digits) {
      if (digitToAudioSource.containsKey(digit)) {
        UriAudioSource originalSource = digitToAudioSource[digit]!;

        // Envolver a fonte original em um ClippingAudioSource
        ClippingAudioSource clippedSource = ClippingAudioSource(
          child: originalSource,
          start: Duration.zero,
          end: Duration(milliseconds: durationMs),
        );

        sequence.add(clippedSource);
      }
    }

    // Criar uma sequência concatenada de áudio
    ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: sequence);

    await player!.setAudioSource(playlist);
    await player!.play();
  } catch (e) {
    print("Erro ao reproduzir a melodia: $e");
  }
}

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
  } catch (e) {
    print("Erro ao liberar o player: $e");
  }
}
