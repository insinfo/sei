-- Migration 0001: provider OpenID Connect do backend do SEI em Dart.
--
-- Estas três tabelas NÃO fazem parte do schema real do SEI/SIP restaurado
-- (não existem em nenhuma versão oficial do SEI ou do SIP): são
-- infraestrutura própria deste projeto para o backend atuar como Identity
-- Provider (IdP) OpenID Connect de outros sistemas  -  o mesmo papel que o
-- SIP desempenha no SEI verdadeiro como serviço de autorização
-- compartilhado por múltiplos sistemas de uma instituição. O primeiro
-- cliente (Relying Party) registrado é o próprio frontend AngularDart do
-- SEI  -  ver a migration de seed 0002.
--
-- Moram no schema "public" da base sei_5_0_0, a mesma conexão já usada
-- pelo login local (AutenticacaoService/AutenticacaoRepository), porque o
-- fluxo de autorização resolve o usuário autenticado (sei_5_0_0.usuario)
-- na mesma requisição que emite o código/token OIDC.
--
-- Convenções seguidas (ver AGENTS.md § Banco de dados e migrations):
--   * nomenclatura em português, sem sufixo em inglês (created_at/expires_at
--     etc.);
--   * "timestamp without time zone" em toda coluna de data/hora;
--   * chave primária natural (string opaca gerada pela aplicação), sem
--     sequence artificial  -  cada tabela já nasce com um identificador de
--     negócio único (id_cliente, valor_codigo, valor_token);
--   * COMMENT ON TABLE/COLUMN em tudo.

CREATE TABLE public.oidc_cliente (
    id_cliente character varying(255) NOT NULL,
    hash_segredo character varying(255),
    nome character varying(255) NOT NULL,
    uris_redirecionamento text[] NOT NULL,
    escopos_permitidos text[] NOT NULL,
    tipo_aplicacao character varying(50) NOT NULL,
    uris_redirecionamento_pos_logout text[] NOT NULL DEFAULT '{}'::text[],
    tipos_concessao_suportados text[] NOT NULL
        DEFAULT '{authorization_code,refresh_token}'::text[],
    tipos_resposta_suportados text[] NOT NULL DEFAULT '{code}'::text[],
    metodo_autenticacao_token_endpoint character varying(50) NOT NULL
        DEFAULT 'none',
    ativo boolean NOT NULL DEFAULT true,
    data_cadastro timestamp without time zone NOT NULL DEFAULT LOCALTIMESTAMP,
    data_atualizacao timestamp without time zone,
    CONSTRAINT oidc_cliente_pkey PRIMARY KEY (id_cliente),
    CONSTRAINT oidc_cliente_tipo_aplicacao_chk CHECK (
        tipo_aplicacao IN ('web_spa', 'backend_confidencial', 'aplicativo_nativo')
    )
);

COMMENT ON TABLE public.oidc_cliente IS
    'Cliente (Relying Party) registrado no provider OpenID Connect deste '
    'backend. Não é uma tabela do schema real do SEI/SIP: é o cadastro dos '
    'sistemas que confiam neste backend como Identity Provider. Cada linha '
    'sobrevive por todo o tempo em que o sistema cliente existir; não há '
    'expiração.';
COMMENT ON COLUMN public.oidc_cliente.id_cliente IS
    'Identificador do cliente (client_id do protocolo OAuth2/OIDC)  -  '
    'string opaca aleatória gerada pela aplicação em OidcCliente.gerarIdCliente, '
    'nunca sequencial. Chave primária.';
COMMENT ON COLUMN public.oidc_cliente.hash_segredo IS
    'Hash do segredo do cliente (client_secret), presente apenas para '
    'clientes tipo_aplicacao = backend_confidencial. Nulo para clientes '
    'públicos (web_spa/aplicativo_nativo), que autenticam só com PKCE.';
COMMENT ON COLUMN public.oidc_cliente.nome IS
    'Nome legível do sistema cliente, exibido na tela de login.';
COMMENT ON COLUMN public.oidc_cliente.uris_redirecionamento IS
    'URIs de redirecionamento permitidas para devolver o código de '
    'autorização. O endpoint de autorização só redireciona para uma URI '
    'presente aqui, comparada por igualdade exata (sem coringa).';
COMMENT ON COLUMN public.oidc_cliente.escopos_permitidos IS
    'Escopos que este cliente pode solicitar no endpoint de autorização. '
    'Um escopo pedido fora desta lista é descartado na concessão, nunca '
    'causa erro.';
COMMENT ON COLUMN public.oidc_cliente.tipo_aplicacao IS
    'Tipo da aplicação cliente: web_spa (SPA pública, ex.: o frontend '
    'AngularDart do SEI, sem segredo, usa PKCE), backend_confidencial '
    '(aplicação servidor, pode guardar segredo com segurança), '
    'aplicativo_nativo (app mobile/desktop, público, usa PKCE).';
COMMENT ON COLUMN public.oidc_cliente.uris_redirecionamento_pos_logout IS
    'URIs para onde o navegador pode ser redirecionado após logout '
    '(RP-Initiated Logout), validadas contra post_logout_redirect_uri.';
COMMENT ON COLUMN public.oidc_cliente.tipos_concessao_suportados IS
    'Grant types que este cliente pode usar no endpoint de token '
    '(nomenclatura do protocolo OAuth2, mantida em inglês por ser valor '
    'de especificação, não de domínio de negócio do SEI).';
COMMENT ON COLUMN public.oidc_cliente.tipos_resposta_suportados IS
    'Response types que este cliente pode usar no endpoint de '
    'autorização (hoje só "code" é suportado pelo provider).';
COMMENT ON COLUMN public.oidc_cliente.metodo_autenticacao_token_endpoint IS
    'Método de autenticação do cliente no endpoint de token: none '
    '(cliente público, sem segredo), client_secret_post ou '
    'client_secret_basic (cliente confidencial).';
COMMENT ON COLUMN public.oidc_cliente.ativo IS
    'Quando falso, o cliente é tratado como desconhecido pelo provider '
    '(authorize e token passam a rejeitá-lo) sem apagar o cadastro.';
COMMENT ON COLUMN public.oidc_cliente.data_cadastro IS
    'Momento em que o cliente foi registrado no provider.';
COMMENT ON COLUMN public.oidc_cliente.data_atualizacao IS
    'Momento da última alteração do cadastro do cliente; nulo enquanto '
    'nunca foi alterado após o cadastro.';


CREATE TABLE public.oidc_codigo_autorizacao (
    valor_codigo character varying(100) NOT NULL,
    id_cliente character varying(255) NOT NULL,
    id_usuario integer NOT NULL,
    escopos text[] NOT NULL,
    uri_redirecionamento text NOT NULL,
    data_expiracao timestamp without time zone NOT NULL,
    code_challenge character varying(255),
    code_challenge_method character varying(50),
    nonce character varying(255),
    data_cadastro timestamp without time zone NOT NULL DEFAULT LOCALTIMESTAMP,
    CONSTRAINT oidc_codigo_autorizacao_pkey PRIMARY KEY (valor_codigo),
    CONSTRAINT oidc_codigo_autorizacao_id_cliente_fkey
        FOREIGN KEY (id_cliente) REFERENCES public.oidc_cliente (id_cliente),
    CONSTRAINT oidc_codigo_autorizacao_id_usuario_fkey
        FOREIGN KEY (id_usuario) REFERENCES public.usuario (id_usuario)
);

COMMENT ON TABLE public.oidc_codigo_autorizacao IS
    'Código de autorização de uso único do fluxo authorization_code do '
    'provider OIDC. Emitido após login local bem sucedido em POST /login '
    'e trocado por access_token/id_token (e, quando o escopo concedido '
    'inclui offline_access, refresh_token) em POST /oauth2/token. A linha '
    'é apagada assim que trocada ou quando expira sem uso  -  nunca '
    'atualizada, só inserida e apagada.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.valor_codigo IS
    'Valor do código em si  -  string opaca aleatória gerada pela '
    'aplicação. Chave primária.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.id_cliente IS
    'Cliente (oidc_cliente.id_cliente) para o qual o código foi emitido.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.id_usuario IS
    'Usuário autenticado (sei_5_0_0.usuario.id_usuario) para quem o '
    'código foi emitido  -  vira o "sub" do id_token/access_token.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.escopos IS
    'Escopos efetivamente concedidos nesta autorização (interseção entre '
    'o solicitado e oidc_cliente.escopos_permitidos), repassados ao token '
    'emitido na troca.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.uri_redirecionamento IS
    'URI de redirecionamento usada nesta autorização  -  o endpoint de '
    'token exige que a mesma URI seja informada de novo na troca.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.data_expiracao IS
    'Momento a partir do qual o código deixa de poder ser trocado  -  '
    'janela curta (minutos), só precisa sobreviver ao redirecionamento do '
    'navegador entre authorize e a submissão do login.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.code_challenge IS
    'Desafio PKCE (RFC 7636) informado no authorize. Nulo quando o '
    'cliente não usou PKCE.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.code_challenge_method IS
    'Método do desafio PKCE  -  hoje só "S256" é aceito pelo provider.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.nonce IS
    'Valor nonce do pedido de autorização original, repassado ao '
    'id_token emitido na troca, para o cliente detectar replay.';
COMMENT ON COLUMN public.oidc_codigo_autorizacao.data_cadastro IS
    'Momento em que o código foi emitido.';


CREATE TABLE public.oidc_token_renovacao (
    valor_token character varying(255) NOT NULL,
    id_cliente character varying(255) NOT NULL,
    id_usuario integer NOT NULL,
    escopos text[] NOT NULL,
    data_expiracao timestamp without time zone NOT NULL,
    data_cadastro timestamp without time zone NOT NULL DEFAULT LOCALTIMESTAMP,
    revogado boolean NOT NULL DEFAULT false,
    CONSTRAINT oidc_token_renovacao_pkey PRIMARY KEY (valor_token),
    CONSTRAINT oidc_token_renovacao_id_cliente_fkey
        FOREIGN KEY (id_cliente) REFERENCES public.oidc_cliente (id_cliente),
    CONSTRAINT oidc_token_renovacao_id_usuario_fkey
        FOREIGN KEY (id_usuario) REFERENCES public.usuario (id_usuario)
);

COMMENT ON TABLE public.oidc_token_renovacao IS
    'Refresh token do provider OIDC, emitido quando o escopo concedido '
    'inclui offline_access. Cada renovação (grant_type=refresh_token em '
    'POST /oauth2/token) revoga o token usado e emite um novo (rotação), '
    'para que um valor vazado não continue utilizável indefinidamente.';
COMMENT ON COLUMN public.oidc_token_renovacao.valor_token IS
    'Valor do refresh token em si  -  string opaca aleatória gerada pela '
    'aplicação. Chave primária.';
COMMENT ON COLUMN public.oidc_token_renovacao.id_cliente IS
    'Cliente (oidc_cliente.id_cliente) para o qual o token foi emitido.';
COMMENT ON COLUMN public.oidc_token_renovacao.id_usuario IS
    'Usuário (sei_5_0_0.usuario.id_usuario) para quem o token foi '
    'emitido.';
COMMENT ON COLUMN public.oidc_token_renovacao.escopos IS
    'Escopos concedidos que este refresh token pode renovar  -  os mesmos '
    'access tokens emitidos a partir dele carregam estes escopos.';
COMMENT ON COLUMN public.oidc_token_renovacao.data_expiracao IS
    'Momento a partir do qual o token deixa de poder ser trocado por um '
    'novo access_token, mesmo que ainda não tenha sido usado.';
COMMENT ON COLUMN public.oidc_token_renovacao.data_cadastro IS
    'Momento em que este token foi emitido (na emissão original ou numa '
    'rotação).';
COMMENT ON COLUMN public.oidc_token_renovacao.revogado IS
    'Verdadeiro quando o token já foi trocado por um novo par (rotação) '
    'ou revogado explicitamente. Um token revogado nunca é aceito de '
    'novo  -  a linha é mantida (não apagada) só para auditoria simples.';
