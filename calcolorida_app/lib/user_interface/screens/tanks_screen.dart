import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voltar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Agradecimentos!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blueAccent,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Nathalie Sinclair",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                         textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Lulu Healy",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                         textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Guilherme Magalhães",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                         textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Luis Fernando Pacheco Pereira",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                         textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Solange Hassan Ahmad Ali Fernandes",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true, 
                        // overflow: TextOverflow
                        //     .fade, // Faz o texto desaparecer suavemente em vez de quebrar.
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Suanne Almeida Barbosa",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                         textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
