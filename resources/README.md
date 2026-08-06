# Dumps canônicos para restauração local

Esta pasta contém cópias byte a byte dos dumps PostgreSQL oficiais de
referência usados pelo projeto. Ambos usam codificação física `LATIN1`; não os
converta para UTF-8 nem substitua caracteres durante a cópia.

| Arquivo | Uso | SHA-256 |
| --- | --- | --- |
| `sei_5_0_0_BD_Ref_Exec.sql` | Base de Referência SEI 5.0.0 | `a648b8ce1acdc34b53e90ab4425fca6d848e1981d12de3393eadfb6590261e18` |
| `sip_5_0_0_BD_Ref_Exec.sql` | Base de Referência SIP 5.0.0 | `9b1ba2f93580174901fc5f61ab12188f804a01ee84dd0657778ceedf58fde52e` |

Para restaurar, use
`backend/scripts/restaurar_referencia_postgresql.ps1`, que
cria a base com `LATIN1`, valida a fonte e confirma a acentuação após a carga.
As bases locais ativas são `sei_5_0_0` e `sip_5_0_0`.
