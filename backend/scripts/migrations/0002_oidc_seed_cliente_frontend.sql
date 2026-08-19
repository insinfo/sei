-- Migration 0002 (seed): registra o frontend AngularDart do SEI como o
-- primeiro cliente (Relying Party) do provider OIDC criado na migration
-- 0001.
--
-- client_id gerado uma única vez com OidcCliente.gerarIdCliente() (script
-- descartável, não commitado) e fixado aqui como literal, para que o
-- mesmo valor seja usado em todo ambiente que rodar esta migration -
-- diferente das outras duas tabelas (código/token), cujo valor nasce em
-- tempo de execução, um client_id precisa ser estável entre subidas do
-- backend para o frontend poder tratá-lo como configuração fixa.
--
-- Porta do dev server do frontend (webdev serve): AJUSTADA nesta rodada de
-- 8080 para 8081. O valor original (8080, porta padrão do `webdev serve` e
-- a mesma do projeto de referência `new_sali/frontend`) era um palpite
-- documentado como "a confirmar". A confirmação real está em
-- `AGENTS.md` (raiz do repositório), seção "Execução de comandos": o
-- comando de serve real deste projeto (disparado manualmente pelo usuário
-- via `start.ps1`, fora deste repositório) é
-- `webdev serve --spa-fallback web:8081 --hostname 127.0.0.1`, ou seja,
-- porta 8081 e host `127.0.0.1`. Mantidas as duas variantes de host
-- (`localhost`/`127.0.0.1`) por segurança, como já era o padrão aqui.
--
-- Idempotente: rodar de novo sobre um ambiente que já tem o cliente atualiza
-- os campos (redirect URIs, escopos) sem duplicar a linha nem trocar o
-- client_id.

INSERT INTO public.oidc_cliente (
    id_cliente,
    hash_segredo,
    nome,
    uris_redirecionamento,
    escopos_permitidos,
    tipo_aplicacao,
    uris_redirecionamento_pos_logout,
    tipos_concessao_suportados,
    tipos_resposta_suportados,
    metodo_autenticacao_token_endpoint,
    ativo
) VALUES (
    'VtmSvvPTcSi11_bmtW8ncd-NmW-4LFAQ0sqNps6XlHw',
    NULL,
    'Frontend SEI (AngularDart)',
    ARRAY[
        'http://localhost:8081/callback',
        'http://127.0.0.1:8081/callback'
    ]::text[],
    ARRAY['openid', 'profile']::text[],
    'web_spa',
    ARRAY[
        'http://localhost:8081/',
        'http://127.0.0.1:8081/'
    ]::text[],
    ARRAY['authorization_code', 'refresh_token']::text[],
    ARRAY['code']::text[],
    'none',
    true
)
ON CONFLICT (id_cliente) DO UPDATE SET
    nome = EXCLUDED.nome,
    uris_redirecionamento = EXCLUDED.uris_redirecionamento,
    escopos_permitidos = EXCLUDED.escopos_permitidos,
    tipo_aplicacao = EXCLUDED.tipo_aplicacao,
    uris_redirecionamento_pos_logout = EXCLUDED.uris_redirecionamento_pos_logout,
    tipos_concessao_suportados = EXCLUDED.tipos_concessao_suportados,
    tipos_resposta_suportados = EXCLUDED.tipos_resposta_suportados,
    metodo_autenticacao_token_endpoint = EXCLUDED.metodo_autenticacao_token_endpoint,
    ativo = EXCLUDED.ativo,
    data_atualizacao = LOCALTIMESTAMP;
