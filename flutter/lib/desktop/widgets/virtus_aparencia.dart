// VirtusConecta: aparencia do programa.
//  - paletas do tema "Personalizado" (cor de destaque e cor de fundo);
//  - biblioteca de fundos da tela inicial (desenhos proprios, no estilo dos
//    papeis de parede do WhatsApp: cor de fundo com desenhos discretos).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:get/get.dart';

const kOpcaoCorDestaque = 'virtus-cor-destaque';
const kOpcaoCorFundo = 'virtus-cor-fundo';
const kOpcaoFundoTela = 'virtus-fundo';

class VirtusCor {
  final String nome;
  final Color cor;
  const VirtusCor(this.nome, this.cor);
}

const coresDestaque = <VirtusCor>[
  VirtusCor('Dourado Virtus', Color(0xFFC9A227)),
  VirtusCor('Âmbar', Color(0xFFFFB300)),
  VirtusCor('Laranja', Color(0xFFFB8C00)),
  VirtusCor('Vermelho', Color(0xFFE53935)),
  VirtusCor('Rosa', Color(0xFFD81B60)),
  VirtusCor('Roxo', Color(0xFF8E24AA)),
  VirtusCor('Anil', Color(0xFF3949AB)),
  VirtusCor('Azul', Color(0xFF1E88E5)),
  VirtusCor('Turquesa', Color(0xFF00ACC1)),
  VirtusCor('Verde-água', Color(0xFF00897B)),
  VirtusCor('Verde', Color(0xFF43A047)),
  VirtusCor('Grafite', Color(0xFF607D8B)),
];

const coresFundo = <VirtusCor>[
  VirtusCor('Preto', Color(0xFF0E0E0E)),
  VirtusCor('Grafite', Color(0xFF1E1F24)),
  VirtusCor('Azul-noite', Color(0xFF0F1A2B)),
  VirtusCor('Verde-noite', Color(0xFF0F2019)),
  VirtusCor('Vinho', Color(0xFF2A1218)),
  VirtusCor('Branco', Color(0xFFFFFFFF)),
  VirtusCor('Cinza-claro', Color(0xFFF2F2F5)),
  VirtusCor('Creme', Color(0xFFFBF7EE)),
  VirtusCor('Azul-claro', Color(0xFFEEF4FB)),
  VirtusCor('Verde-claro', Color(0xFFEFF7F1)),
];

String corParaTexto(Color c) =>
    (c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

Color corDaOpcao(String chave, Color padrao) {
  final v = bind.mainGetLocalOption(key: chave).trim();
  final n = int.tryParse(v, radix: 16);
  if (v.length != 6 || n == null) return padrao;
  return Color(0xFF000000 | n);
}

bool corEscura(Color c) => c.computeLuminance() < 0.4;

/// Paletas do tema "Personalizado" (aparecem em Configuracoes > Geral > Tema).
class VirtusPaletaCores extends StatefulWidget {
  final VoidCallback? aoMudar;
  const VirtusPaletaCores({Key? key, this.aoMudar}) : super(key: key);

  @override
  State<VirtusPaletaCores> createState() => _VirtusPaletaCoresState();
}

class _VirtusPaletaCoresState extends State<VirtusPaletaCores> {
  Future<void> _escolher(String chave, Color cor) async {
    await bind.mainSetLocalOption(key: chave, value: corParaTexto(cor));
    await MyTheme.aplicarTemaPersonalizado();
    await reloadAllWindows();
    if (mounted) setState(() {});
    widget.aoMudar?.call();
  }

  Widget _linha(String titulo, String chave, List<VirtusCor> cores,
      Color padrao) {
    final atual = corDaOpcao(chave, padrao).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14))
            .marginOnly(bottom: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cores.map((c) {
            final selecionada = c.cor.value == atual;
            return Tooltip(
              message: c.nome,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _escolher(chave, c.cor),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.cor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selecionada
                          ? MyTheme.accent
                          : Colors.grey.withOpacity(0.5),
                      width: selecionada ? 3 : 1,
                    ),
                  ),
                  child: selecionada
                      ? Icon(Icons.check,
                          size: 16,
                          color: corEscura(c.cor) ? Colors.white : Colors.black)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linha('Cor de destaque', kOpcaoCorDestaque, coresDestaque,
            MyTheme.virtusDourado),
        const SizedBox(height: 14),
        _linha('Cor de fundo', kOpcaoCorFundo, coresFundo,
            MyTheme.virtusFundoPadrao),
      ],
    ).marginOnly(left: 40, top: 6, bottom: 6);
  }
}

// ------------------------------------------------------------------ fundos

class VirtusFundo {
  final String id;
  final String nome;
  const VirtusFundo(this.id, this.nome);
}

const fundosTela = <VirtusFundo>[
  VirtusFundo('', 'Nenhum'),
  VirtusFundo('escritorio', 'Escritório'),
  VirtusFundo('pontos', 'Pontos'),
  VirtusFundo('diagonais', 'Diagonais'),
  VirtusFundo('grade', 'Grade'),
  VirtusFundo('ondas', 'Ondas'),
  VirtusFundo('hexagonos', 'Colmeia'),
  VirtusFundo('circulos', 'Círculos'),
  VirtusFundo('losangos', 'Losangos'),
  VirtusFundo('cruzes', 'Cruzes'),
  VirtusFundo('confete', 'Confete'),
  VirtusFundo('degrade', 'Degradê'),
  VirtusFundo('aurora', 'Aurora'),
];

final RxString fundoTelaAtual = RxString(_lerFundo());

String _lerFundo() {
  try {
    return bind.mainGetLocalOption(key: kOpcaoFundoTela);
  } catch (_) {
    return '';
  }
}

/// Coloca o fundo escolhido atras de [child] (area direita da tela inicial).
class VirtusFundoTela extends StatelessWidget {
  final Widget child;
  const VirtusFundoTela({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final id = fundoTelaAtual.value;
      if (id.isEmpty) return child;
      return CustomPaint(
        painter: _PintorFundo(id, Theme.of(context).scaffoldBackgroundColor,
            MyTheme.accent, Theme.of(context).brightness == Brightness.dark),
        child: child,
      );
    });
  }
}

/// Biblioteca de fundos (Configuracoes > Geral > Fundo da tela inicial).
class VirtusEscolhaFundo extends StatelessWidget {
  const VirtusEscolhaFundo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fundoBase = Theme.of(context).scaffoldBackgroundColor;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final atual = fundoTelaAtual.value;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: fundosTela.map((f) {
          final selecionado = f.id == atual;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await bind.mainSetLocalOption(key: kOpcaoFundoTela, value: f.id);
              fundoTelaAtual.value = f.id;
            },
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: fundoBase,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selecionado
                          ? MyTheme.accent
                          : Colors.grey.withOpacity(0.4),
                      width: selecionado ? 3 : 1,
                    ),
                  ),
                  child: f.id.isEmpty
                      ? Icon(Icons.block, color: Colors.grey.withOpacity(0.6))
                      : CustomPaint(
                          painter: _PintorFundo(
                              f.id, fundoBase, MyTheme.accent, escuro,
                              escala: 0.5)),
                ),
                const SizedBox(height: 4),
                Text(f.nome, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ).marginOnly(left: 20, top: 4, bottom: 6);
    });
  }
}

class _PintorFundo extends CustomPainter {
  final String id;
  final Color fundo;
  final Color destaque;
  final bool escuro;
  final double escala;

  _PintorFundo(this.id, this.fundo, this.destaque, this.escuro,
      {this.escala = 1.0});

  static const _icones = <IconData>[
    Icons.computer,
    Icons.calculate_outlined,
    Icons.description_outlined,
    Icons.folder_outlined,
    Icons.mail_outline,
    Icons.attach_money,
    Icons.lock_outline,
    Icons.cloud_outlined,
    Icons.wifi,
    Icons.schedule,
    Icons.bar_chart,
    Icons.coffee_outlined,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final traco = Paint()
      ..color = destaque.withOpacity(escuro ? 0.13 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * escala;
    final cheio = Paint()
      ..color = destaque.withOpacity(escuro ? 0.12 : 0.16)
      ..style = PaintingStyle.fill;
    final p = 36.0 * escala;

    switch (id) {
      case 'escritorio':
        final passo = 70.0 * escala;
        var i = 0;
        for (double y = 0; y < size.height + passo; y += passo) {
          final desloca = ((y / passo).round().isOdd) ? passo / 2 : 0.0;
          for (double x = -passo; x < size.width + passo; x += passo) {
            final icone = _icones[i++ % _icones.length];
            final tp = TextPainter(
              text: TextSpan(
                text: String.fromCharCode(icone.codePoint),
                style: TextStyle(
                  fontSize: 26 * escala,
                  fontFamily: icone.fontFamily,
                  package: icone.fontPackage,
                  color: destaque.withOpacity(escuro ? 0.14 : 0.2),
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            canvas.save();
            canvas.translate(x + desloca, y);
            canvas.rotate(((i % 5) - 2) * 0.15);
            tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
            canvas.restore();
          }
        }
        break;
      case 'pontos':
        for (double y = p / 2; y < size.height; y += p) {
          for (double x = p / 2; x < size.width; x += p) {
            canvas.drawCircle(Offset(x, y), 2.2 * escala, cheio);
          }
        }
        break;
      case 'diagonais':
        for (double x = -size.height; x < size.width; x += p / 1.5) {
          canvas.drawLine(
              Offset(x, size.height), Offset(x + size.height, 0), traco);
        }
        break;
      case 'grade':
        for (double x = 0; x < size.width; x += p) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), traco);
        }
        for (double y = 0; y < size.height; y += p) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), traco);
        }
        break;
      case 'ondas':
        for (double y = 0; y < size.height + p; y += p / 1.4) {
          final caminho = Path()..moveTo(0, y);
          for (double x = 0; x <= size.width; x += 4) {
            caminho.lineTo(x, y + math.sin(x / (22 * escala)) * 7 * escala);
          }
          canvas.drawPath(caminho, traco);
        }
        break;
      case 'hexagonos':
        final r = 20.0 * escala;
        final w = math.sqrt(3) * r;
        var linha = 0;
        for (double y = 0; y < size.height + r * 2; y += r * 1.5) {
          final desloca = (linha++).isOdd ? w / 2 : 0.0;
          for (double x = 0; x < size.width + w; x += w) {
            final c = Offset(x + desloca, y);
            final caminho = Path();
            for (var k = 0; k < 6; k++) {
              final a = math.pi / 6 + k * math.pi / 3;
              final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
              k == 0 ? caminho.moveTo(pt.dx, pt.dy) : caminho.lineTo(pt.dx, pt.dy);
            }
            caminho.close();
            canvas.drawPath(caminho, traco);
          }
        }
        break;
      case 'circulos':
        final passo = 64.0 * escala;
        for (double y = 0; y < size.height + passo; y += passo) {
          for (double x = 0; x < size.width + passo; x += passo) {
            canvas.drawCircle(Offset(x, y), passo * 0.42, traco);
            canvas.drawCircle(Offset(x, y), passo * 0.2, traco);
          }
        }
        break;
      case 'losangos':
        final passo = 40.0 * escala;
        for (double y = 0; y < size.height + passo; y += passo) {
          for (double x = 0; x < size.width + passo; x += passo) {
            final caminho = Path()
              ..moveTo(x, y - passo / 3)
              ..lineTo(x + passo / 3, y)
              ..lineTo(x, y + passo / 3)
              ..lineTo(x - passo / 3, y)
              ..close();
            canvas.drawPath(caminho, traco);
          }
        }
        break;
      case 'cruzes':
        final t = 5.0 * escala;
        for (double y = p / 2; y < size.height; y += p) {
          for (double x = p / 2; x < size.width; x += p) {
            canvas.drawLine(Offset(x - t, y), Offset(x + t, y), traco);
            canvas.drawLine(Offset(x, y - t), Offset(x, y + t), traco);
          }
        }
        break;
      case 'confete':
        final aleatorio = math.Random(7);
        final quantos = (size.width * size.height / (900 * escala * escala))
            .clamp(10, 1500)
            .toInt();
        for (var k = 0; k < quantos; k++) {
          final c = Offset(aleatorio.nextDouble() * size.width,
              aleatorio.nextDouble() * size.height);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(aleatorio.nextDouble() * math.pi);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                      center: Offset.zero,
                      width: 8 * escala,
                      height: 3 * escala),
                  Radius.circular(1.5 * escala)),
              cheio);
          canvas.restore();
        }
        break;
      case 'degrade':
        canvas.drawRect(
            rect,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  fundo,
                  Color.lerp(fundo, destaque, escuro ? 0.22 : 0.18)!,
                ],
              ).createShader(rect));
        break;
      case 'aurora':
        canvas.drawRect(
            rect,
            Paint()
              ..shader = RadialGradient(
                center: const Alignment(0.8, -0.9),
                radius: 1.3,
                colors: [
                  Color.lerp(fundo, destaque, 0.28)!,
                  Color.lerp(fundo, const Color(0xFF3949AB), 0.12)!,
                  fundo,
                ],
                stops: const [0.0, 0.45, 1.0],
              ).createShader(rect));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFundo old) =>
      old.id != id ||
      old.fundo != fundo ||
      old.destaque != destaque ||
      old.escuro != escuro ||
      old.escala != escala;
}
