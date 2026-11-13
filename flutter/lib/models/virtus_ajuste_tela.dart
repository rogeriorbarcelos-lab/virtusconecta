// VirtusConecta: ajuste automatico da resolucao da outra maquina.
// Quando a tela remota ficaria bem menor que o tamanho real na tela local
// (ex.: notebook 15" acessando um monitor 29" ultrawide), troca a resolucao
// da outra maquina so durante a conexao. O servidor volta a resolucao
// original sozinho quando a ultima conexao termina (restore_resolutions).
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/model.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:window_size/window_size.dart' as window_size;

const kOpcaoAjusteResolucao = 'virtus-ajuste-resolucao';

// Abaixo desta escala (imagem 20% menor que o real) a resolucao e ajustada.
const _kEscalaMinima = 0.8;
const _kLarguraMinima = 1024;
const _kAlturaMinima = 600;

bool ajusteResolucaoLigado() =>
    mainGetLocalBoolOptionSync(kOpcaoAjusteResolucao);

/// Escolhe a resolucao da outra maquina que cabe inteira na tela local.
/// Devolve null quando nao ha nada a ajustar.
Resolution? escolherResolucaoRemota(Resolution local, Resolution remota,
    List<Resolution> suportadas, bool telaVirtual) {
  if (local.width <= 0 || local.height <= 0) return null;
  if (remota.width <= 0 || remota.height <= 0) return null;
  final escala =
      math.min(local.width / remota.width, local.height / remota.height);
  if (escala >= _kEscalaMinima) return null;
  if (telaVirtual) return Resolution(local.width, local.height);

  final aspectoLocal = local.width / local.height;
  double distancia(Resolution r) => (r.width / r.height - aspectoLocal).abs();
  Resolution? melhor;
  for (final r in suportadas) {
    if (r.width > local.width || r.height > local.height) continue;
    if (r.width < _kLarguraMinima || r.height < _kAlturaMinima) continue;
    if (melhor == null) {
      melhor = r;
      continue;
    }
    final area = r.width * r.height;
    final areaMelhor = melhor.width * melhor.height;
    if (area > areaMelhor ||
        (area == areaMelhor && distancia(r) < distancia(melhor))) {
      melhor = r;
    }
  }
  if (melhor == null ||
      (melhor.width == remota.width && melhor.height == remota.height)) {
    return null;
  }
  return melhor;
}

Future<Resolution?> _resolucaoLocal() async {
  try {
    final tela = (await window_size.getWindowInfo()).screen;
    if (tela != null && tela.frame.width > 0 && tela.frame.height > 0) {
      return Resolution(tela.frame.width.round(), tela.frame.height.round());
    }
  } catch (_) {}
  try {
    final d = json.decode(bind.mainGetMainDisplay());
    if (d['w'] != null && d['h'] != null) {
      return Resolution(d['w'], d['h']);
    }
  } catch (_) {}
  return null;
}

/// Chamado quando a conexao recebe as telas da outra maquina.
Future<void> virtusAjustarResolucao(FFI ffi) async {
  if (!isDesktop || !ajusteResolucaoLigado()) return;
  // Espera as permissoes e a janela se acomodarem.
  await Future.delayed(const Duration(seconds: 2));
  final modelo = ffi.ffiModel;
  final pi = modelo.pi;
  if (!modelo.keyboard || modelo.viewOnly) return;
  final d = pi.tryGetDisplayIfNotAllDisplay();
  if (d == null) return;
  final telaVirtual = modelo.isVirtualDisplayResolution;
  if (pi.resolutions.isEmpty && !telaVirtual) return;
  final local = await _resolucaoLocal();
  if (local == null) return;
  final remota =
      Resolution((d.width / d.scale).round(), (d.height / d.scale).round());
  final alvo =
      escolherResolucaoRemota(local, remota, pi.resolutions, telaVirtual);
  if (alvo == null) return;
  debugPrint('VirtusConecta: ajuste de resolucao $remota -> $alvo (local $local)');
  await bind.sessionChangeResolution(
    sessionId: ffi.sessionId,
    display: pi.currentDisplay,
    width: alvo.width,
    height: alvo.height,
  );
  showToast(
      'Tela da outra máquina ajustada para ${alvo.width}x${alvo.height} durante a conexão');
}
