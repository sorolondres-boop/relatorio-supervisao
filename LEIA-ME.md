# Relatório de Supervisão (aplicativo)

Aplicativo de supervisão de vendas (Sorocaba, Londrina e Curitiba): saídas de campo, tarefas dos
vendedores com Feito/Não feito e foto, avaliações, termômetro, metas e resumos para WhatsApp.

Funciona no navegador do celular e do computador e pode ser **instalado** como aplicativo
no Android e no iPhone. Cada pessoa entra com **e-mail e senha**.

## Como as pessoas entram

1. O **gerente** abre Configurações → **Acessos ao app** e libera o e-mail de cada pessoa
   (vendedor, supervisor ou gerente).
2. A pessoa abre o endereço do app, toca em **Primeiro acesso**, digita o e-mail liberado, o
   **código de acesso do app** e cria a própria senha. O código só é pedido nessa primeira vez.
3. Nas próximas vezes, é só e-mail e senha em **Entrar**.
4. Esqueceu a senha? O gerente cria uma senha nova em Configurações → Acessos → **Nova senha**.

Quem não foi liberado pelo gerente não consegue criar acesso, mesmo sabendo o código.

## Instalar no celular

- **Android (Chrome):** abra o endereço, toque nos três pontinhos e em **Instalar app**
  (ou use o botão “Instalar o app neste aparelho” da tela de entrada).
- **iPhone (Safari):** abra o endereço no Safari, toque em **Compartilhar** e em
  **Adicionar à Tela de Início**. No iPhone só o Safari instala aplicativos.

## O que existe aqui

| Arquivo | Para que serve |
| --- | --- |
| `index.html` | O aplicativo inteiro (telas, regras e login) |
| `supabase-config.js` | Endereço do banco e chave pública (a chave pública pode ficar no código) |
| `manifest.webmanifest`, `sw.js`, `icon-*.png` | Instalação como aplicativo e uso com sinal fraco |
| `banco-supabase.sql` | Tabelas, regras de segurança e funções do banco (rodar uma vez no Supabase) |

## Segurança (resumo)

- O banco é o Supabase, com **regras de acesso por linha (RLS)**. Sem entrar, nada é lido nem gravado.
- O **código de acesso** não fica no código do app: só uma versão criptografada dele fica no banco.
  Ele é conferido no servidor e tem limite de tentativas (6 erradas = espera de 30 minutos).
- Para criar uma conta é preciso: e-mail liberado pelo gerente **e** código certo. O servidor
  entrega uma senha de uso único (vale 10 minutos) e só aceita criar a conta com ela.
- O vendedor só consegue atualizar tarefas e prospecções. Ele não altera vendas, visitas, pedidos,
  aberturas, horas nem avaliações, não cria nem apaga saídas e não mexe nas configurações.
- A chave **secret** do Supabase nunca deve ir para o código nem para o GitHub.

## Para saber

- O plano gratuito do Supabase **pausa o projeto depois de 7 dias sem uso**. Basta abrir o painel e
  clicar em retomar. Com o app em uso diário isso não acontece.
- As fotos dos eventos ficam dentro do banco (cada uma com cerca de 200 KB). O plano gratuito tem
  500 MB. Se o volume crescer, o próximo passo é guardá-las no Storage do Supabase.
- Trocar o código de acesso: Configurações → Acessos → Código de acesso do app.
