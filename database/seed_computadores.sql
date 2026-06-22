-- =============================================================
--  SEED: Computadores do Museu (versão atualizada)
--  Executar após a migration_computadores.sql
-- =============================================================

-- Limpar dados existentes para evitar duplicados
TRUNCATE TABLE computadores;

-- =============================================================
--  Computadores Históricos
-- =============================================================

INSERT INTO computadores (nome, ano, fabricante, categoria, descricao, curiosidade, imagem_url, wikipedia_url) VALUES
('ENIAC', 1945, 'Universidade da Pensilvânia', 'historico',
 'O primeiro computador eletrónico de uso geral do mundo. Pesava 27 toneladas, ocupava uma sala inteira e usava 18.000 válvulas termoiónicas. Foi criado para calcular tabelas balísticas para o exército americano.',
 'Consumia tanta eletricidade que, segundo a lenda, as luzes da cidade piscavam quando era ligado.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Eniac.jpg',
 'https://pt.wikipedia.org/wiki/ENIAC'),

('Apple I', 1976, 'Apple Computer', 'historico',
 'O primeiro produto da Apple, criado por Steve Wozniak e vendido por Steve Jobs. Era vendido como placa-mãe sem caixa, monitor ou teclado — o utilizador montava o resto.',
 'Foi vendido originalmente por 666,66 dólares. Apenas 200 unidades foram produzidas e hoje vale até 400.000 dólares em leilão.',
 'https://upload.wikimedia.org/wikipedia/commons/a/a1/Apple_I_Computer.jpg',
 'https://pt.wikipedia.org/wiki/Apple_I'),

('Commodore 64', 1982, 'Commodore Business Machines', 'historico',
 'O computador pessoal mais vendido de todos os tempos, com estimativas entre 10 a 17 milhões de unidades. Era famoso pelos seus jogos e capacidade musical avançada para a época.',
 'O seu chip de som SID foi tão revolucionário que ainda hoje existem músicos que o usam em concertos ao vivo.',
 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Commodore64.jpg',
 'https://pt.wikipedia.org/wiki/Commodore_64'),

('IBM 5150 (IBM PC)', 1981, 'IBM', 'historico',
 'O computador que definiu o padrão da arquitectura PC tal como conhecemos hoje. A IBM abriu a arquitectura para outros fabricantes, criando o ecossistema de PCs compatíveis que domina até hoje.',
 'A IBM contratou a Microsoft para fornecer o sistema operativo — Bill Gates comprou o DOS por 50.000 dólares e licenciou-o à IBM, mantendo os direitos para si.',
 'https://upload.wikimedia.org/wikipedia/commons/6/69/IBM_PC_5150.jpg',
 'https://pt.wikipedia.org/wiki/IBM_Personal_Computer'),

('Macintosh 128K', 1984, 'Apple', 'historico',
 'O primeiro computador pessoal de sucesso comercial com interface gráfica e rato. Mudou para sempre a forma como as pessoas interagem com computadores.',
 'Steve Jobs apresentou-o com o famoso anúncio ''1984'' durante o Super Bowl, que é considerado até hoje um dos melhores anúncios publicitários da história.',
 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Macintosh_128k_transparency.png',
 'https://pt.wikipedia.org/wiki/Macintosh_128K'),

('Cray-1', 1976, 'Cray Research', 'historico',
 'O supercomputador mais rápido do mundo quando foi lançado. A sua forma circular icónica não era apenas estética — foi projectada para minimizar o comprimento dos cabos e aumentar a velocidade.',
 'O primeiro Cray-1 foi vendido ao Laboratório Nacional de Los Alamos por 8,8 milhões de dólares. O banco circular em volta servia de assento e escondia os sistemas de refrigeração.',
 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Cray_1_IMG_9600.jpg',
 'https://pt.wikipedia.org/wiki/Cray-1'),

('ZX Spectrum', 1982, 'Sinclair Research', 'historico',
 'O computador que introduziu a computação pessoal para milhões de europeus, especialmente no Reino Unido e Portugal. Foi a base da indústria de videojogos europeia nos anos 80.',
 'Em Portugal e Angola, o ZX Spectrum foi o primeiro contacto de muita gente com a programação — as revistas da época vinham com código para digitar linha a linha.',
 'https://upload.wikimedia.org/wikipedia/commons/3/33/ZXSpectrum48k.jpg',
 'https://pt.wikipedia.org/wiki/ZX_Spectrum'),

('Altair 8800', 1975, 'MITS', 'historico',
 'Considerado o computador que deu início à revolução dos computadores pessoais. Era vendido em kit para montar em casa e não tinha teclado, monitor nem sistema operativo — só luzes e interruptores.',
 'Foi a capa do Altair na revista Popular Electronics que inspirou Bill Gates e Paul Allen a fundar a Microsoft, para criar um interpretador BASIC para ele.',
 'https://upload.wikimedia.org/wikipedia/commons/0/01/Altair_8800_Computer.jpg',
 'https://pt.wikipedia.org/wiki/Altair_8800'),

('Deep Blue', 1996, 'IBM', 'historico',
 'O supercomputador da IBM especializado em xadrez que derrotou o campeão mundial Garry Kasparov em 1997. Foi um marco histórico na inteligência artificial.',
 'Kasparov acusou a IBM de usar jogadores humanos a ajudar o Deep Blue durante a partida. A IBM negou e nunca permitiu uma revanche, encerrando o projecto logo depois.',
 'https://upload.wikimedia.org/wikipedia/commons/b/be/Deep_Blue.jpg',
 'https://pt.wikipedia.org/wiki/Deep_Blue'),

('Commodore Amiga 1000', 1985, 'Commodore', 'historico',
 'Um computador muito à frente do seu tempo, com capacidades gráficas e de multitarefa que os PCs da época nem sonhavam ter. Era usado profissionalmente em produção de vídeo e animação.',
 'As assinaturas dos engenheiros que o criaram estão gravadas na placa-mãe para sempre — incluindo a pata do cão de estimação do designer de hardware.',
 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Amiga_1000.jpg',
 'https://pt.wikipedia.org/wiki/Amiga_1000'),

('IBM System/360', 1964, 'IBM', 'historico',
 'A família de computadores que revolucionou a indústria ao introduzir o conceito de arquitectura compatível — diferentes modelos podiam correr o mesmo software. Mudou para sempre como os computadores são desenhados.',
 'O desenvolvimento do System/360 custou 5 mil milhões de dólares — mais do que o Projecto Manhattan da bomba atómica. Foi a maior aposta empresarial da história até então.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4d/IBM_System360_Model30_Front_Panel.jpg',
 'https://pt.wikipedia.org/wiki/IBM_System/360');

-- =============================================================
--  Supercomputadores
-- =============================================================

INSERT INTO computadores (nome, ano, fabricante, categoria, descricao, curiosidade, imagem_url, wikipedia_url) VALUES
('Frontier', 2022, 'HPE / AMD — Oak Ridge National Laboratory', 'supercomputador',
 'O primeiro supercomputador a ultrapassar a barreira do exaflop — 1 quintilhão de operações por segundo. É actualmente o mais rápido do mundo na lista TOP500.',
 'A velocidade do Frontier é tão grande que, se cada ser humano na Terra fizesse um cálculo por segundo, levariam mais de 4 anos para fazer o que o Frontier faz em apenas 1 segundo.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Frontier_Supercomputer_ORNL.jpg/1280px-Frontier_Supercomputer_ORNL.jpg',
 'https://pt.wikipedia.org/wiki/Frontier_(supercomputador)'),

('Summit', 2018, 'IBM / NVIDIA — Oak Ridge National Laboratory', 'supercomputador',
 'Foi o supercomputador mais rápido do mundo entre 2018 e 2022. Usado para investigação em medicina, clima, física de partículas e inteligência artificial.',
 'O Summit foi usado para identificar compostos que podiam combater o COVID-19 em 2020 — analisou 8.000 compostos em dias, algo que levaria anos a um laboratório convencional.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Summit_Supercomputer_ORNL.jpg/1280px-Summit_Supercomputer_ORNL.jpg',
 'https://pt.wikipedia.org/wiki/Summit_(supercomputador)'),

('Fugaku', 2020, 'RIKEN / Fujitsu', 'supercomputador',
 'Supercomputador japonês que foi o mais rápido do mundo em 2020-2021. Usa processadores ARM, provando que a arquitectura dos smartphones pode competir com hardware especializado.',
 'O nome Fugaku é outro nome do Monte Fuji em japonês. Foi usado para simular a dispersão de gotículas do vírus em espaços fechados durante a pandemia.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Fugaku_Supercomputer.jpg/1280px-Fugaku_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Fugaku_(supercomputador)'),

('Aurora', 2023, 'Intel / HPE — Argonne National Laboratory', 'supercomputador',
 'Um dos supercomputadores exascale mais recentes, projectado especificamente para inteligência artificial e simulações científicas de larga escala.',
 'O Aurora foi concebido para treinar modelos de IA científica de nível nacional — desde modelos climáticos até ao mapeamento do cérebro humano.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Aurora_supercomputer_ANL.jpg/1280px-Aurora_supercomputer_ANL.jpg',
 'https://en.wikipedia.org/wiki/Aurora_(supercomputer)'),

('El Capitan', 2024, 'HPE / AMD — Lawrence Livermore National Laboratory', 'supercomputador',
 'O supercomputador mais recente e poderoso dos EUA, com capacidade de 2 exaflops. Destinado principalmente a simulações de armas nucleares e segurança nacional.',
 'O El Capitan é tão potente que pode fazer em 1 hora simulações que levariam anos nos supercomputadores da década anterior.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/El_Capitan_supercomputer.jpg/1280px-El_Capitan_supercomputer.jpg',
 'https://en.wikipedia.org/wiki/El_Capitan_(supercomputer)');
