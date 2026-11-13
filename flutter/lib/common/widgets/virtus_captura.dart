// VirtusConecta: captura de tela nos dois sentidos, pelo menu da conexao.
// A imagem capturada vai para a area de transferencia de quem capturou e a
// sincronizacao automatica do programa leva para o outro lado; o usuario so
// precisa usar Ctrl+V onde quiser colar.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/toolbar.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/models/model.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:url_launcher/url_launcher.dart';

const _kTempoAviso = Duration(seconds: 7);

Future<void> _teclaRemota(FFI ffi, String nome,
    {bool shift = false, bool win = false}) {
  return bind.sessionInputKey(
    sessionId: ffi.sessionId,
    name: nome,
    down: true,
    press: true,
    alt: false,
    ctrl: false,
    shift: shift,
    command: win,
  );
}

List<TTextMenu> virtusMenusCaptura(FFI ffi) {
  final modelo = ffi.ffiModel;
  if (!isDesktop || ffi.connType != ConnType.defaultConn) return [];
  if (modelo.permissions['keyboard'] == false || modelo.viewOnly) return [];
  final menus = <TTextMenu>[];
  if (modelo.pi.platform == kPeerPlatformWindows) {
    menus.add(TTextMenu(
      child: const Text('Recortar parte da tela remota'),
      onPressed: () async {
        await _teclaRemota(ffi, 'VK_S', shift: true, win: true);
        showToast(
            'Selecione a área na tela remota. Depois use Ctrl+V para colar lá ou aqui.',
            timeout: _kTempoAviso);
      },
    ));
    menus.add(TTextMenu(
      child: const Text('Copiar a tela remota inteira (Print Screen)'),
      onPressed: () async {
        await _teclaRemota(ffi, 'VK_SNAPSHOT');
        showToast('Tela remota copiada. Use Ctrl+V para colar lá ou aqui.',
            timeout: _kTempoAviso);
      },
    ));
  }
  if (isWindows) {
    menus.add(TTextMenu(
      child: const Text('Recortar a minha tela e enviar para a remota'),
      onPressed: () async {
        await launchUrl(Uri.parse('ms-screenclip:'));
        showToast(
            'Selecione a área da sua tela. Depois clique na tela remota e use Ctrl+V.',
            timeout: _kTempoAviso);
      },
    ));
  }
  return menus;
}
