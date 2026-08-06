[CmdletBinding()]
param(
    [ValidateSet('SEI', 'SIP')]
    [string]$Sistema = 'SEI',
    [string]$Servidor = 'localhost',
    [int]$Porta = 5432,
    [string]$Usuario = 'dart',
    [string]$Banco = '',
    [switch]$Recriar,
    [string]$Fonte = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Testar-IdentificadorSql {
    param(
        [string]$Valor,
        [string]$Nome
    )

    if ($Valor -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
        throw "O $Nome deve ser um identificador PostgreSQL simples e seguro."
    }
}

function Invocar-Psql {
    param(
        [string]$Base,
        [string[]]$Argumentos
    )

    & psql -X -q -v ON_ERROR_STOP=1 -h $Servidor -p $Porta -U $Usuario -d $Base @Argumentos
    if ($LASTEXITCODE -ne 0) {
        throw "O psql falhou ao executar uma operação na base $Base."
    }
}

function Obter-ValorPsql {
    param(
        [string]$Base,
        [string]$Sql
    )

    $saida = & psql -X -v ON_ERROR_STOP=1 -h $Servidor -p $Porta -U $Usuario -d $Base -t -A -c $Sql
    if ($LASTEXITCODE -ne 0) {
        throw "O psql falhou ao consultar a base $Base."
    }
    return ($saida | Select-Object -First 1).Trim()
}

function Obter-HashSha256 {
    param([string]$Caminho)

    $algoritmo = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Caminho)
        return ([System.BitConverter]::ToString($algoritmo.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algoritmo.Dispose()
    }
}

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    throw 'O executável psql não foi encontrado no PATH.'
}
if ([string]::IsNullOrWhiteSpace($env:PGPASSWORD)) {
    throw 'Defina PGPASSWORD somente na sessão atual antes da restauração.'
}

switch ($Sistema) {
    'SEI' {
        $nomeBancoPadrao = 'sei_5_0_0'
        $papelDono = 'sei_user'
        $arquivoPadrao = 'sei_5_0_0_BD_Ref_Exec.sql'
        $hashEsperado = 'a648b8ce1acdc34b53e90ab4425fca6d848e1981d12de3393eadfb6590261e18'
        $sqlAmostra = "SELECT nome FROM public.tipo_procedimento WHERE id_tipo_procedimento = 100000101;"
        $sqlMetricas = @'
SELECT concat_ws('|',
  current_setting('server_encoding'),
  (SELECT count(*) FROM pg_tables WHERE schemaname = 'public'),
  (SELECT count(*) FROM pg_sequences WHERE schemaname = 'public'),
  (SELECT count(*) FROM public.tipo_procedimento),
  (SELECT count(*) FROM public.serie)
);
'@
    }
    'SIP' {
        $nomeBancoPadrao = 'sip_5_0_0'
        $papelDono = 'sip_user'
        $arquivoPadrao = 'sip_5_0_0_BD_Ref_Exec.sql'
        $hashEsperado = '9b1ba2f93580174901fc5f61ab12188f804a01ee84dd0657778ceedf58fde52e'
        $sqlAmostra = "SELECT nome FROM public.usuario WHERE sigla = 'teste';"
        $sqlMetricas = @'
SELECT concat_ws('|',
  current_setting('server_encoding'),
  (SELECT count(*) FROM pg_tables WHERE schemaname = 'public'),
  (SELECT count(*) FROM pg_sequences WHERE schemaname = 'public'),
  (SELECT count(*) FROM pg_constraint WHERE contype = 'f'),
  (SELECT count(*) FROM public.recurso)
);
'@
    }
}

if ([string]::IsNullOrWhiteSpace($Banco)) {
    $Banco = $nomeBancoPadrao
}
if ([string]::IsNullOrWhiteSpace($Fonte)) {
    $diretorioReferencias = Split-Path -Parent $PSScriptRoot
    $diretorioBackend = Split-Path -Parent $diretorioReferencias
    $diretorioRaiz = Split-Path -Parent $diretorioBackend
    $Fonte = Join-Path $diretorioRaiz "resources\$arquivoPadrao"
}

Testar-IdentificadorSql -Valor $Usuario -Nome 'usuário'
Testar-IdentificadorSql -Valor $Banco -Nome 'banco'
if (-not (Test-Path -LiteralPath $Fonte -PathType Leaf)) {
    throw "O dump canônico não foi encontrado em $Fonte."
}

$bytesFonte = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Fonte))
$hashFonte = Obter-HashSha256 -Caminho (Resolve-Path -LiteralPath $Fonte)
if ($hashFonte -ne $hashEsperado) {
    throw "O SHA-256 da fonte não corresponde ao dump canônico $Sistema 5.0.0: $hashFonte"
}
$utf8Estrito = [System.Text.UTF8Encoding]::new($false, $true)
$fonteEhUtf8 = $true
try {
    [void]$utf8Estrito.GetString($bytesFonte)
}
catch [System.Text.DecoderFallbackException] {
    $fonteEhUtf8 = $false
}
if ($fonteEhUtf8) {
    throw 'O dump selecionado não possui os bytes LATIN1 esperados; a restauração foi interrompida para evitar perda de caracteres.'
}

$papelExiste = Obter-ValorPsql -Base 'postgres' -Sql "SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$papelDono');"
if ($papelExiste -ne 't') {
    Invocar-Psql -Base 'postgres' -Argumentos @('-c', "CREATE ROLE $papelDono NOLOGIN;")
}

$bancoExiste = Obter-ValorPsql -Base 'postgres' -Sql "SELECT EXISTS (SELECT 1 FROM pg_database WHERE datname = '$Banco');"
if ($bancoExiste -eq 't') {
    if (-not $Recriar) {
        throw "A base $Banco já existe. Use -Recriar somente se desejar substituí-la integralmente."
    }
    Invocar-Psql -Base 'postgres' -Argumentos @('-c', "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$Banco' AND pid <> pg_backend_pid();")
    Invocar-Psql -Base 'postgres' -Argumentos @('-c', "DROP DATABASE $Banco;")
}

Invocar-Psql -Base 'postgres' -Argumentos @('-c', "CREATE DATABASE $Banco WITH OWNER = $Usuario TEMPLATE = template0 ENCODING = 'LATIN1' LC_COLLATE = 'C' LC_CTYPE = 'C';")
Invocar-Psql -Base $Banco -Argumentos @('-f', (Resolve-Path -LiteralPath $Fonte))

$metricas = Obter-ValorPsql -Base $Banco -Sql $sqlMetricas
$amostra = Obter-ValorPsql -Base $Banco -Sql $sqlAmostra
if ($metricas -notmatch '^LATIN1\|') {
    throw "A base restaurada não está em LATIN1: $metricas"
}
if ($amostra -match '�' -or $amostra -notmatch '[áéíóúÁÉÍÓÚàèìòùÀÈÌÒÙãõÃÕçÇ]') {
    throw "A amostra textual não preservou a acentuação esperada: $amostra"
}

[pscustomobject]@{
    sistema = $Sistema
    banco = $Banco
    fonte = (Resolve-Path -LiteralPath $Fonte)
    sha256 = $hashFonte
    metricas = $metricas
    amostra_acentuada = $amostra
} | Format-List
