#!/usr/bin/env python3
"""VirtusConecta - aplica a marca na biblioteca libs/hbb_common.

libs/hbb_common e um submodulo (outro repositorio). Em vez de manter um segundo
fork, este script troca, antes da compilacao, as quatro constantes que definem
o nome do programa e o servidor embutido.

Uso (na raiz do repositorio, depois de baixar os submodulos):
    python virtus/aplicar-marca.py

Pode ser executado mais de uma vez. Se o trecho original nao for encontrado
(por exemplo, depois de atualizar a versao do RustDesk), o script para com erro
em vez de compilar um programa apontando para o servidor errado.
"""
import sys
from pathlib import Path

NOME = "VirtusConecta"
ORGANIZACAO = "br.com.virtusassessoria"
SERVIDOR = "conecta.virtusassessoria.com.br"
# Chave PUBLICA do servidor da Virtus (nao e segredo; a privada fica so no servidor).
CHAVE_PUBLICA = "kJ8GjfHvDzLvn7rDdIrrOLQ2MzHQaKlkhUBf1V60VXM="

RAIZ = Path(__file__).resolve().parent.parent
ARQUIVO = RAIZ / "libs" / "hbb_common" / "src" / "config.rs"

TROCAS = [
    (
        'pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());',
        f'pub static ref APP_NAME: RwLock<String> = RwLock::new("{NOME}".to_owned());',
    ),
    (
        'pub static ref ORG: RwLock<String> = RwLock::new("com.carriez".to_owned());',
        f'pub static ref ORG: RwLock<String> = RwLock::new("{ORGANIZACAO}".to_owned());',
    ),
    (
        'pub const RENDEZVOUS_SERVERS: &[&str] = &["rs-ny.rustdesk.com"];',
        f'pub const RENDEZVOUS_SERVERS: &[&str] = &["{SERVIDOR}"];',
    ),
    (
        'pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";',
        f'pub const RS_PUB_KEY: &str = "{CHAVE_PUBLICA}";',
    ),
]


def main() -> int:
    if not ARQUIVO.is_file():
        print(f"ERRO: nao encontrei {ARQUIVO}. Os submodulos foram baixados?")
        return 1
    texto = ARQUIVO.read_text(encoding="utf-8")
    for original, novo in TROCAS:
        if novo in texto:
            print("ja aplicado:", novo)
            continue
        if texto.count(original) != 1:
            print("ERRO: trecho original nao encontrado (ou repetido):")
            print("   ", original)
            return 1
        texto = texto.replace(original, novo)
        print("aplicado:", novo)
    ARQUIVO.write_text(texto, encoding="utf-8", newline="\n")

    # Conferencia final: nada de servidor publico do RustDesk nas constantes.
    final = ARQUIVO.read_text(encoding="utf-8")
    for proibido in ("rs-ny.rustdesk.com", "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw="):
        if proibido in final:
            print("ERRO: ainda existe referencia ao servidor publico:", proibido)
            return 1
    print("ok: marca aplicada em", ARQUIVO.relative_to(RAIZ))
    return 0


if __name__ == "__main__":
    sys.exit(main())
