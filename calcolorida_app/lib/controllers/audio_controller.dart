import 'package:just_audio/just_audio.dart'; 
import 'package:calcolorida_app/constants/constants.dart';

// final AudioPlayer player = AudioPlayer(); // Player global para ser reutilizado
AudioPlayer? player; // Player global para ser reutilizado


// Future<void> playAllNotes() {
//   // criar uma instancia para cada nota previamente
  
// }

Future<void> playNoteForNumber(int number) async {
  String note = digitToNote[number]!;  // Use o map digitToNote
  String audioPathMp3 = 'assets/sounds/${note}_Piano_Acustico.mp3';

  try {
    AudioPlayer playerInstance = AudioPlayer();
    player = playerInstance;
    await player?.setAsset(audioPathMp3);
    await player?.setVolume(1.0); // Define o volume máximo
    await player?.play();

    // Aguardar até que a reprodução seja concluída
    await player?.playerStateStream.firstWhere(
      (state) => state.processingState == ProcessingState.completed,
    );

    // Parar e redefinir o player para a próxima nota
    await player?.stop();
    playerInstance.dispose();
  } catch (e) {
    print("Erro ao tocar nota .mp3: $e");
  } 
}

Future<void> stopAudio() async {
  try {
    await player?.stop(); // Parar o áudio se estiver tocando 
    await player?.seek(Duration.zero); // Redefine a posição do player
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
