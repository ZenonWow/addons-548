(With thanks to Thomas A. for the translation)

Descrição Geral
------------------------

MozzFullWorldMap é simples: ele adiciona uma nova caixa de seleção no canto superior esquerdo do mapa do mundo chamado 'Mostrar áreas inexploradas". Na marcação, ele vai fazer exatamente isso ... tornar as áreas que não têm explorado ainda no mapa visível para você. Este AddOn também adiciona um "MozzFullWorldMap" para o "Interface > AddOns" interface da janela de opções (Imprensa 'Escape' e selecione a opção do guia do "addons") que você pode usar para definir as MFWM opções e cores (veja notas abaixo)

As configurações padrão significa que áreas inexploradas aparecer com uma coloração azul/verde. Eu acredito que esta configuração é a mais útil, pois significa que você pode ver todos os detalhes do mapa, enquanto continuam sendo capazes de identificar quais áreas você ainda não explorado. Você pode alterar o comportamento do AddOn através dos comandos de Barra detalhadas abaixo, e retire a coloração azul completamente, deixando-o com uma vista padrão de cada mapa, como se você já tinha explorado todas as áreas.

Chave de ligação disponível para usuários de AlphaMap / cartógrafo / MetaMap

NOTA: A chave de ligação é desativado quando o mapa do mundo é aberto - a não ser que o mapa do mundo foi modificado por outro AddOn como AlphaMap)

MFWM é compatível com:

    WorldMapFrame
    AlphaMap
    MetaMap (você deve desabilitar MetaMapFWM se utilizar este AddOn)
    Cartógrafo (você deve desabilitar Foglight se utilizar este AddOn)
    nUI5
    Este addon é construído diretamente no nUI6 e não tem (não deve) precisa ser instalado como um addon separado ao usar nUI6.

MFWM usa um conjunto codificado de dados de sobreposição que duplica os dados disponíveis no cliente. Desde ele também consulta o cliente para descobrir quais sobreposiçãos foram descobertos (deve ser 100%) ele irá detectar discrepâncias nos dados do cliente e gravar todos os dados que são incompatíveis ou não presente em uma tabela de Errata salva. Se você tem uma errata salvo, ele irá imprimir uma mensagem no logon com instruções sobre como enviar suas errata ao autor para que ele possa ser adicionados à distribuição, ou você pode adicionar a errata para sua própria cópia. Você não tem de fazer qualquer um ... MFWM automaticamente mesclar suas errata com seus dados em cache para todos os seus personagens se beneficiar dela sem que você tenha de tomar qualquer ação.

Original escrito por Mozz, atualizado pela Shub, depois Telic e depois reescrito e atualmente mantido vivo por K. Scott Piel (spiel2001).

Suporte técnico
----------------------

Se você está tendo um problema com MozzFullWorldMap, gostaria de fazer uma sugestão, gostaria de fazer upload de dados de erratas, ou relatar um bug, por favor visite http://forums.nUIaddon.com - Se você ainda não tem uma conta em WoWInterface, você pode criar uma gratuitamente. Note que Wowi vai mandar você um e-mail com um link nela que você tem que clicar para confirmar seu endereço de e-mail antes que você possa começar a postar no fórum. Se você não ver esta mensagem, verifique a sua pasta de spam.

Quando, você tem uma conta em WoWInterface.com e você verificou o seu endereço de e-mail, você vai encontrar um tópico criado especificamente para o suporte de MFWM no endereço http://forums.nUIaddon.com. Todos os comentários, sugestões, relatórios de bugs e submissões de erratas são sempre bem vindas. Você também vai encontrar uma grande comunidade de usuários do Nui e MFWM nestes fóruns que estão sempre dispostos a ajudar, mesmo quando eu não estou disponível.

Por favor, mostre seu apoio de MFWM!
---------------------------------------------

Se você encontrar MozzFullWorldMap útil, e um benefício para o seu jogo, espero sinceramente que você vai ter um momento para visitar http://www.nUIaddon.com e criou uma conta lá. Você pode acompanhar as atualizações para Nui, MozzFullWorldMap e Party Spotter através do boletim gratuito (que nunca vai spam que você e nunca é compartilhado com ninguém). Você também pode fazer doações para o autor através do site e se inscrever para os serviços premium, tais como atualizações diretas via e-mail, área de download apenas de um membro premium, para evitar a loucura do dia  do patch, e muito mais. Suas doações são verdadeiramente apreciados e são o combustível que mantém o geek escravizado para você ~sorrir~

Cortar Comandos
--------------------

/Mfwm - exibe a janela de configurações MFWM opção

************************

As opções de configuração:

Usando o comando '/mfwm' vai abrir a tela de configuração MozzFullWorldMap. Você também pode abrir esta tela pressionando 'Escape' no jogo, então selecione a opção "Interface" opção de menu e clique em guia"Addons" . MozzFullWorldMap aparece no lado esquerdo do menu ... clique que para abrir a tela de opções.

As seguintes opções de configuração de exibição de mapa são suportados ....

1) "Revelar áreas inexploradas no mapa"

    ---- Ativado por padrão

    Quando marcado, MFWM mostrará área no mapa que seu personagem ainda não foi explorado. Normalmente as áreas que não têm explorado são ocultados. Desligar esta opção fará com que o mapa se comportar como o padrão Blizzard World Map faz.

2) "Destaque todos os dados em cache no mapa"

    ---- Desativado por padrão

    Esta opção é usada para ajudar você a ver o que os dados MFWM sabe sobre o mapa do mundo e os dados que você tem como errata em suas variáveis ​​salvas. Quando está selecionada, MFWM irá exibir todas as áreas que ele conhece em uma cor esmeralda e todos os seus errata em uma cor vermelha. Isso é feito independentemente do que áreas o seu personagem(s) têm e não tem descoberto e, independentemente do que cores e transparência que você escolheu. Esta opção destina-se como uma ferramenta para ajudar a compreender o que é "diferente" entre o que MFWM pensa que sabe sobre o mapa do mundo e que você tem "visto" ao explorar o mundo.

Essas opções são fornecidas para atualização do MFWM e suporte da depuração ...
    
3) "Salvar cache do mapa atual para variáveis ​​salvos"

    ---- Desativado por padrão

    Quando esta opção estiver ativada, MFWM vai salvar o actual mapa de cache de dados, incluindo tanto os dados de mapas conhecidos e as erratas que você coletou, em [World of Warcraft> WTF> {conta}> Variáveis ​​Salvo> MozzFullWorldMap.lua] para atualizar o [> Interface AddOns> MozzFullWorldMap> MapData.lua] conjunto de dados. Estes são os dados usados ​​por MFWM quando você está no jogo. Você não * tem que fazer isso. Ela só é necessária para atualizar os dados de mapa MFWM quando há conteúdo novo mundo ou alterações. Mesmo assim, os jogadores não têm que fazer isso a menos que o "Você tem errata" mensagem no login irrita-los.

4) "Escrever dados de depuração para variáveis ​​salvos"

    ---- Desativado por padrão

    Esta opção só deve ser usado por aqueles familiarizados com programação e Lua como uma ajuda para tentar descobrir o que MFWM está fazendo em tempo de execução. Quando ele tiver sido habilitado, MFWM vai escrever mensagens de texto em arquivo do variáveis ​​salvas do jogador na tabela de MFWM_PlayerData.Debugging. Estas mensagens irá acompanhar os continentes, zonas, mapas e sobreposições que MFWM está exibindo juntamente com cores e alfas como uma ajuda de depuração. A tabela de depuração é eliminado no início de cada sessão ou recarregar e os dados coletados até logout ou outra recarga salvo para as variáveis salvas do ​​MozzFullWorldMap.lua (nUI6.lua para usuários do nUI6). Isso pode ser um monte de dados se você usar o mapa  um monte ou abrir/fechar o mapa freqüentemente. Geralmente, esta opção deve ser sempre desligado.

5) "Rotular os painéis de mapa para depuração visual"

    ---- Desativado por padrão

    Como a opção anterior, esta opção é fornecida para aqueles que estão tentando resolver o que MFWM está fazendo e por quê. Ela apresenta o nome do painel, a textura e a linha/coluna de cada sobreposição ele desenha como uma ajuda na depuração visualmente o que está a ser exibido, onde no mapa. Assim como a opção de depuração de dados, esta opção normalmente deve ser desligado.

Estas são as opções de coloração de mapas. Apenas uma delas pode ser escolhido de uma vez. A seleção de qualquer uma destas três opções irá desmarcar as outras duas opções e alterar as configurações de cor ...

6) "Mostrar áreas inexploradas sem uma tonalidade"

    ---- Não selecionada por padrão

    Quando essa opção for selecionada, o mapa é exibido usando as cores do mapa normais como se você já explorou o mapa inteiro, independentemente da existência ou não de ter descoberto cada zona no mapa.

7) "Mostrar áreas inexploradas com um tonalidade esmeralda"

    ---- Selecionada por padrão

    Esta é a opção padrão de coloração mapa e quando selecionado exibe as áreas inexploradas no mapa em uma cor de esmeralda. Ele ainda permite que o usuário veja o detalhe nas áreas inexploradas do mapa, mas deixa claro que áreas do mapa foram e não foram descobertos.

8) "Usar uma cor personalizada para tingir áreas inexploradas"

    ---- Não selecionada por padrão

    Esta opção permite ao jogador escolher a sua própria cor para exibir as áreas inexploradas do mapa. Quando é selecionado, o usuário pode usar a roda de tonalidade e os controles deslizantes vermelho/verde/azul para escolher uma cor para usar. Note que ao selecionar as opções sem tonalidade ou tonalidade esmeralda, qualquer cor personalizada, o jogador pode ter escolhido será perdido.

Tem quatro controles deslizantes na tela de configuração ...

9) "Definir a opacidade das áreas inexploradas"

    ---- Definido para 100% de opacidade por padrão

    Esse controle deslizante ajusta a transparência das áreas inexploradas do mapa. Além de ser capaz de colorir as áreas inexploradas com uma cor, você também pode ajustar a forma como ele é transparente. Quando o controle deslizante é totalmente para a direita, as áreas inexploradas são totalmente opaco (exibido) e quando é para o lado esquerdo, eles são totalmente transparente (invisível).

10) "Definir o valor da tonalidade vermelha (R)"

    ----  Definido para 20% por padrão(verde esmeralda)

    Este controle deslizante é utilizado para controlar o componente vermelho do esquema de cores RGB para o tingimento de áreas inexploradas. Quando totalmente para a direita, o componente vermelho está definido para o seu valor máximo (vermelho) e quando totalmente para a esquerda, o componente vermelho é definido como 0 (preto). Esse controle deslizante só pode ser modificado quando o "Use uma cor personalizada para tingir áreas inexploradas" opção foi selecionada. Quando a opção de usar nenhuma tonalidade e/ou tonalidade esmeralda é ativada, esta barra exibe o componente vermelho da tonalidade predefinido selecionada.

11) "Definir o valor da tonalidade verde (G)"

    ----  Definido para 60% por padrão (verde esmeralda)

    Este controle deslizante é utilizado para controlar o componente verde do esquema de cores RGB para o tingimento de áreas inexploradas. Quando totalmente para a direita, o componente verde está definido para o seu valor máximo (verde) e quando totalmente para a esquerda, o componente verde é definido como 0 (preto). Esse controle deslizante só pode ser modificado quando o "Use uma cor personalizada para tingir áreas inexploradas" opção foi selecionada. Quando a opção de usar nenhuma tonalidade e/ou tonalidade esmeralda é ativada, esta barra exibe o componente verde da tonalidade predefinido selecionada.

12) "Definir o valor da tonalidade azul (B)"

    ---- Definido para 100% por padrão (verde esmeralda)

    Este controle deslizante é utilizado para controlar o componente azul do esquema de cores RGB para o tingimento de áreas inexploradas. Quando totalmente para a direita, o componente azul está definido para o seu valor máximo (azul) e quando totalmente para a esquerda, o componente azul é definido como 0 (preto). Esse controle deslizante só pode ser modificado quando o "Use uma cor personalizada para tingir áreas inexploradas" opção foi selecionada. Quando a opção de usar nenhuma tonalidade e/ou tonalidade esmeralda é ativada, esta barra exibe o componente azul da tonalidade predefinido selecionada.  


13) Roda de Cor

    Além dos controles deslizantes para o vermelho, verde e azul, a janela de configuração do MFWM também fornece uma roda de cores que pode ser usado para selecionar uma cor clicando dentro da roda e arrastando o mouse em torno da roda para alterar as cores. Conforme você mover o mouse, os controles deslizantes vermelho, verde e azul será atualizada para refletir a cor escolhida. Da mesma forma, alterar o valor dos controles deslizantes vermelho, verde e azul também vai mudar a posição do cursor na roda de cor, também se você escolher a opção de não usar uma tonalidade ou usar uma tonalidade esmeralda. A roda de cor só pode ser alterado quando o "Usar uma cor personalizada para tingir áreas inexploradas" opção é usada.

************************

Como enviar errata ao autor MozzFullWorldMap:

Se você encontrar erros ou dados em falta no mapa (MFWM irá imprimir uma mensagem no login dizendo que você tem errata mapa) e tem tempo para ajudar, por favor, faça o seguinte:

Primeiro, verifique os sites de download e verifique se você tem a versão mais recente de MFWM. Os pontos de distribuição oficiais para MFWM são (em ordem)

    http://www.nUIaddon.com
    http://www.WoWInterface.com
    http://www.curse.com
    http://wow.curseforge.com

Qualquer outra fonte de MFWM *não* é oficialmente sancionada (contudo permitido) e pode ou não pode ser correto ou atual.

Se você tem a versão mais recente do MFWM de um desses quatro locais, e você tem errata do mapa em seu banco de dados, então você pode fazer o seguinte para dar uma mão e enviar seus errata ao autor para que ele pode ser incluído em futuras versões ...

Enviar por e-mail ...

    Sair do jogo
    Vá para o seu [ World of Warcraft > WTF > {account} > Saved Variables ] pasta
    E-mail o arquivo MozzFullWorldMap.lua para kscottpiel@gmail.com
    (Se você estiver usando nUI6, enviar o arquivo nUI6.lua em vez de MozzFullWorldMap.lua)

Enviar através dos fóruns de suporte ...

    Sair do jogo
    Ir para http://forums.nUIaddon.com e login (criar uma conta se você não tiver um)
    Ir para o fórum de suporte MozzFullWorldMap
    Criar um novo tópico
    Clique no ícone de clipe no editor de mensagem ou desça até "Gerenciar Anexos"
    Carregue o seu [World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua] arquivo
    (Se você estiver usando nUI6, fazer o upload do arquivo nUI6.lua em vez de MozzFullWorldMap.lua)

Nota: O arquivo MozzFullWorldMap.lua contém dados *não* pessoais. Se você estiver usando nUI6 e fazer o upload do arquivo nUI6.lua, esse arquivo contém os nomes dos reinos você jogar, e os nomes dos personagens em cada reino, mas não amarrar esses nomes para o seu nome, e-mail ou nome de conta e não contém qualquer outra informação pessoal.
     
************************

Como atualizar seus próprios dados sem uma atualização:

O processo de atualização de seus dados em cache foi simplificado na versão MFWM 5.00.05.00. Para todos os efeitos práticos, você só tem que explorar o mundo eo sistema irá coletar a informação e mesclá-lo em seu cache. Os "errata" será salvo em seu arquivo [World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua] (nUI6.lua para usuários do nUI6 ) e podem ser facilmente analisado por visualizar o arquivo com qualquer editor de texto simples ... ele aparecerá na tabela MFWM_PlayerData.Errata. Esta errata é automaticamente incorporado ao de  built-in dados do mapas no login e uma mensagem é impressa para dizer-lhe que você tem errata e como você pode enviá-lo para o autor. Caso contrário, você realmente não tem que fazer nada ... quando você explorou uma área "novo" em qualquer um dos seus personagens, será exibido corretamente para todos os seus outros personagens.

Se você quiser realmente mesclar as erratas em seus dados conhecidos, o método mais fácil é usar o comando '/mfwm' para abrir o painel do interface de opções e marque a opção "Salvar cache do mapa atual para as variáveis ​​salvas", então clique em "OK" e sair do jogo. Abra o seu  arquivo [World of Warcraft > WTF > {account} > Saved Variables > WorldOfWarcraft.lua] com um editor de texto simples (nUI6.lua para nUI6 usuários). Localizar a tabela MFWM_PlayerData e a tabela MapData nele. Copiar todos os dados de mais de MFWM_PlayerData.MapData por cima da tabela MFWM.MapData no arquivo [Interface > AddOns > MozzFullWorldMap > MapData.lua] (Interface > AddOns> nUI6 > Features > MozzFullWorldMap > MapData.lua para usuários do  nUI6), depois salve e feche o arquivo MapData.lua. Depois de ter copiado a tabela, apagar os dados na tabela MFWM_PlayerData.Errata no MozzFullWorldMap.lua (nUI6.lua) arquivo de variáveis ​​salvo e salvar o arquivo. Entrar volta para o jogo e verificar os mapas ... eles devem ser correto agora. Mais uma vez, usar a opção '/mfwm' para abrir a tela de opções, desligar a opçõe de "Salvar cache do mapa atual para as variáveis ​​salvas" e clique em "Ok"- você está pronto para jogar.