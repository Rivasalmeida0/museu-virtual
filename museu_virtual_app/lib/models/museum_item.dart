import 'package:flutter/material.dart';

class MuseumItem {
  final String title;
  final String era;
  final String releaseDate;
  final String description;
  final String imageUrl;
  final List<String> historyParagraphs;
  final List<ItemSpec> specs;
  final List<FunFact> funFacts;
  final String hotspotDetail;

  const MuseumItem({
    required this.title,
    required this.era,
    required this.releaseDate,
    required this.description,
    required this.imageUrl,
    required this.historyParagraphs,
    required this.specs,
    required this.funFacts,
    required this.hotspotDetail,
  });
}

class ItemSpec {
  final String label;
  final String value;
  final bool highlight;

  const ItemSpec({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class FunFact {
  final IconData icon;
  final String title;
  final String description;

  const FunFact({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ─── Sample: Apple Macintosh 128K ───────────────────────────────────────────

const macintosh128k = MuseumItem(
  title: 'Apple Macintosh 128K',
  era: 'Computação Pessoal',
  releaseDate: '24 DE JANEIRO DE 1984',
  description:
      'O computador que mudou tudo. Introduzido com o famoso comercial "1984" durante o Super Bowl, o Macintosh foi o primeiro computador pessoal de sucesso a usar uma interface gráfica de usuário (GUI) e um mouse.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDiVI8oLYjBuIq_jnEgMYrMuDlyGsCu-2Z9UiQxYmNiLcgo2oPlsOSAFccEeVI93i9yJQsWunOJ2YKXPwOQpXfCu7OiVo0Cl-0aBXXaCnIt_401X7eCjuRcmseX7lMXijryWYGMAWkgeSp5ZMMi1NZ-z0Tyxq7juiIZw7C9_2ho8yAoV2usuua5UdxEyzKL2KAegpHEkJbbzOdiC_It2tnB7NYWbAgQAtFdm59IJTvOfHThR1ymqJ3Z3SvSqeL8wenYLrqYz0H-CLoI',
  historyParagraphs: [
    'Desenvolvido por uma equipe liderada inicialmente por Jef Raskin e depois por Steve Jobs, o Macintosh 128K não era apenas uma máquina, mas uma declaração de design e acessibilidade. Antes dele, operar um computador exigia o aprendizado de comandos de texto complexos. Com o "Mac", a interação tornou-se visual e intuitiva.',
    'Seu gabinete compacto "bege" abrigava uma tela monocromática de 9 polegadas, uma unidade de disquete de 3,5 polegadas e, o mais importante, vinha com o MacWrite e o MacPaint, demonstrando imediatamente o potencial da computação gráfica para usuários comuns e profissionais criativos.',
    'Apesar do alto preço inicial de US\$ 2.495 e de algumas limitações técnicas (como a falta de ventilador para resfriamento silencioso e a memória fixa), ele estabeleceu o padrão para o que um computador moderno deveria ser.',
  ],
  specs: [
    ItemSpec(label: 'Processador', value: 'Motorola 68000 @ 8 MHz'),
    ItemSpec(label: 'RAM', value: '128 KB (Integrada)'),
    ItemSpec(label: 'Armazenamento', value: 'Drive Disquete 400 KB'),
    ItemSpec(label: 'Resolução', value: '512 x 342 Monocromático'),
    ItemSpec(label: 'Preço Lançamento', value: '\$2,495.00', highlight: true),
  ],
  funFacts: [
    FunFact(
      icon: Icons.edit_note,
      title: 'Assinaturas Internas',
      description:
          'O interior da carcaça plástica trazia as assinaturas gravadas de toda a equipe de desenvolvimento do Macintosh.',
    ),
    FunFact(
      icon: Icons.brush,
      title: 'Inspirado em Picasso',
      description:
          'A identidade visual original e os ícones foram inspirados em um estilo de linha minimalista que lembrava a arte de Picasso.',
    ),
    FunFact(
      icon: Icons.ac_unit,
      title: 'Sem Ventoinha',
      description:
          'Steve Jobs insistiu que a máquina não tivesse ventoinhas para ser silenciosa, o que causava problemas de superaquecimento.',
    ),
  ],
  hotspotDetail:
      'Drive de disquete Sony 3.5" de 400KB — Uma revolução para a época, substituindo os frágeis disquetes de 5.25".',
);

// ─── Sample: Altair 8800 ────────────────────────────────────────────────────

const altair8800 = MuseumItem(
  title: 'Altair 8800',
  era: 'Microcomputadores',
  releaseDate: '1975',
  description:
      'O marco inicial da revolução dos microcomputadores, vendido como kit por correspondência. O Altair 8800 inspirou uma geração de entusiastas e deu origem à Microsoft.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBwuIj8Cxsg-itNfnVSqEpqsoj7Ny6ZFBK9imVCmFZtO5E3bwofA8OriJMJHTUg24qtRALtgAA1lC0TiUuY3juj88WhJRJpKLT_Ptrcp1r1gVJtFU0H2fa_j6hC7MdF0-J6WNAQqW-PyY4bkzXNcnCnNvRyAd1-gq63CDPuVOYP70uQpTbpuvJmX2JZBCJ2y3T2n4QB3pCtu-cWtGp4o98to9zolOtjj9xE_5GMF5_nSddt8YiJRWgI26UISwF1LErJKuY96e2zFEpK',
  historyParagraphs: [
    'Lançado em 1975 pela MITS, o Altair 8800 é amplamente considerado o primeiro computador pessoal de sucesso comercial. Era vendido como um kit de montar por US\$ 439, ou já montado por US\$ 621 — valores que atraíram hobbyistas e engenheiros.',
    'Seu painel frontal com interruptores de alavanca e LEDs era a interface primária. Para programá-lo, o usuário precisava inserir código binário manualmente usando os interruptores. Apesar da simplicidade, foi a plataforma que inspirou Bill Gates e Paul Allen a escrever o primeiro interpretador BASIC para microcomputadores.',
    'O Altair 8800 provou que computadores poderiam ser pequenos o suficiente e acessíveis o bastante para estar nas mãos de indivíduos, plantando a semente de toda a indústria moderna de computadores pessoais.',
  ],
  specs: [
    ItemSpec(label: 'Processador', value: 'Intel 8080 @ 2 MHz'),
    ItemSpec(label: 'RAM', value: '256 bytes (expansível a 64 KB)'),
    ItemSpec(label: 'Armazenamento', value: 'Fita de papel / Disquete (opcional)'),
    ItemSpec(label: 'Interface', value: 'Painel frontal com chaves e LEDs'),
    ItemSpec(label: 'Preço Lançamento', value: '\$439 (kit)', highlight: true),
  ],
  funFacts: [
    FunFact(
      icon: Icons.code,
      title: 'Nascimento da Microsoft',
      description:
          'Bill Gates e Paul Allen desenvolveram o primeiro BASIC para o Altair, levando à fundação da Microsoft.',
    ),
    FunFact(
      icon: Icons.toggle_on,
      title: 'Programação Manual',
      description:
          'Para carregar programas, os usuários alternavam manualmente 25 interruptores para cada byte de instrução.',
    ),
    FunFact(
      icon: Icons.memory,
      title: '256 Bytes de RAM',
      description:
          'O modelo básico vinha com apenas 256 bytes de RAM — menos do que esta descrição ocupa em texto.',
    ),
  ],
  hotspotDetail:
      'O Altair 8800 usava o processador Intel 8080, um dos primeiros microprocessadores de 8 bits amplamente disponíveis.',
);

// ─── Sample: Osborne 1 ──────────────────────────────────────────────────────

const osborne1 = MuseumItem(
  title: 'Osborne 1',
  era: 'Computadores Portáteis',
  releaseDate: '1981',
  description:
      'O primeiro computador portátil verdadeiramente bem-sucedido. Pesando 24,5 libras, era o sonho de todo profissional que precisava levar o escritório consigo.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBCSUcKDF7Jgu4ZZlhrl7XKenp4MGluleNTO70W8MQFFBAIPXtlfgucc54LwBfyh3nyjpSjAmxIxN9h46R5FY5WdEweCU2ij7XtCRWIuf5sEQveCok65yA0kSqyS6rRTxt7lSMxvGsLEMZIZ5Gu4a7CTX9YgxPujadFPpnI3urGnyk_Icat98ByKBudt7DY8iuX4CWOsmf3dPO6cR031AhP286E5LqXUod12OfEXFZeK3qWvALTTI0UxmpOsZb4GCUFvgyTP6URt12l',
  historyParagraphs: [
    'Fundado por Adam Osborne, o Osborne 1 foi lançado em 1981 como o primeiro microcomputador portátil comercialmente viável. Ele vinha dentro de uma maleta de plástico bege que lembrava uma máquina de costura, com uma pequena tela CRT de 5 polegadas e dois drives de disquete.',
    'Incluía um generoso pacote de software: processador de texto WordStar, planilha SuperCalc, banco de dados dBase II e as linguagens CBASIC e CP/M. Este agrupamento de software tornou o Osborne 1 extremamente atraente para profissionais de negócios.',
    'Infelizmente, a Osborne Computer Corporation faliu em 1983 devido ao que ficou conhecido como "Efeito Osborne" — o anúncio prematuro de um modelo superior que canibalizou as vendas do modelo atual.',
  ],
  specs: [
    ItemSpec(label: 'Processador', value: 'Z80 @ 4 MHz'),
    ItemSpec(label: 'RAM', value: '64 KB'),
    ItemSpec(label: 'Armazenamento', value: '2× Drives Disquete 5.25" 91 KB'),
    ItemSpec(label: 'Tela', value: '5" CRT Monocromático 52×24'),
    ItemSpec(label: 'Peso', value: '24,5 lb (11,1 kg)', highlight: true),
  ],
  funFacts: [
    FunFact(
      icon: Icons.work,
      title: 'Escritório Portátil',
      description:
          'Vinha com US\$ 1.500 em software incluso, algo revolucionário para a época.',
    ),
    FunFact(
      icon: Icons.trending_down,
      title: 'Efeito Osborne',
      description:
          'O termo "Efeito Osborne" foi cunhado após o anúncio prematuro do Osborne Executive causar a falência da empresa.',
    ),
    FunFact(
      icon: Icons.battery_unknown,
      title: 'Sem Bateria',
      description:
          'Apesar de portátil, o Osborne 1 não tinha bateria interna e precisava ser conectado à tomada.',
    ),
  ],
  hotspotDetail:
      'O Osborne 1 pesava 24,5 libras e vinha com duas unidades de disquete de 5.25" — uma para o sistema operacional e outra para os dados.',
);

// ─── Sample: Commodore PET ──────────────────────────────────────────────────

const commodorePET = MuseumItem(
  title: 'Commodore PET',
  era: 'Computadores Domésticos',
  releaseDate: '1977',
  description:
      'O Personal Electronic Transactor (PET) foi um dos primeiros computadores domésticos completos, combinando monitor, teclado e unidade de fita em um único gabinete.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB0u4hzW2tbaRa3DZlOuGC_gjOOB4Z_o_SIfe_fjH6XytLf1P3JW3NJNSWFft1PdQjLBFDgCCPzL1DNLHzMztvABI59gysQTlsay5WtKyWes99TlUWQFNedaIV0lgazKqWX2qNjA5OvSKsQri8dEfp8xe_77aHdibH7jj7BuC69zF1pw-rZB9WQCK3NNshVYTirnWycubeaCDQo62qq-r-q9JCytwjtBapDd5eqZAn5wIirDdl-wVzlSwpFz-2U2_D6zxDdWtodfkDS',
  historyParagraphs: [
    'Lançado em 1977 pela Commodore International, o PET 2001 foi um dos três computadores domésticos pioneiros (junto com o Apple II e o TRS-80). Seu design all-in-one trapezoidal em metal tornou-se icônico, combinando monitor, teclado e gravador de cassetes.',
    'Com um processador MOS 6502 rodando a 1 MHz e 4 KB de RAM (expansível para 32 KB), o PET foi amplamente adotado em escolas e laboratórios de informática nos Estados Unidos e Europa. Seu sistema operacional BASIC residia em ROM e era carregado instantaneamente ao ligar.',
    'O pequeno teclado com teclas tipo calculadora foi uma das críticas mais frequentes, mas o PET permanece como um símbolo da era dourada dos primeiros computadores domésticos, responsável por introduzir uma geração inteira à programação.',
  ],
  specs: [
    ItemSpec(label: 'Processador', value: 'MOS 6502 @ 1 MHz'),
    ItemSpec(label: 'RAM', value: '4 KB (expansível a 32 KB)'),
    ItemSpec(label: 'Armazenamento', value: 'Gravador de Cassete integrado'),
    ItemSpec(label: 'Tela', value: '9" Monocromática (verde)'),
    ItemSpec(label: 'Preço Lançamento', value: '\$795', highlight: true),
  ],
  funFacts: [
    FunFact(
      icon: Icons.school,
      title: 'O Computador Escolar',
      description:
          'Foi o computador padrão em milhares de escolas, ensinando programação BASIC a uma geração.',
    ),
    FunFact(
      icon: Icons.keyboard,
      title: 'Teclado de Calculadora',
      description:
          'O teclado original tinha teclas tipo calculadora, muito criticadas por serem desconfortáveis para digitar.',
    ),
    FunFact(
      icon: Icons.fast_forward,
      title: 'Cassete como Disco',
      description:
          'Os programas eram carregados de gravadores de fita cassete comuns, levando vários minutos para iniciar.',
    ),
  ],
  hotspotDetail:
      'O PET 2001 usava o processador MOS 6502, o mesmo chip que mais tarde alimentaria o Nintendo Entertainment System (NES).',
);

// ─── Sample: IBM PC 5150 ────────────────────────────────────────────────────

const ibmPC5150 = MuseumItem(
  title: 'IBM PC 5150',
  era: 'Computação Empresarial',
  releaseDate: '12 DE AGOSTO DE 1981',
  description:
      'O computador que definiu o padrão da indústria. Com sua arquitetura aberta, o IBM PC criou o ecossistema de clones PC-compatíveis que domina até hoje.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC7yr8FCSw1Z7-Q_Em9yH4ubbGXnnu8Ck0w05ME3UIK6TF00YK1zQ4i1H6iAZwHoRpv9G1whzIrUDFHH63C-bbr9o94DQzqvfKUKQC1wsdDjgyNXcTMUzDZv75XX55ottmWg_N6ZHbQtjHqRgo_T3_bl9gBRiMA7WHJ2rgK9vlm8Tpw-ZJJ33lz7KYicpbepztna8-TfTmEHCE02RJ4Ja0g6Ea9wqOEebMYFF9LUjIc9nFsNhZS9B9LofSeYMvlOvpJj_OEnKOwx0qM',
  historyParagraphs: [
    'Lançado em 1981, o IBM PC 5150 foi a tentativa da gigante IBM de entrar no mercado crescente de computadores pessoais. Desenvolvido em apenas 12 meses por uma equipe de 12 engenheiros em Boca Raton, Flórida, o projeto foi mantido em sigilo e recebeu o codinome "Project Chess".',
    'Diferente da abordagem proprietária da IBM, o PC 5150 foi construído com componentes disponíveis no mercado (off-the-shelf), incluindo um processador Intel 8088, sistema operacional Microsoft MS-DOS e slots de expansão ISA. Esta arquitetura aberta permitiu que outras empresas fabricassem "clones" compatíveis.',
    'O IBM PC estabeleceu o padrão que domina a computação pessoal até hoje: a arquitetura x86 da Intel combinada com o sistema operacional da Microsoft. Seu legado é a plataforma Wintel que ainda alimenta a maioria dos computadores do mundo.',
  ],
  specs: [
    ItemSpec(label: 'Processador', value: 'Intel 8088 @ 4.77 MHz'),
    ItemSpec(label: 'RAM', value: '16 KB (expansível a 256 KB)'),
    ItemSpec(label: 'Armazenamento', value: '1 ou 2 Drives Disquete 5.25" 160 KB'),
    ItemSpec(label: 'SO', value: 'IBM BASIC / PC-DOS 1.0'),
    ItemSpec(label: 'Preço Lançamento', value: '\$1.565', highlight: true),
  ],
  funFacts: [
    FunFact(
      icon: Icons.architecture,
      title: 'Arquitetura Aberta',
      description:
          'O uso de componentes padrão de mercado permitiu que a Compaq e outras empresas criassem clones legais do IBM PC.',
    ),
    FunFact(
      icon: Icons.computer,
      title: 'Codificado como "Projeto Xadrez"',
      description:
          'O desenvolvimento foi mantido em segredo absoluto dentro da IBM sob o codinome "Project Chess".',
    ),
    FunFact(
      icon: Icons.music_note,
      title: 'Som de Arranque Icônico',
      description:
          'Uma das primeiras coisas que os usuários ouviam ao ligar o IBM PC era o som característico do altifalante interno durante o POST.',
    ),
  ],
  hotspotDetail:
      'O IBM PC 5150 original vinha com apenas 16 KB de RAM — menos do que uma imagem JPEG moderna.',
);

// ─── All samples ────────────────────────────────────────────────────────────

const allSampleItems = [
  macintosh128k,
  altair8800,
  osborne1,
  commodorePET,
  ibmPC5150,
];
