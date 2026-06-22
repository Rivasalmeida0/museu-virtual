-- =============================================================
--  MIGRAÇÃO: Tabela de Computadores do Museu
--  Adiciona suporte a computadores históricos e supercomputadores
-- =============================================================
use museuvirtual;
CREATE TABLE IF NOT EXISTS computadores (
  id                INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome              VARCHAR(200)    NOT NULL,
  ano               SMALLINT UNSIGNED NOT NULL,
  fabricante        VARCHAR(150)    NOT NULL,
  categoria         ENUM('historico','supercomputador') NOT NULL,
  descricao         TEXT            NULL,
  curiosidade       TEXT            NULL,
  imagem_url        VARCHAR(1000)   NULL,
  wikipedia_url     VARCHAR(1000)   NULL,
  especificacoes    JSON            NULL,
  activa            TINYINT(1)      NOT NULL DEFAULT 1,
  criado_em         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_em    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_computadores_categoria (categoria),
  KEY idx_computadores_ano       (ano),
  KEY idx_computadores_activa    (activa)
) ENGINE=InnoDB;

-- =============================================================
--  SEED: Computadores Históricos
-- =============================================================

INSERT INTO computadores (nome, ano, fabricante, categoria, descricao, curiosidade, imagem_url, wikipedia_url, especificacoes) VALUES
('ENIAC', 1945, 'Universidade da Pensilvânia', 'historico',
 'O primeiro computador eletrónico de propósito geral. Ocupava uma sala inteira e usava 17.468 válvulas termiónicas.',
 'Podia executar 5.000 adições por segundo — menos do que uma calculadora moderna de bolso.',
 'https://upload.wikimedia.org/wikipedia/commons/6/6c/Eniac.jpg',
 'https://pt.wikipedia.org/wiki/ENIAC',
 '[{"label":"Processador","value":"17.468 válvulas"},{"label":"Peso","value":"27 toneladas"},{"label":"Área","value":"167 m²"},{"label":"Clock","value":"100 kHz"}]'),

('Apple I', 1976, 'Apple', 'historico',
 'O primeiro computador da Apple, vendido como placa-mãe montada. Steve Jobs e Steve Wozniak fundaram a Apple para vendê-lo.',
 'Foi vendido por US$ 666,66 — Steve Wozniak gostava de números repetidos.',
 'https://upload.wikimedia.org/wikipedia/commons/5/53/Apple_I_Computer.jpg',
 'https://pt.wikipedia.org/wiki/Apple_I',
 '[{"label":"Processador","value":"MOS 6502 @ 1 MHz"},{"label":"RAM","value":"4 KB"},{"label":"Armazenamento","value":"Cassete"},{"label":"Preço","value":"US$ 666,66"}]'),

('IBM 5150', 1981, 'IBM', 'historico',
 'O primeiro computador pessoal da IBM, que estabeleceu o padrão PC compatível. Usava o MS-DOS da Microsoft.',
 'A IBM esperava vender apenas 250.000 unidades em 5 anos. Vendeu mais de 3 milhões.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4e/IBM_PC_5150.jpg',
 'https://pt.wikipedia.org/wiki/IBM_PC',
 '[{"label":"Processador","value":"Intel 8088 @ 4.77 MHz"},{"label":"RAM","value":"16 KB (expansível a 256 KB)"},{"label":"SO","value":"PC-DOS 1.0"},{"label":"Preço","value":"US$ 1.565"}]'),

('Commodore 64', 1982, 'Commodore', 'historico',
 'O computador mais vendido de todos os tempos. Famoso pelos seus gráficos e som superiores para a época.',
 'Estima-se que ainda existam dezenas de milhares de C64 funcionais pelo mundo.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4b/Commodore-64-Computer.jpg',
 'https://pt.wikipedia.org/wiki/Commodore_64',
 '[{"label":"Processador","value":"MOS 6510 @ 1 MHz"},{"label":"RAM","value":"64 KB"},{"label":"Gráficos","value":"VIC-II 16 cores"},{"label":"Som","value":"SID 3 canais"}]'),

('Apple Macintosh 128K', 1984, 'Apple', 'historico',
 'O primeiro Macintosh, popularizou a interface gráfica com mouse. Famoso pelo comercial "1984" no Super Bowl.',
 'O interior da carcaça tinha as assinaturas gravadas de toda a equipa de desenvolvimento.',
 'https://upload.wikimedia.org/wikipedia/commons/9/98/Macintosh_128K_transparency.png',
 'https://pt.wikipedia.org/wiki/Macintosh_128K',
 '[{"label":"Processador","value":"Motorola 68000 @ 8 MHz"},{"label":"RAM","value":"128 KB"},{"label":"Tela","value":"9 polegadas 512×342"},{"label":"Preço","value":"US$ 2.495"}]'),

('Nintendo Entertainment System', 1985, 'Nintendo', 'historico',
 'A consola que salvou a indústria dos videojogos após o crash de 1983. Trouxe Super Mario Bros. ao mundo.',
 'O NES original vinha com um robô (R.O.B.) para parecer um brinquedo e não uma consola.',
 'https://upload.wikimedia.org/wikipedia/commons/8/82/NES-Console-Set.jpg',
 'https://pt.wikipedia.org/wiki/Nintendo_Entertainment_System',
 '[{"label":"Processador","value":"Ricoh 2A03 8-bit @ 1.79 MHz"},{"label":"RAM","value":"2 KB"},{"label":"Cores","value":"52 simultâneas"},{"label":"Unidades","value":"62 milhões"}]'),

('MSX', 1983, 'Microsoft / ASCII', 'historico',
 'Padrão de computador doméstico criado pela Microsoft e ASCII Corporation. Muito popular no Brasil e Japão.',
 'O MSX foi uma tentativa da Microsoft de criar um padrão aberto de hardware, como o PC fazia com software.',
 'https://upload.wikimedia.org/wikipedia/commons/e/e2/MSX_Philips_VG-8020.jpg',
 'https://pt.wikipedia.org/wiki/MSX',
 '[{"label":"Processador","value":"Z80 @ 3.58 MHz"},{"label":"RAM","value":"8-64 KB"},{"label":"Gráficos","value":"TMS9918 16 cores"},{"label":"Som","value":"AY-3-8910 3 canais"}]'),

('Altair 8800', 1975, 'MITS', 'historico',
 'Considerado o primeiro microcomputador de sucesso comercial. Vendido como kit por correspondência.',
 'Bill Gates e Paul Allen escreveram o primeiro BASIC para o Altair, fundando a Microsoft.',
 'https://upload.wikimedia.org/wikipedia/commons/f/f6/Altair_8800_Computer.jpg',
 'https://pt.wikipedia.org/wiki/Altair_8800',
 '[{"label":"Processador","value":"Intel 8080 @ 2 MHz"},{"label":"RAM","value":"256 bytes"},{"label":"Interface","value":"Painel de interruptores"},{"label":"Preço","value":"US$ 439 (kit)"}]'),

('Osborne 1', 1981, 'Osborne Computer', 'historico',
 'O primeiro computador portátil comercialmente viável. Pesava 11 kg e cabia numa maleta.',
 'A empresa faliu devido ao "Efeito Osborne" — anunciou um modelo melhor antes de vender o atual.',
 'https://upload.wikimedia.org/wikipedia/commons/9/9f/Osborne_1_Open.jpg',
 'https://pt.wikipedia.org/wiki/Osborne_1',
 '[{"label":"Processador","value":"Z80 @ 4 MHz"},{"label":"RAM","value":"64 KB"},{"label":"Tela","value":"5 polegadas CRT 52×24"},{"label":"Peso","value":"11,1 kg"}]'),

('Amiga 1000', 1985, 'Commodore', 'historico',
 'O computador mais avançado da sua época, com sistema multitarefa preventivo e gráficos a 4096 cores.',
 'O sistema operativo AmigaOS bootava diretamente para uma interface gráfica colorida em segundos.',
 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Amiga1000.jpg',
 'https://pt.wikipedia.org/wiki/Amiga_1000',
 '[{"label":"Processador","value":"Motorola 68000 @ 7.16 MHz"},{"label":"RAM","value":"256 KB"},{"label":"Cores","value":"4096 (HAM)"},{"label":"Som","value":"4 canais PCM estéreo"}]'),

('Z3 (Zuse 3)', 1941, 'Konrad Zuse', 'historico',
 'Considerado o primeiro computador programável e completamente automático do mundo. Usava relés eletromecânicos.',
 'Konrad Zuse construiu o Z3 no seu apartamento em Berlim durante a Segunda Guerra Mundial.',
 'https://upload.wikimedia.org/wikipedia/commons/d/d6/Z3_Deutsches_Museum.JPG',
 'https://pt.wikipedia.org/wiki/Z3',
 '[{"label":"Tecnologia","value":"2.600 relés"},{"label":"Clock","value":"5-10 Hz"},{"label":"Memória","value":"64 palavras de 22 bits"},{"label":"Frequência","value":"5.3 Hz"}]'),

('UNIVAC I', 1951, 'Remington Rand', 'historico',
 'O primeiro computador comercial fabricado nos Estados Unidos. Ficou famoso por prever a eleição de Eisenhower.',
 'A UNIVAC pesava 13 toneladas e custava US$ 1,25 milhão (equivalente a US$ 12 milhões hoje).',
 'https://upload.wikimedia.org/wikipedia/commons/2/26/UNIVAC_I_Computer.jpg',
 'https://pt.wikipedia.org/wiki/UNIVAC_I',
 '[{"label":"Válvulas","value":"5.200"},{"label":"Peso","value":"13 toneladas"},{"label":"Adições/s","value":"1.905"},{"label":"Preço","value":"US$ 1,25M"}]'),

('TRS-80', 1977, 'Tandy / RadioShack', 'historico',
 'Um dos primeiros computadores domésticos de massa, vendido nas lojas RadioShack.',
 'Era carinhosamente chamado de "Trash-80" (Lixo-80) pelos entusiastas.',
 'https://upload.wikimedia.org/wikipedia/commons/4/46/TRS-80_Model_I_1.jpg',
 'https://pt.wikipedia.org/wiki/TRS-80',
 '[{"label":"Processador","value":"Z80 @ 1.77 MHz"},{"label":"RAM","value":"4 KB"},{"label":"Armazenamento","value":"Cassete"},{"label":"Preço","value":"US$ 599"}]'),

('Commodore PET', 1977, 'Commodore', 'historico',
 'O Personal Electronic Transactor foi um computador all-in-one com monitor, teclado e cassete integrados.',
 'Foi adotado massivamente em escolas, ensinando BASIC a uma geração inteira de estudantes.',
 'https://upload.wikimedia.org/wikipedia/commons/f/fc/Commodore_PET_2001.jpg',
 'https://pt.wikipedia.org/wiki/Commodore_PET',
 '[{"label":"Processador","value":"MOS 6502 @ 1 MHz"},{"label":"RAM","value":"4 KB"},{"label":"Tela","value":"9 polegadas monocromática"},{"label":"Preço","value":"US$ 795"}]'),

('Atari 2600', 1977, 'Atari', 'historico',
 'A consola que popularizou os videojogos domésticos com cartuchos intercambiáveis.',
 'O jogo "E.T." para Atari 2600 foi tão mal-sucedido que milhares de cópias foram enterradas no deserto.',
 'https://upload.wikimedia.org/wikipedia/commons/8/8f/Atari-2600-Wood-4Sw-Set.jpg',
 'https://pt.wikipedia.org/wiki/Atari_2600',
 '[{"label":"Processador","value":"MOS 6507 @ 1.19 MHz"},{"label":"RAM","value":"128 bytes"},{"label":"Cores","value":"128"},{"label":"Unidades","value":"30 milhões"}]'),

('Xerox Alto', 1973, 'Xerox PARC', 'historico',
 'O primeiro computador com interface gráfica, mouse e Ethernet. Nunca foi comercializado mas influenciou tudo.',
 'Steve Jobs visitou a Xerox PARC em 1979 e saiu de lá determinado a construir o Macintosh.',
 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Xerox_Alto.jpg',
 'https://pt.wikipedia.org/wiki/Xerox_Alto',
 '[{"label":"Processador","value":"Xerox bit-slice"},{"label":"RAM","value":"256 KB"},{"label":"Tela","value":"808×606 pixels"},{"label":"Inovação","value":"Primeira GUI"}]');

-- =============================================================
--  SEED: Supercomputadores
-- =============================================================

INSERT INTO computadores (nome, ano, fabricante, categoria, descricao, curiosidade, imagem_url, wikipedia_url, especificacoes) VALUES
('Summit', 2018, 'IBM', 'supercomputador',
 'O supercomputador mais rápido do mundo em 2018-2020. Localizado no Oak Ridge National Laboratory, USA.',
 'O Summit consome energia suficiente para alimentar 8.000 casas americanas.',
 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Summit_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Summit_(supercomputador)',
 '[{"label":"Desempenho","value":"200 petaflops"},{"label":"Núcleos","value":"2.4 milhões"},{"label":"RAM","value":"2.8 PB"},{"label":"Consumo","value":"13 MW"}]'),

('Frontier', 2022, 'HPE / AMD', 'supercomputador',
 'O primeiro supercomputador a atingir a barreira do exaflop. Localizado no Oak Ridge National Laboratory.',
 'O Frontier usa processadores AMD EPYC e GPUs AMD Instinct, todos interligados por rede HPE Slingshot.',
 'https://upload.wikimedia.org/wikipedia/commons/f/fe/Frontier_supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Frontier_(supercomputador)',
 '[{"label":"Desempenho","value":"1.1 exaflops"},{"label":"Núcleos","value":"8.7 milhões"},{"label":"RAM","value":">4 PB"},{"label":"Consumo","value":"21 MW"}]'),

('Fugaku', 2020, 'Fujitsu', 'supercomputador',
 'Supercomputador japonês baseado em CPUs ARM A64FX. Foi o mais rápido do mundo em 2020-2021.',
 'O Fugaku foi usado extensivamente na pesquisa contra a COVID-19, simulando a dispersão de gotículas.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fugaku_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Fugaku_(supercomputador)',
 '[{"label":"Desempenho","value":"442 petaflops"},{"label":"Núcleos","value":"7.6 milhões"},{"label":"CPU","value":"Fujitsu A64FX ARM"},{"label":"Consumo","value":"28 MW"}]'),

('LUMI', 2021, 'HPE / AMD', 'supercomputador',
 'O supercomputador mais rápido da Europa e um dos mais ecológicos do mundo, localizado na Finlândia.',
 'O LUMI é alimentado inteiramente por energia hidroelétrica e o seu calor residual aquece edifícios da região.',
 'https://upload.wikimedia.org/wikipedia/commons/5/5b/LUMI_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/LUMI',
 '[{"label":"Desempenho","value":"375 petaflops"},{"label":"Núcleos","value":"2 milhões+"},{"label":"Energia","value":"100% renovável"},{"label":"Local","value":"Finlândia"}]'),

('Sierra', 2018, 'IBM / NVIDIA', 'supercomputador',
 'Supercomputador do Lawrence Livermore National Laboratory, usado para simulações de segurança nuclear.',
 'O Sierra foi projetado especificamente para simulações 3D de alta resolução de armas nucleares.',
 'https://upload.wikimedia.org/wikipedia/commons/5/56/Sierra_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Sierra_(supercomputador)',
 '[{"label":"Desempenho","value":"125 petaflops"},{"label":"Núcleos","value":"1.5 milhões"},{"label":"RAM","value":"1.4 PB"},{"label":"GPU","value":"NVIDIA Volta"}]'),

('Sunway TaihuLight', 2016, 'NRCPC', 'supercomputador',
 'Foi o supercomputador mais rápido do mundo em 2016-2017. Usa processadores chineses Sunway SW26010.',
 'O TaihuLight tem mais de 10 milhões de núcleos de processamento, todos projetados e fabricados na China.',
 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Sunway_TaihuLight.jpg',
 'https://pt.wikipedia.org/wiki/Sunway_TaihuLight',
 '[{"label":"Desempenho","value":"93 petaflops"},{"label":"Núcleos","value":"10.6 milhões"},{"label":"CPU","value":"Sunway SW26010"},{"label":"Consumo","value":"15.3 MW"}]'),

('Perlmutter', 2021, 'HPE / AMD', 'supercomputador',
 'Supercomputador do National Energy Research Scientific Computing Center (NERSC), focado em IA e ciência.',
 'O Perlmutter foi nomeado em homenagem ao físico Saul Perlmutter, Prémio Nobel da Física em 2011.',
 'https://upload.wikimedia.org/wikipedia/commons/4/44/Perlmutter_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Perlmutter_(supercomputador)',
 '[{"label":"Desempenho","value":"70 petaflops"},{"label":"Núcleos","value":"1.5 milhões+"},{"label":"GPU","value":"NVIDIA A100"},{"label":"Uso","value":"IA e ciência"}]'),

('Tianhe-2 (MilkyWay-2)', 2013, 'NUDT', 'supercomputador',
 'Foi o supercomputador mais rápido do mundo em 2013-2015. Desenvolvido pela Universidade Nacional de Tecnologia de Defesa da China.',
 'O Tianhe-2 significa "Via Láctea-2". Foi o primeiro sistema a ultrapassar 30 petaflops.',
 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Tianhe-2_Supercomputer.jpg',
 'https://pt.wikipedia.org/wiki/Tianhe-2',
 '[{"label":"Desempenho","value":"33.9 petaflops"},{"label":"Núcleos","value":"3.1 milhões"},{"label":"RAM","value":"1.4 PB"},{"label":"Consumo","value":"17.8 MW"}]'),

('IBM Watson', 2011, 'IBM', 'supercomputador',
 'Sistema de IA que venceu o concurso Jeopardy! contra campeões humanos. Representa um marco em processamento de linguagem natural.',
 'O Watson leu 200 milhões de páginas de texto em segundos para responder a perguntas no Jeopardy!.',
 'https://upload.wikimedia.org/wikipedia/commons/1/1f/IBM_Watson.jpg',
 'https://pt.wikipedia.org/wiki/Watson_(inteligência_artificial)',
 '[{"label":"Desempenho","value":"80 teraflops"},{"label":"RAM","value":"16 TB"},{"label":"Servidores","value":"90 IBM Power 750"},{"label":"Base de dados","value":"200M páginas"}]'),

('Aurora', 2023, 'HPE / Intel', 'supercomputador',
 'Supercomputador do Argonne National Laboratory, focado em IA e simulações científicas de grande escala.',
 'O Aurora foi projetado para ultrapassar 2 exaflops, sendo um dos primeiros sistemas exascale dos EUA.',
 'https://upload.wikimedia.org/wikipedia/commons/2/29/Aurora_supercomputer_rendering.jpg',
 'https://pt.wikipedia.org/wiki/Aurora_(supercomputador)',
 '[{"label":"Desempenho","value":"2+ exaflops"},{"label":"CPU","value":"Intel Xeon Max"},{"label":"GPU","value":"Intel Data Center GPU Max"},{"label":"Local","value":"Argonne, EUA"}]');
