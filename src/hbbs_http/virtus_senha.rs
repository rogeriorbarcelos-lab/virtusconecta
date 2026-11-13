// VirtusConecta: senha fixa automatica.
//
// Maquina sem senha fixa gera uma sozinha, envia ao servidor da Virtus (que a entrega,
// cifrada, so aos usuarios liberados pela agenda "Escritorio Virtus") e so depois passa
// a usa-la. Se o envio falhar, nada muda no PC e a tentativa se repete mais tarde.
use hbb_common::{config::Config, log};
use serde_json::json;
use std::{
    sync::Mutex,
    time::{Duration, Instant},
};

const API_VIRTUS: &str = "https://conecta.virtusassessoria.com.br";
const INTERVALO: Duration = Duration::from_secs(300);
const TAMANHO: usize = 20;

lazy_static::lazy_static! {
    static ref ULTIMA_TENTATIVA: Mutex<Option<Instant>> = Mutex::new(None);
}

pub async fn garantir(url_heartbeat: &str, id: &str) {
    if id.is_empty()
        || !url_heartbeat.starts_with(API_VIRTUS)
        || Config::has_permanent_password()
        || Config::is_disable_change_permanent_password()
    {
        return;
    }
    {
        let mut ultima = ULTIMA_TENTATIVA.lock().unwrap();
        if ultima.map(|x| x.elapsed() < INTERVALO).unwrap_or(false) {
            return;
        }
        *ultima = Some(Instant::now());
    }
    let senha = Config::get_auto_password(TAMANHO);
    let corpo = json!({
        "id": id,
        "uuid": crate::encode64(hbb_common::get_uuid()),
        "senha": senha,
    })
    .to_string();
    let url = format!("{API_VIRTUS}/api/virtus/senha-maquina");
    match crate::post_request(url, corpo, "").await {
        Ok(resposta) if resposta.contains("\"ok\":true") => {
            if Config::set_permanent_password(&senha) {
                log::info!("VirtusConecta: senha fixa automatica definida");
            } else {
                log::warn!("VirtusConecta: nao foi possivel gravar a senha fixa automatica");
            }
        }
        Ok(resposta) => log::warn!("VirtusConecta: servidor recusou a senha fixa: {resposta}"),
        Err(err) => log::warn!("VirtusConecta: falha ao enviar a senha fixa: {err:?}"),
    }
}
