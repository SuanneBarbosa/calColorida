import 'package:flutter/material.dart';

class UsageInstructionsScreen extends StatelessWidget {
  const UsageInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções de Uso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInstructionItem(
              context,
              title: '1. Realizar Cálculos',
              description:
                  'Digite números e operações no teclado da calculadora para realizar cálculos. O resultado será exibido no display superior.',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '2. Gerar Mosaicos',
              description:
                  'Os resultados dos cálculos que gerem números decimais são convertidos em mosaicos coloridos representando os números após a vírgula na parte decimal.',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '3. Salvar Mosaicos',
              description:
                  "Clique no botão 'S' no teclado da calculadora para salvar o mosaico gerado. Ele será armazenado na seção 'Mosaicos Salvos', onde você poderá gerenciar seus mosaicos. Para excluir, clique no ícone de lixeira. Para carregar o mosaico salvo na tela principal, basta clicar na opção 'Aplicar'.",
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '4. Tocar Notas Musicais',
              description:
                  'Clique no botão de "Play" para reproduzir os sons das notas musicais correspondentes ao mosaico gerado, e escolha um instrumento diferente no menu.',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '5. Ajustar Configurações',
              description:
                  'No menu lateral, você pode ajustar diferentes configurações para personalizar a experiência:\n'
                  '- Instrumento musical: Use o menu suspenso com o ícone de nota musical para selecionar o instrumento que tocará as notas musicais correspondentes ao mosaico (por exemplo, piano, violino, guitarra, etc.).\n'
                  '- Zoom do mosaico: Use o slider "Zoom do Mosaico" para alterar o tamanho dos quadrados no mosaico, aumentando ou diminuindo o nível de detalhe exibido.\n'
                  '- Velocidade de reprodução: Ajuste o slider com o ícone de velocidade para controlar a duração de cada nota musical reproduzida, tornando-a mais lenta ou mais rápida.\n'
                  '- Ignorar Zeros: Ative essa opção para evitar que os zeros sejam reproduzidos e destacados quando o botão play for acionado.\n'
                  '- Ler Resultado: Ative essa opção para que o resultado exibido na tela seja lido automaticamente após a realização de uma operação.\n'
                  '- Tempo entre notas: Ajuste o slider com o ícone de ampulheta para aumentar ou diminuir a diferença de tempo entre as notas que estão tocando.\n',
                 semanticsDescription:'',
            
            ),
            _buildInstructionItem(
              context,
              title: '6. Explorar Desafios',
              description:
                  'Na seção de desafios, você encontrará 3 tipos de desafios projetados para interagir com mosaico e os sons musicais:\n'
                  '- Desafio Mosaico (Apenas Mosaico): Realize uma operação a partir do mosaico fornecido na tela. O objetivo é observar como os números decimais geram padrões visuais no mosaico. Não há sons neste modo, apenas a exibição visual.\n'
                  '- Desafio Som (Apenas Áudio): Este desafio foca na reprodução das notas musicais correspondentes aos números do mosaico. A experiência é auditiva, permitindo que você explore os sons associados aos dígitos gerados.\n'
                  '- Desafio Som e Mosaico: Combine o visual e o auditivo. Este modo exibe o mosaico e reproduz as notas musicais simultaneamente, unindo padrões visuais e sonoros.\n',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '7. Apagar um Dígito',
              description:
                  'Use o botão "<-" no teclado da calculadora para apagar o último dígito inserido.',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '8. Limpar Tela',
              description:
                  'Clique no botão "C" para apagar todos os números e operações no cálculo atual.',
            semanticsDescription:'',
            
            ),
            _buildInstructionItem(
              context,
              title: '9. Usar Operações Avançadas',
              description:
                  'Use os seguintes botões para realizar operações avançadas:\n'
                  '- "π": Insere o valor de pi.\n'
                  '- "√": Calcula a raiz quadrada do número exibido.\n'
                  '- "^": Eleva o número atual à potência inserida.\n'
                  '- "1/x": Calcula o inverso do número exibido.\n'
                  '- "!": Calcula o fatorial do número inserido.',
           semanticsDescription:'',
           
            ),
            _buildInstructionItem(
              context,
              title: '10. Teclas de Operação',
              description:
                  'Use os botões "+", "-", "x" e "/" para adicionar, subtrair, multiplicar e dividir, respectivamente.',
            semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '11. Exibir o Resultado',
              description:
                  'Clique no botão "=" para calcular e exibir o resultado da expressão inserida.',
                  semanticsDescription:'',
            ),
            _buildInstructionItem(
              context,
              title: '12. Adicionar Casas Decimais',
              description:
                  'Use o botão "." para adicionar casas decimais ao número atual.',
                  semanticsDescription:'',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(BuildContext context,
      {required String title, required String description, required String semanticsDescription}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        
       Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
         Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const Divider(
          thickness: 1,
          height: 20,
        ),
      ],
    );
  }
}
