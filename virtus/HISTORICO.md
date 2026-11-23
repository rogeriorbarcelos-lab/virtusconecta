# VirtusConecta — histórico do desenvolvimento

Registro do que foi feito até 23/11/2026. O VirtusConecta é o acesso remoto da
Virtus, baseado no RustDesk, com servidor próprio.

## Onde fica cada parte

| Parte | Onde |
|---|---|
| Programa (Windows) | Este repositório, ramo **`virtusconecta`** (versão normal) e ramo **`testes`** (versão de teste, número com "-teste") |
| Instalador | GitHub Actions, workflow `VirtusConecta - Windows` (`.github/workflows/virtusconecta-windows.yml`), gerado a cada envio ao ramo |
| Código do servidor (API, compose, Caddy) | Notebook: `C:\Users\Rogério\Downloads\Projetos Automação\VirtusConecta\servidor` (não está neste repositório) |
| Servidor | AWS Lightsail `virtus-servidor` (54.232.98.43), acesso `ssh virtus-lightsail`, pasta `/opt/virtusconecta` |
| Endereço da API | `https://conecta.virtusassessoria.com.br` (porta 443, via nginx do aaPanel) e porta 21114 (Caddy) |

## Programa — mudanças por data

### 11/11/2026
- Marca VirtusConecta, servidor próprio da Virtus e compilação do Windows (`95f465f`).

### 12/11/2026
- Tira o aviso de servidor público do rodapé; cartão de aviso nas cores da marca (`b39f767`).
- Tela remota ajustada à janela e melhor qualidade de imagem como padrão (`42e87b4`).
- API sempre em HTTPS quando o servidor é o da Virtus (`e82e559`).

### 13/11/2026
- Senha fixa automática: máquina sem senha fixa gera uma (20 caracteres), envia ao servidor da Virtus e só depois passa a usá-la (`5bc79f6`).
- Tema escuro passa a ser só o padrão; o usuário pode trocar (`e1446b9`).
- Temas Padrão Virtus / Claro / Personalizado, fundos da tela inicial e conexão com a conta logada (`9cfa250`, `d85e355`).
- Correção de compilação (`0df59f1`). Compilação 9 da versão normal: sucesso.
- Feitas no ramo `testes` (compilação 13: sucesso):
  - ajuste automático da resolução da outra máquina;
  - número da versão na tela inicial e no nome do instalador;
  - captura de tela e copiar/colar nos dois sentidos;
  - tela inicial liberada para quem está conectado de fora (as Configurações continuam travadas durante conexões recebidas).

### 16/11/2026
- As quatro correções acima, que estavam só no ramo `testes`, foram levadas para a versão normal (`8390125`, `ae50622`, `476046c`, `2726955`). O código do ramo `virtusconecta` ficou idêntico ao do `testes`.
- Motivo: o PC do escritório (ID 206524240) estava com a versão normal e a tela do VirtusConecta ficava bloqueada quando alguém se conectava.
- **Compilação 15: sucesso. Instalador `VirtusConecta-1.15.exe`** (artefato `VirtusConecta-1.15` na execução 43983342928 do GitHub Actions).

## Servidor

### Fase 1 (até 11/11)
- `hbbs` e `hbbr` (servidor de ID e de retransmissão) em contêineres em `/opt/virtusconecta`.

### Fase 3 — API (12/11)
- API instalada (`virtusconecta-api`, ouvindo em `127.0.0.1:21180`, dados em `/opt/virtusconecta/api-dados`). Compose anterior guardado como `docker-compose.yml.fase1`.
- Chave que cifra as senhas das máquinas gerada no próprio servidor e gravada no `.env`.
- Porta 21114 liberada no firewall (ufw).
- Contêiner HTTPS (Caddy, `virtusconecta-https`) obtém o certificado pela Cloudflare (DNS) e serve a API na porta 21114.
- nginx do aaPanel (`/www/server/panel/vhost/nginx/virtusconecta.conf`) serve `/api/` na porta 443 para `conecta.virtusassessoria.com.br`, usando o certificado do Caddy; o resto responde 404. O site do VirtusAutomacaoWeb continua sendo o padrão da 443.
- Usuário administrador `rogerio` criado na API.

### 16/11/2026 — conferência
- `https://conecta.virtusassessoria.com.br/api/saude` responde `{"ok":true}`.
- Certificado válido até **10/02/2027**.
- O token da Cloudflare (`CF_API_TOKEN`) foi removido do `.env` durante as tentativas de regravação, e o contêiner `virtusconecta-https` ficou **parado**. Nada deixou de funcionar, porque a porta 443 usa o certificado já emitido.
- `virtusconecta-api`, `hbbs`, `hbbr` e o site do VirtusAutomacaoWeb seguiram no ar o tempo todo.

## Pendências

1. **Renovação do certificado (até ~10/01/2027):** criar na Cloudflare um token com **Zone Read + DNS Write** só na zona `virtusassessoria.com.br`, gravar como `CF_API_TOKEN` no `/opt/virtusconecta/.env` (conferir: tamanho ~40 e nenhum caractere fora de letras, números, `-` e `_`) e subir com `sudo docker compose up -d --no-deps --force-recreate https`. Há um lembrete agendado para 04/01/2027.
2. **Atualizar o PC do escritório (ID 206524240) para a 1.15** e conferir que a tela inicial mostra "1.15".
3. **Senha permanente no PC do escritório:** definir em Configurações > Segurança, com alguém no próprio PC (as Configurações ficam travadas durante conexões recebidas), e escolher "Usar ambas as senhas". Sem isso, a senha de uso único muda a cada desconexão e "lembrar a senha" não funciona.
4. **"Gerando…" no notebook:** em 12/11 a senha de uso único ficou presa em "Gerando…"; foi passado um comando para reiniciar o serviço `VirtusConecta`. Resultado não confirmado.
