# RELATÓRIO DE ESTÁGIO SUPERVISIONADO

**Estagiário:** Ítalo  
**Empresa / Concedente:** Prefeitura Municipal de Cosmópolis – Secretaria Municipal de Saúde (Departamento de Tecnologia da Informação / Desenvolvimento e Sustentação de Sistemas)  
**Parcerias / Convênios:** CISMETRO (Consórcio Intermunicipal de Saúde da Região Metropolitana de Campinas)  
**Área / Curso:** Tecnologia em Análise e Desenvolvimento de Sistemas / Ciência da Computação / Engenharia de Software  

---

## 1. INTRODUÇÃO

### 1.1 Histórico da Organização e Caracterização do Segmento de Mercado
A **Prefeitura Municipal de Cosmópolis**, pessoa jurídica de direito público interno, tem por atribuição precípua a gestão administrativa e a prestação continuada de serviços essenciais à população de Cosmópolis, município situado na Região Metropolitana de Campinas (SP). 

O estágio curricular supervisionado foi realizado no **Departamento de Tecnologia da Informação (TI)**, atuando diretamente no desenvolvimento, suporte e modernização de soluções tecnológicas voltadas à **Secretaria Municipal de Saúde (SMS)**, aos seus setores correlatos (como a **Saúde e Bem-Estar Animal** e o **Almoxarifado Municipal**) e aos órgãos parceiros consorciados, em especial o **CISMETRO** (Consórcio Intermunicipal de Saúde da Região Metropolitana de Campinas).

O segmento compreende a administração pública municipal e a gestão integrada de saúde e suprimentos, onde as tecnologias da informação desempenham papel crítico na otimização de recursos, no controle de estoque de insumos, na rastreabilidade de medicamentos, na extinção do uso de papel e na observância das diretrizes do SUS e da Lei Geral de Proteção de Dados (LGPD).

### 1.2 Missão e Visão
- **Missão:** Desenvolver, manter e modernizar sistemas computacionais que otimizem os serviços públicos municipais, promovendo agilidade, transparência, integridade das informações e qualidade de vida à comunidade.
- **Visão:** Ser referência regional em inovação e governança digital no setor público, integrando com eficiência os setores administrativos, unidades de saúde, consórcios intermunicipais e cidadãos.

### 1.3 Principais Atividades, Produtos e Serviços Desenvolvidos
A equipe de desenvolvimento atua em todas as fases do ciclo de vida das aplicações municipais. Entre as principais soluções desenvolvidas, refatoradas e mantidas durante o período de estágio, destacam-se:
1. **Sistema de Envio de Atestados ao RH (CISMETRO):** Aplicação web desenvolvida em Python para envio digital, validação e controle de atestados médicos dos servidores consorciados.
2. **Sistema de Almoxarifado Municipal (v2.0 em Python):** Nova plataforma desenvolvida para substituir o sistema legado, com migração integral de dados históricos, controle de entradas/saídas e estoque mínimo.
3. **Sistema VetCare (Saúde e Bem-Estar Animal):** Plataforma para gestão clínica veterinária, cadastros de animais, agendamento de castrações e campanhas municipais de vacinação.
4. **Sistema da Farmácia Municipal (Farmácia Cosmópolis):** Sistema de gestão de estoque, rastreabilidade de medicamentos estratégicos, notas fiscais e dispensação a pacientes.
5. **Sistema Sis Tram Saúde & Portal PSE:** Plataformas para tramitação eletrônica de processos sanitários e gestão do Programa Saúde na Escola com assinatura digital e QR Code.
6. **Sistema de Coleta de Dados e Ouvidoria da Saúde:** Aplicação para avaliação de atendimento pelos munícipes acoplada a cartazes com QR Codes dinâmicos e painéis analíticos.

---

## 2. OBJETIVOS DO ESTÁGIO

### 2.1 Atividades Previstas no TCE (Termo de Compromisso de Estágio)
As atividades estabelecidas no Termo de Compromisso de Estágio contemplaram a participação em todas as fases da engenharia de software no departamento:
- Coletar, analisar e documentar requisitos de software em conjunto com servidores de diversos setores municipais;
- Projetar e codificar novas soluções computacionais sob medida (utilizando linguagens como Python e padrões web);
- Realizar refatoração e migração de sistemas legados, incluindo exportação, transformação e importação de bases de dados;
- Executar manutenção corretiva (depuração de bugs) e evolutiva (novas funcionalidades e regras de negócio);
- Realizar rotinas formais de teste, homologação e deploy (publicação em produção);
- Apoiar na modelagem de bancos de dados relacionais, criação de rotinas de cópias de segurança (backup) e suporte técnico especializado aos usuários.

### 2.2 Relação das Atividades com o PPC (Projeto Pedagógico do Curso)
A vivência prática no setor de TI consolidou a articulação entre o perfil de egresso definido no Projeto Pedagógico do Curso (PPC) e os desafios reais do mercado de trabalho. As atividades integraram diretamente os conteúdos das disciplinas curriculares:
- **Engenharia de Software:** Análise e levantamento de requisitos, arquitetura de software, refatoração de sistemas legados, versionamento com Git e procedimentos de deploy.
- **Desenvolvimento Web:** Desenvolvimento full-stack, manipulação segura de uploads, responsividade para dispositivos móveis e consumo de APIs/rotas dinâmicas.
- **Banco de Dados:** Modelagem relacional, scripts de extração/carga de dados (ETL para migração do almoxarifado), consultas analíticas e automação de backups (`mysqldump`).
- **Programação Orientada a Objetos (POO):** Modularização de serviços em Python, reuso de código, separação de responsabilidades e controle de regras de negócio.
- **Estrutura de Dados:** Organização, paginação, agrupamento e filtragem de grandes volumes de registros de estoque, movimentações e atestados.
- **Sistemas Operacionais II:** Automação de rotinas em terminal (PowerShell/Batch), configuração de servidores web/banco de dados locais (XAMPP/Apache/MySQL) e agendamento de tarefas do sistema operacional.

---

## 3. ATIVIDADES DESENVOLVIDAS

> *Em todas as aplicações atendidas, a atuação compreendeu o ciclo integral de software: levantamento de requisitos, desenvolvimento, migração de dados, manutenção corretiva e evolutiva, deploy em ambiente de produção e coleta/análise de dados de uso.*

### 3.1. Desenvolvimento do Sistema de Envio de Atestados ao RH (CISMETRO)
- **O que foi realizado:** Desenvolvimento completo (do levantamento inicial até a publicação) de uma aplicação web em Python para o envio eletrônico de fotos e documentos de atestados médicos dos colaboradores ao setor de Recursos Humanos do consórcio CISMETRO. O trabalho envolveu coleta de requisitos com o RH, codificação full-stack, validação de arquivos no upload, testes de usabilidade, deploy no servidor e suporte contínuo aos servidores.
- **Por que foi realizado:** Os atestados físicos em papel sofriam constantes atrasos de entrega e riscos de extravio no deslocamento entre as unidades municipais e a sede do consórcio em Campinas. Havia necessidade de um canal digital ágil e seguro para garantir o envio imediato no primeiro dia de afastamento do profissional.
- **Como foi realizado:** Utilizou-se linguagem **Python** (framework web), com validação rigorosa de formato e tamanho de imagens, banco de dados para indexação dos envios, interface responsiva adaptada para envio direto pela câmera de smartphones, deploy no servidor de produção e monitoramento das taxas de envio.
- **O que agregou de conhecimento:** Prática completa do ciclo de vida em *Engenharia de Software* (especificação, codificação, deploy e sustentação) e *Desenvolvimento Web* (gerenciamento seguro de uploads de arquivos e responsividade).

### 3.2. Refatoração, Criação e Migração do Sistema de Almoxarifado Municipal (v2.0 em Python)
- **O que foi realizado:** Refatoração e modernização integral do sistema de Almoxarifado Municipal. A partir de um sistema legado existente que apresentava limitações operacionais, foi desenvolvida uma nova aplicação em Python, planejado e executado o processo de exportação/migração dos dados históricos do sistema antigo para a nova base de dados, além da realização de deploy, manutenção corretiva/evolutiva e coleta de dados de uso com os operadores.
- **Por que foi realizado:** O sistema legado de almoxarifado era instável, possuía arquitetura defasada e dificultava auditorias de estoque. Era essencial modernizar a ferramenta para garantir o controle rigoroso de entradas, saídas, transferências e estoque mínimo de materiais de expediente e insumos da prefeitura, preservando todo o histórico acumulado de movimentações.
- **Como foi realizado:** Desenvolvimento full-stack em **Python**; elaboração de rotinas e scripts de extração, transformação e carga (ETL) para exportar os dados legados e inseri-los com integridade no novo esquema relacional; homologação prática junto à equipe do almoxarifado; deploy em produção e implementação de melhorias contínuas pós-lançamento.
- **O que agregou de conhecimento:** Conhecimento aprofundado em técnicas de refatoração e modernização de legados (*Engenharia de Software*), além de modelagem relacional, integridade referencial e migração de grandes volumes de registros (*Banco de Dados*).

### 3.3. Levantamento de Requisitos, Manutenção e Melhorias no Sistema VetCare (Saúde Animal)
- **O que foi realizado:** Atuação continuada no sistema VetCare (aplicação voltada à saúde e bem-estar animal do município), contemplando a coleta de requisitos diretamente com os médicos veterinários e equipe técnica, manutenção de rotinas com defeito, desenvolvimento de novas melhorias solicitadas, deploy de atualizações e suporte aos operadores.
- **Por que foi realizado:** O setor de controle de zoonoses e atendimento veterinário necessitava adequar o sistema às demandas cotidianas de triagem clínica, controle de castrações, histórico de vacinas e emissão de laudos de procedimentos.
- **Como foi realizado:** Condução de reuniões para identificação de gargalos operacionais, depuração e correção de regras de negócio em código existente, testes de funcionalidade em ambiente local, deploy no ambiente dos servidores e acompanhamento do uso.
- **O que agregou de conhecimento:** Fixação das competências de engenharia de requisitos e manutenção de software (*Engenharia de Software*), além de adaptação de fluxos e consultas em *Banco de Dados*.

### 3.4. Desenvolvimento, Manutenção e Sustentação do Sistema da Farmácia Municipal
- **O que foi realizado:** Participação no ciclo completo de sustentação da aplicação da Farmácia Municipal: desenvolvimento de rotinas de rastreamento de medicamentos estratégicos, correção de falhas de validação em formulários (eliminando bloqueios de carregamento), criação de permissões restritas por perfil (perfil Auditor), deploy de novas versões e coleta/análise de dados de movimentação de medicamentos.
- **Por que foi realizado:** A farmácia pública opera continuamente e precisa prestar contas de estoques essenciais e de alto custo. Instabilidades no sistema prejudicavam o atendimento aos munícipes e a conferência de notas fiscais.
- **Como foi realizado:** Programação em Python integrada ao banco de dados MySQL, refatoração de regras de validação no back-end, realização de deploys periódicos e monitoramento contínuo da estabilidade das rotas.
- **O que agregou de conhecimento:** Prática em modelagem relacional e integridade de *Banco de Dados*, além de disciplina de manutenção corretiva e deploy contínuo em aplicações de missão crítica (*Engenharia de Software*).

### 3.5. Manutenção, Evolução de Recursos e Deploy no Sis Tram Saúde e Portal PSE
- **O que foi realizado:** Desenvolvimento de novos módulos como o de assinatura digital com autenticação por QR Code no Portal do Programa Saúde na Escola (PSE), manutenção contínua em fluxos de tramitação de processos sanitários, deploy de atualizações e suporte aos servidores da saúde e da educação.
- **Por que foi realizado:** Desburocratizar o processo de autorização médica e odontológica nas escolas da rede municipal, eliminando o extravio de termos físicos em papel e conferindo validade jurídica e agilidade ao consentimento dos pais.
- **Como foi realizado:** Construção de rotas de autenticação, renderização dinâmica de selos digitais autenticados com QR Code, testes de usabilidade, deploy em produção e acompanhamento da taxa de adesão dos munícipes.
- **O que agregou de conhecimento:** Aplicação de padrões de controle de acesso (RBAC) e arquitetura de software (*POO* e *Engenharia de Software*), com ênfase em segurança da informação no *Desenvolvimento Web*.

### 3.6. Desenvolvimento da Plataforma de Coleta de Dados e Ouvidoria da Saúde
- **O que foi realizado:** Desenvolvimento completo da plataforma web de pesquisa de satisfação do munícipe (questionário online), geração dinâmica de cartazes com QR Codes parametrizados por unidade (UBSs e CMSC), controle de métricas de conversão (scans vs. respostas) e deploy dos painéis analíticos para a gestão da saúde.
- **Por que foi realizado:** Fornecer à Secretaria de Saúde indicadores reais e contínuos sobre a percepção da população a respeito do atendimento recebido, orientando melhorias estruturais e operacionais nas unidades.
- **Como foi realizado:** Front-end responsivo, lógica de controle de sessão para impedir duplicidade de respostas, rotas de agregação estatística, deploy do serviço web e suporte à equipe de comunicação.
- **O que agregou de conhecimento:** Técnicas de coleta, tratamento e visualização de dados (*Estrutura de Dados* e *Banco de Dados*), além de usabilidade e interface com o usuário (*UX/UI* em *Desenvolvimento Web*).

### 3.7. Automação de Rotinas, Manutenção de Infraestrutura e Gestão de Backups
- **O que foi realizado:** Criação, deploy e monitoramento de scripts de automação em PowerShell e Batch para realização diária de cópias de segurança (backups lógicos completos via `mysqldump`) das bases de dados municipais (farmácia, almoxarifado e sistemas integrados), além de suporte à infraestrutura de servidores locais (XAMPP/Apache/MySQL).
- **Por que foi realizado:** Blindar os dados públicos essenciais do município contra perdas por falhas de hardware, picos de energia ou corrupção de arquivos, garantindo conformidade com normas de segurança da informação.
- **Como foi realizado:** Elaboração de scripts com carimbo automático de data/hora, agendamento de tarefas no Windows Server, testes periódicos de restauração (restore) em ambiente isolado e documentação de contingência.
- **O que agregou de conhecimento:** Conhecimentos práticos de shell scripting e agendamento de tarefas da disciplina de *Sistemas Operacionais II*, articulados a políticas de governança e segurança em *Banco de Dados*.

---

## 4. CONSIDERAÇÕES FINAIS

O estágio supervisionado realizado no Departamento de TI da Prefeitura Municipal de Cosmópolis foi decisivo para a consolidação da formação acadêmica e o amadurecimento profissional em Tecnologia da Informação.

Ao longo do período, a atuação caracterizou-se pela versatilidade e pelo envolvimento generalista em todo o ciclo de vida dos softwares: desde o levantamento e coleta de requisitos junto a usuários de diferentes setores (RH do CISMETRO, equipe veterinária do VetCare, farmacêuticos e gestores de saúde), passando pela codificação em Python, refatoração de sistemas legados (como a modernização e migração do Almoxarifado), até a execução de testes, deploys em produção e suporte técnico diário.

Essa experiência prática evidenciou a importância da integração interdisciplinar entre Engenharia de Software, Desenvolvimento Web, Banco de Dados e Sistemas Operacionais. Além dos ganhos técnicos, o estágio desenvolveu competências fundamentais de comunicação interpessoal, capacidade analítica para solucionar incidentes sob pressão e uma profunda consciência do impacto social da tecnologia no serviço público.

Conclui-se, portanto, que todas as metas estipuladas no Termo de Compromisso de Estágio e as competências previstas no Projeto Pedagógico do Curso foram amplamente atendidas, qualificando de forma sólida o estagiário para os desafios do mercado de trabalho.

---

## REFERÊNCIAS BIBLIOGRÁFICAS

- DATE, C. J. **Introdução a Sistemas de Bancos de Dados**. 8. ed. Rio de Janeiro: Elsevier, 2004.
- ELMASRI, Ramez; NAVATHE, Shamkant B. **Sistemas de Banco de Dados**. 6. ed. São Paulo: Pearson Addison Wesley, 2011.
- FLANAGAN, David. **JavaScript: O Guia Definitivo**. 6. ed. Porto Alegre: Bookman, 2013.
- PRESSMAN, Roger S.; MAXIM, Bruce R. **Engenharia de Software: Uma Abordagem Profissional**. 8. ed. Porto Alegre: McGraw-Hill, 2016.
- SILBERSCHATZ, Abraham; GALVIN, Peter Baer; GAGNE, Greg. **Fundamentos de Sistemas Operacionais**. 9. ed. Rio de Janeiro: LTC, 2015.
- SOMMERVILLE, Ian. **Engenharia de Software**. 10. ed. São Paulo: Pearson Education do Brasil, 2019.
- PYTHON SOFTWARE FOUNDATION. **Python 3 Documentation**. Disponível em: <https://docs.python.org/3/>. Acesso em: 09 nov. 2026.
- ORACLE CORPORATION. **MySQL 8.0 Reference Manual**. Disponível em: <https://dev.mysql.com/doc/refman/8.0/en/>. Acesso em: 09 nov. 2026.
