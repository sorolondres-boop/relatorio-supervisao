# Gestão à Vista (aplicativo)

Aplicativo **Gestão à Vista**, de supervisão de vendas (Sorocaba, Londrina e Curitiba): saídas de campo, tarefas dos
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

## Agenda do mês (4 compromissos por vendedor)

- Todo mês o app prepara a **proposta**: **2 Dias da beleza e 2 Rodadas de mesa de negócios** para cada vendedor.
  O supervisor (Urbano ou Pires) ou o gerente abre **Pendências → Agenda do mês**, confere as datas e toca em **OK**:
  só então os compromissos aparecem para os vendedores. No começo do mês, e enquanto nada foi liberado, o app mostra
  um aviso no topo.
- Depois do OK, o supervisor muda **datas e tipos** quando quiser (por exemplo, trocar por Café com Aneethun),
  adiciona ou remove compromissos e avisa o vendedor pelo WhatsApp. O padrão continua sendo 4 por mês.
- O vendedor tem a aba **Agenda**, com a própria agenda da **semana** e do **mês**: compromissos da agenda do mês,
  compromissos das saídas e visitas de prospecção. Ele cumpre cada um como sempre (foto do local obrigatória,
  Feito ou Não feito).
- Para mudar **qualquer data**, o vendedor toca em **Pedir mudança de data**, sugere a nova data e conta o motivo.
  O supervisor **aprova ou recusa** no app e o vendedor vê a resposta. Aprovada, a data nova passa a valer
  (inclusive o retorno da visita de prospecção).
- A agenda do mês fica separada das saídas: não conta como saída, venda ou hora em campo. Os compromissos aparecem
  nas Pendências, no placar dos compromissos, nos atrasos e na galeria de fotos como qualquer outro compromisso, e contam como qualquer outra tarefa na pontuação extra.

## Aba Metas: metas e resultados do mês

A aba **Metas** (gerente e supervisores) tem o **Placar do mês** e duas partes para preencher:

- **Metas do mês:** para cada vendedor, a **meta de vendas** (R$) e a **meta de aberturas de clientes**, a **normal** e a
  **acima do normal**. Dá para copiar as metas do mês anterior. A meta de cada franquia passa a ser a soma das metas dos
  vendedores (é ela que aparece no foguete do Mês).
- **Atualização da semana:** uma vez por semana, digite o **acumulado do mês** de cada vendedor (vendas em R$ e
  aberturas). O app mostra o **ritmo** (quanto era esperado até hoje e quanto falta por semana), guarda o histórico
  semanal e atualiza o placar. O contador de cada franquia diz quantos já foram atualizados na semana.
- Os pontos só fecham no fim do mês. A meta da semana serve só para acompanhar o ritmo, e a meta do dia continua como
  comemoração na saída, sem valer pontos.
- O vendedor vê apenas o cartão **Sua meta do mês** (barras de vendas e aberturas, ritmo e mensagens de incentivo).
  Pontos e classificação são só da gerência e da supervisão.

## Pontos do mês (base 100)

A tabela ilustrada (`tabela-pontuacao.png`) fica na pasta `versoes/` do computador, fora do GitHub.

| Critério | Pontos | Como ganha |
| --- | --- | --- |
| Meta de vendas | 30 | Proporcional ao % da meta batido (80% da meta = 24; 100% = 30) |
| Meta de aberturas | 30 | Proporcional às aberturas em relação à meta normal (4 de 5 = 24; meta batida = 30) |
| Tarefas no prazo | 25 | Agenda do mês, prospecções e compromissos. No prazo 100%; atraso de 1 a 2 dias 60%; de 3 a 5 dias 30%; mais que isso, não feito ou sem resposta há mais de 2 dias, 0. Pontos = 25 × a média. Se o supervisor aprovar a mudança de data pedida pelo vendedor, vale o prazo novo |
| Avaliação dos supervisores | 15 | Média das notas (0 a 10) das saídas × 1,5 (nota 8 = 12) |

Se faltar algum item no mês (por exemplo, nenhuma tarefa), ele sai da conta e os outros se ajustam para fechar 100.

**Pontos extras (até +30):**

| Extra | Pontos | Como ganha |
| --- | --- | --- |
| Passou da meta de vendas | até +10 | +1 a cada 5% acima da meta (150% ou mais = +10) |
| Aberturas acima do normal | até +10 | Cresce da meta normal até a meta "acima do normal" (normal 10, acima 15: 12 aberturas = +4). Sem meta "acima do normal", +1 a cada 10% acima da normal |
| Campeão de aberturas da franquia | +5 | Quem mais abrir clientes na franquia no mês (empate: todos). O valor aceita vírgula e muda em Configurações |
| Melhor avaliação dos supervisores | +5 | Maior nota média da equipe toda, desde que seja 8 ou mais |

**Selos e desempate:** 🎯 meta de vendas batida e 🆕 aberturas na meta "acima do normal". No ranking, quem tem mais selos
fica na frente; entre iguais, vale a pontuação. **Classes:** 90 ou mais Craque, 80 a 89 Destaque, 70 a 79 No ritmo,
60 a 69 Em evolução, abaixo de 60 Precisa de atenção. O máximo possível é 130 pontos.

A **pontuação extra de tarefas** (nota de 0 a 5 no cartão do Mês) é a mesma conta das tarefas, e vale 25 dos 100 pontos.

## Corrida maluca e avatares (só gerência e supervisão)

- Na aba **Metas**, o card **Corrida maluca do mês** junta as 3 franquias numa pista. Cada vendedor é um kart (a cor mostra a
  franquia) com a cabecinha dele, andando até a linha de chegada, que é **100% da meta de vendas**. O pontilhado amarelo é o
  ritmo esperado para hoje. Chama = passou da meta, fumaça = abaixo do ritmo, chave inglesa = ainda sem vendas. Os botões das
  franquias filtram a pista e o narrador resume quem lidera. Os karts largam animados (com "reduzir movimento" ligado no
  celular, aparecem direto na posição).
- **Avatares:** cada faixa da pista tem um ícone 📷 para anexar o **avatar ou a foto** do vendedor (o mesmo botão existe no
  card **Avatares da equipe**). O app recorta (arraste a imagem e use o zoom) e guarda **só o recorte pequeno**, com cerca de
  5 KB, que aparece dentro do kart. Em **Estilo**, escolha **Original** para um avatar que já está pronto (a imagem entra como
  está) ou um desenho para fotos (Suave, Desenho e Quadrinho). A foto enviada não é guardada nem mandada para ninguém. O
  desenho é um filtro de imagem feito no próprio aparelho, não uma caricatura feita por inteligência artificial. Dá para
  trocar a imagem quando quiser. Sem imagem, aparece a inicial do nome.
- O avatar também aparece nas listas da gerência e da supervisão. O vendedor não recebe os avatares nem vê a corrida.
- Os avatares ficam no banco em `config/avatares`, que só gerente e supervisor leem e gravam.

## Tela motivacional do vendedor

Toda vez que o vendedor envia a avaliação do supervisor, aparece uma tela com uma mensagem de motivação e o lado bom do
dia dele (tarefas concluídas, fotos, dias seguidos no prazo). Se a soma das 5 notas for menor que 25 (de 50), a
mensagem é mais forte e acolhedora, para ele não desanimar. Nunca fala em nota baixa.

## Aparência

O visual padrão é o **Ouro**: fundo escuro com ondas de luz dourada, cartões de vidro com borda dourada, trilha de gemas em 3D até o troféu, avatares com anel dourado, barra de missão com estrela, contador com placas de dígitos e botões metálicos. No botão de cada supervisor aparece a etiqueta verde "Ativo hoje" quando ele lançou uma saída hoje ou é quem está usando o app. Cada pessoa pode trocar em Configurações → Aparência para **Jogo**, **Claro**, **Escuro** ou **Automático** (segue o celular). A escolha fica salva no aparelho. As fotos de avatar também valem para os supervisores (card Avatares da equipe).

Se a escolha de aparência era da versão antiga, o app volta para o **Jogo** uma vez; depois é só escolher de novo em
Configurações → Aparência.

## Versão nova do app

O GitHub Pages guarda a página por até 10 minutos. Por isso o app confere sozinho se saiu uma versão mais nova: ao abrir,
ele se atualiza uma vez; depois, ao voltar para o app, aparece o botão verde **Tem versão nova do app** para atualizar
quando quiser.

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
| `banco-supabase-v2-vendedor.sql` | Faz o vendedor ler só o que é dele (rodar depois do arquivo acima) |
| `versoes/` | Cópia da versão anterior (tema claro, antes do tema Jogo e do novo nome) e imagens comparando os visuais e mostrando as telas da agenda do mês |

## Segurança (resumo)

- O banco é o Supabase, com **regras de acesso por linha (RLS)**. Sem entrar, nada é lido nem gravado.
- O **código de acesso** não fica no código do app: só uma versão criptografada dele fica no banco.
  Ele é conferido no servidor e tem limite de tentativas (6 erradas = espera de 30 minutos).
- Para criar uma conta é preciso: e-mail liberado pelo gerente **e** código certo. O servidor
  entrega uma senha de uso único (vale 10 minutos) e só aceita criar a conta com ela.
- O vendedor lê só as saídas em que participa, as próprias fotos, a própria avaliação e os próprios acessos, e só consegue atualizar tarefas e prospecções. Ele não altera vendas, visitas, pedidos,
  aberturas, horas nem avaliações, não cria nem apaga saídas e não mexe nas configurações.
- Os avatares ficam na coleção `config`, que o vendedor não lê (ele só recebe a parte pública da configuração).
- As metas e os resultados do mês ficam em campos que o banco já protege contra edição do vendedor: ele só vê os
  próprios números e não consegue alterá-los.
- O pedido de mudança da agenda vale pelo app (o vendedor pede, o supervisor decide). No banco, o vendedor continua
  podendo atualizar as próprias tarefas, como já era.
- A chave **secret** do Supabase nunca deve ir para o código nem para o GitHub.

## Para saber

- O plano gratuito do Supabase **pausa o projeto depois de 7 dias sem uso**. Basta abrir o painel e
  clicar em retomar. Com o app em uso diário isso não acontece.
- As fotos dos eventos ficam dentro do banco (cada uma com cerca de 200 KB). O plano gratuito tem
  500 MB. Se o volume crescer, o próximo passo é guardá-las no Storage do Supabase.
- Trocar o código de acesso: Configurações → Acessos → Código de acesso do app.
