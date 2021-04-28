/* Script realizado por Felipe Neves e Filipi Nudi para o Projeto de Avaliacao da P2 Parte 1
Foram criados os tipos e tabelas tipadas para Pacientes, Funcionarios, Vacinas e no caso de Unidade de Atendimento,
foi criado um tipo generico para unidade, que serve como tipo abstrato para os tipos posto de saude e hospital que
herdam do tipo unidade, dessa forma a modelagem proposta na P1 pode ser mais aproximada com as tecnicas de bancos
objetos relacionais. As tabelas de atendimento e de carteira de vacinacao tambem foram aninhadas dentro da tabela
de pacientes, como solicitado. */

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

/* Tipo da vacina */
DROP TYPE tipovacina FORCE;
CREATE OR REPLACE TYPE tipovacina AS OBJECT(
    tipo_vacina VARCHAR2(15),
    lote_vacina INTEGER,
    qntd_vacina SMALLINT,
    dt_validade_vacina DATE,
    info_adicionais_vacina VARCHAR2(300),
    mes_campanha_vacina CHAR(3),
    registro_vacina VARCHAR2(10),
    doses_recomendadas SMALLINT
) FINAL;

/* Tabela de vacinas */
DROP TABLE vacina CASCADE CONSTRAINTS;
CREATE TABLE vacina OF tipovacina(
    tipo_vacina NOT NULL,
    lote_vacina NOT NULL,
    qntd_vacina NOT NULL,
    dt_validade_vacina NOT NULL,
    CHECK(mes_campanha_vacina IN ('JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ')),
    registro_vacina NOT NULL,
    doses_recomendadas NOT NULL,
    CHECK(doses_recomendadas >= 0)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Tipo de telefone */
DROP TYPE tipofone FORCE;
CREATE OR REPLACE TYPE tipofone AS VARRAY(3) OF VARCHAR2(9);

/* Tipo de endereco */
DROP TYPE tipoendereco FORCE;
CREATE OR REPLACE TYPE tipoendereco AS OBJECT(
    tipo_logradouro CHAR(12),
    logradouro VARCHAR2(40),
    numero SMALLINT,
    complemento CHAR(10),
    bairro VARCHAR2(25),
    regiao VARCHAR2(30),
    cidade VARCHAR2(30),
    uf CHAR(2),
    email VARCHAR2(32),
    telefone tipofone
) FINAL;

/* Tipo funcionario - unidade pertencente eh colocada adiante */
DROP TYPE tipofuncionario FORCE;
CREATE OR REPLACE TYPE tipofuncionario AS OBJECT(
    num_funcionario INTEGER,
    nome_funcionario VARCHAR2(50),
    endereco tipoendereco,
    sexo_funcionario CHAR(1),
    dt_nascimento_func DATE,
    dt_admissao DATE,
    cargo VARCHAR2(20)
) FINAL;

/* Tipo horario */
DROP TYPE tipohorario FORCE;
CREATE OR REPLACE TYPE tipohorario AS OBJECT(
    dia CHAR(3),
    hora_inicio CHAR(5),
    hora_fim CHAR(5),
    turno VARCHAR2(10)
)FINAL;

/* Tipo escala */
DROP TYPE tipoescala FORCE;
CREATE OR REPLACE TYPE tipoescala AS OBJECT(
    data_inicio DATE,
    data_fim DATE,
    regime VARCHAR2(10),
    horario tipohorario,
    funcionario REF tipofuncionario
) FINAL;

/* Tabela de escalas */
DROP TABLE escala CASCADE CONSTRAINS;
CREATE TABLE escala OF tipoescala(
	data_inicio NOT NULL,
	data_fim NOT NULL,
	regime NOT NULL,
	funcionario NOT NULL
)OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Tipo unidade - generalista */
DROP TYPE tipounidade FORCE;
CREATE OR REPLACE TYPE tipounidade AS OBJECT(
    nome_unidade VARCHAR2(40),
    endereco tipoendereco,
    responsavel REF tipofuncionario
) NOT FINAL;

/* Tipo posto - filho de tipounidade */
DROP TYPE tipoposto FORCE;
CREATE OR REPLACE TYPE tipoposto UNDER tipounidade(
    desc_vacinas VARCHAR2(50),
    atend_pres VARCHAR2(50)
) FINAL;

/* Tipo hospital - filho de tipounidade */
DROP TYPE tipohospital FORCE;
CREATE OR REPLACE TYPE tipohospital UNDER tipounidade(
    num_leitos SMALLINT,
    num_uti SMALLINT
) FINAL;

/* Tabela de postos de saude */
DROP TABLE posto CASCADE CONSTRAINTS;
CREATE TABLE posto OF tipoposto(
    nome_unidade NOT NULL,
    responsavel NOT NULL,
    atend_pres NOT NULL,
    desc_vacinas NOT NULL
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Tabela de hospitais */
DROP TABLE hospital CASCADE CONSTRAINTS;
CREATE TABLE hospital OF tipohospital(
    nome_unidade NOT NULL,
    responsavel NOT NULL,
    num_leitos NOT NULL,
    num_uti NOT NULL
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Adicionando unidade ao funcionario */
ALTER TYPE tipofuncionario
ADD ATTRIBUTE unidade REF tipounidade CASCADE;

/* Tabela de funcionarios */
DROP TABLE funcionario CASCADE CONSTRAINTS;
CREATE TABLE funcionario OF tipofuncionario(
    num_funcionario NOT NULL UNIQUE,
    nome_funcionario NOT NULL,
    CHECK(sexo_funcionario IN ('M','F')),
    sexo_funcionario NOT NULL,
    dt_nascimento_func NOT NULL,
    dt_admissao NOT NULL,
    cargo NOT NULL
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Tipo medico */
DROP TYPE tipomedico FORCE;
CREATE OR REPLACE TYPE tipomedico AS OBJECT(
    especialidade VARCHAR2(15),
    crm INTEGER,
    funcionario REF tipofuncionario
) FINAL;

/* Tabela de medicos */
DROP TABLE medico CASCADE CONSTRAINTS;
CREATE TABLE medico OF tipomedico(
    especialidade NOT NULL,
    crm NOT NULL UNIQUE
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

/* Tipo de atendimento */
DROP TYPE tipoatendimento FORCE;
CREATE OR REPLACE TYPE tipoatendimento AS OBJECT(
    num_atendimento INTEGER,
    data_hora_atend TIMESTAMP,
    motivo VARCHAR2(20),
    diagnostico VARCHAR2(100),
    tipo_atendimento VARCHAR2(20),
    situacao VARCHAR2(20),
    observacao VARCHAR2(50),
    data_hora_agendad TIMESTAMP,
    cpf_acompanhente INTEGER,
    nome_responsavel VARCHAR2(50),
    agendado_por VARCHAR2(50),
    medico_responsavel REF tipomedico,
    atendente REF tipofuncionario,
    unidade_atendimento REF tipounidade
)FINAL;

/* Tipo de tabelas de atendimentos */
DROP TYPE tab_atendimento FORCE;
CREATE OR REPLACE TYPE tab_atendimento AS TABLE OF tipoatendimento;

/* Tipo vacinacao */
DROP TYPE tipovacinacao FORCE;
CREATE OR REPLACE TYPE tipovacinacao AS OBJECT(
    num_atendimento INTEGER,
    vacina REF tipovacina,
    dose_recebida SMALLINT,
    doses_faltantes SMALLINT
)FINAL;

/* Tabela de vacinas */
DROP TYPE tab_carteira_vacinao FORCE;
CREATE OR REPLACE TYPE tab_carteira_vacinacao AS TABLE OF tipovacinacao;

/* Tipo paciente */
DROP TYPE tipopaciente FORCE;
CREATE OR REPLACE TYPE tipopaciente AS OBJECT(
    nome_paciente VARCHAR2(50),
    endereco tipoendereco,
    num_rg CHAR(9),
    num_cpf CHAR(11),
    num_sus INTEGER,
    sexo_paciente CHAR(1),
    dt_nascimento_paciente DATE,
    login VARCHAR2(20),
    senha VARCHAR2(20),
    carteira_vacinas tab_carteira_vacinacao,
    atendimentos_realizados tab_atendimento
)FINAL;

/* Tabela de pacientes */
DROP TABLE paciente CASCADE CONSTRAINTS;
CREATE TABLE paciente OF tipopaciente(
    nome_paciente NOT NULL,
    num_rg NOT NULL UNIQUE,
    num_cpf NOT NULL UNIQUE,
    num_sus NOT NULL UNIQUE,
    sexo_paciente NOT NULL,
    CHECK(sexo_paciente IN ('M','F')),
    dt_nascimento_paciente NOT NULL,
    login NOT NULL UNIQUE,
    senha NOT NULL
) OBJECT IDENTIFIER IS SYSTEM GENERATED
NESTED TABLE carteira_vacinas STORE AS tabela_vacinas_tomadas RETURN AS LOCATOR
NESTED TABLE atendimentos_realizados STORE AS tabela_atendimentos_feitos RETURN AS LOCATOR;

/*-----------------------------------------------------------------------------------------------------------------------
 PARTE 2 ----------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------*/

-- Exercicio 8 -- Populando as tabelas

-- Populando a tabela vacina
INSERT INTO vacina VALUES ('Triplice Viral',105,200,'01/01/2021','Prevencao de rubeola, sarampo e caxumba','OUT','ANVI75346',3);
INSERT INTO vacina VALUES ('Anti tetanica',140,150,'01/06/2021','Aplicacao difteria e coqueluxe em conjunto',NULL,'ANVI741X',3);
INSERT INTO vacina VALUES ('Gripe',47455,500,'31/12/2021',NULL,'JUN','ANVI6482V',1);
INSERT INTO vacina VALUES ('HPV',14571,100,'01/07/2021','Aplicar em meninas de 9 a 14 anos e meninos de 11 a 14 anos', NULL,'ANVI098T',2);

-- Populando a tabela funcionario (atualizacao das unidades de trabalho deles mais a frente)
INSERT INTO funcionario VALUES (100,'Francisco de Paula Araujo',
    tipoendereco('Rua', 'Guamare','145',NULL,'Jardim Lenize','Leste','Guarulhos','SP','araujodepaula@gmail.com',
    tipofone('99717364','974834975')),'M','05/04/1984','14/06/2017','medico',NULL);

INSERT INTO funcionario VALUES (110,'Luana de Souza Teixeira',
    tipoendereco('Avenida','Higienopolis','1023','Apto 74','Higienopolis','Oeste','Sao Paulo','SP','luteixeira@outlook.com',
    tipofone('64283726','975641273','47561457')),'F','08/05/1974','25/08/2008','coordenadora',NULL);

INSERT INTO funcionario VALUES (115,'Rodrigo Alvarez Silva',
    tipoendereco('Rua','Frei Joao','403',NULL,'Ipiranga','Sul','Sao Paulo','SP','rodalvarez@terra.com.br',
    tipofone('974513579')),'M','19/11/1991','23/10/2019','medico',NULL);

INSERT INTO funcionario VALUES (120,'Beatriz Goes Schwartz',
    tipoendereco('Av.','Paulista','446','Apto 26','Bela Vista','Centro','Sao Paulo','SP','schwartzbea@ig.com.br',
    tipofone('47516347','975942319')),'F','20/07/1986','21/09/2013','medica',NULL);

INSERT INTO funcionario VALUES (125,'Leandro Tamashiru Reis',
    tipoendereco('Rua','Vilela','104',NULL,'Tatuape','Leste','Sao Paulo','SP','leandroreis@gmail.com',
    tipofone('941523625','975395184')),'M','14/07/1998','05/02/2019','atendente',NULL);

INSERT INTO funcionario VALUES(130,'Rogeria Gomes Carvalho',
    tipoendereco('Rua','Franscico Morato','96','Apto 136','Tatuape','Leste','Sao Paulo','SP','rogeriagomes@outlook.com',
    tipofone('945211463','14965135')),'F','20/04/1978','13/03/2010','coordenadora',NULL);

-- Populando a tabela hospital
INSERT INTO hospital VALUES ('Hospital Samaritano',
    tipoendereco('Avenida','Brigadeiro Luis Antonio','1895',NULL,'Bela Vista','Centro','Sao Paulo','SP','samaritanosac@samaritano.com.br',
    tipofone('12349876','54322345')), (SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 110),600,200);

INSERT INTO hospital VALUES ('Hospital Beneficiencia Portuguesa',
    tipoendereco('Rua', 'Maestro Cardim', '769', NULL,'Paraiso','Sul','Sao Paulo','SP','sacbfhospital@bfhospital.com.br',
    tipofone('67894321','22334455')),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 130),1050,350);

-- Populando a tabela posto
INSERT INTO posto VALUES ('UBS Belenzinho',
    tipoendereco('Av.','Celso Garcia','1749',NULL,'Belenzinho','Leste','Sao Paulo','SP','ubsbelenzinho@saude.gov.sp.br',
    tipofone('31827642','14369743')),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 115),'Triplice Viral','Vacinacao, Pronto atendimento');

INSERT INTO posto VALUES ('UBS Dr. Antonio da Silveira e Oliveira',
    tipoendereco('Rua','Acurui','720',NULL,'Vila Formosa','Leste','Sao Paulo','SP', 'ubsvilaformosa1@saude.gov.sp.br',
    tipofone('24672831','34796341')),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 110),'Gripe e HPV','Vacinacao, pronto atendimento e consultas');

-- Atualizando as unidades de trabalho dos funcionarios
UPDATE funcionario f
SET f.unidade = (SELECT REF(h) FROM hospital h WHERE UPPER(h.nome_unidade) LIKE '%SAMARITANO%')
WHERE f.num_funcionario = 110;

UPDATE funcionario f
SET f.unidade = (SELECT REF(h) FROM hospital h WHERE UPPER(h.nome_unidade) LIKE '%BENEFICIENCIA%')
WHERE f.num_funcionario = 130;

UPDATE funcionario f
SET f.unidade = (SELECT REF(p) FROM posto p WHERE UPPER(p.nome_unidade) LIKE '%BELENZINHO%')
WHERE f.num_funcionario = 115;

UPDATE funcionario f
SET f.unidade = (SELECT REF(p) FROM posto p WHERE UPPER(p.nome_unidade) LIKE '%ANTONIO DA SILVEIRA%')
WHERE f.num_funcionario = 125;

UPDATE funcionario f
SET f.unidade = (SELECT REF(h) FROM hospital h WHERE UPPER(h.nome_unidade) LIKE '%SAMARITANO%')
WHERE f.num_funcionario = 100;

UPDATE funcionario f
SET f.unidade = (SELECT REF(h) FROM hospital h WHERE UPPER(h.nome_unidade) LIKE '%BENEFICIENCIA%')
WHERE f.num_funcionario = 120;

-- Populando a tabela medico
INSERT INTO medico VALUES ('Hematologia',6824593,(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 100));
INSERT INTO medico VALUES ('Cardiologia',3954286,(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 115));
INSERT INTO medico VALUES ('Reumatologista',9173284,(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 120));

-- Populando a tabela de escalas
INSERT INTO escala VALUES (current_date,current_date + 14,'Interno',
    tipohorario('SEG','08:00','18:00','Integral'),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 100));

INSERT INTO escala VALUES (current_date - 7, current_date + 7, 'Remoto',
    tipohorario('QUA','08:00','12:00','Matutino'),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 115));

INSERT INTO escala VALUES (current_date - 14, current_date, 'Interno',
    tipohorario('QUI','13:00','18:00','Vespertino'),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 120));

INSERT INTO escala VALUES (current_date, current_date + 7, 'Interno',
    tipohorario('TER','08:00','14:00','6 horas'),(SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 125));

-- Populando a tabela paciente (atendimentos e vacinas serao colocados adiante)
INSERT INTO paciente VALUES ('Gloria Estefania Alvarenga',
    tipoendereco('Rua', 'Filipe Camarao', '205','Apto 97','Tatuape','Leste','Sao Paulo','SP',NULL,tipofone('45971467','947935085')),
    '41597427X','35702674241',11334455,'F','03/06/1995',11334455,'senha1234',NULL,NULL);

INSERT INTO paciente VALUES ('Gabriel Sanchez Xavier',
    tipoendereco('Av','Conselheiro Carrao','1465','Apto 83','Vila Carrao','Leste','Sao Paulo','SP','gabxavier@gmail.com',tipofone('941632573','46791317')),
    '794658306','95167830775',22446677,'M','26/09/2001',22446677,'1234567890',NULL,NULL);

INSERT INTO paciente VALUES ('Giovana Albuquerque Lima',
    tipoendereco('Rua','Barao de Maua','146','Nos fundos','Centro','Centro','Guarulhos','SP','giolimalbu@ig.com.br',tipofone('995175328','93467128')),
    '167943280','34975128301',98761234,'F','16/04/2005',98761234,'password4321',NULL,NULL);

INSERT INTO paciente VALUES ('Fabricio dos Santos Reigado',
    tipoendereco('Rua','Canada','1069','Apto 114','Jardim Paulista','Sul','Sao Paulo','SP',NULL,tipofone('987452365','14279648','94137860')),
    '13467721Z','74383239202',64641331,'M','11/07/1998',646441331,'abc123',NULL,NULL);

-- Populando a tabela atendimento aninhada em paciente
UPDATE paciente p
SET p.atendimentos_realizados = tab_atendimento( tipoatendimento(1,'17/JAN/2020','Falta de ar','Depressao','Pronto Socorro','FINALIZADO',
    'Depressao ja em tratamento',NULL,'13256815341','Lucas Albuquerque Lima',NULL,(SELECT REF(m) FROM medico m WHERE m.funcionario.num_funcionario = 100),
    (SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 125), (SELECT REF(pos) FROM posto pos WHERE UPPER(pos.nome_unidade) LIKE '%ANTONIO DA SILVEIRA%')))
WHERE p.num_sus = 98761234;

UPDATE paciente p
SET p.atendimentos_realizados = tab_atendimento( tipoatendimento(2,current_date - 7, 'Atualizacao vacina', 'Vacina aplicada', 'Vacinacao','FINALIZADO',
    'Primeira aplicacao triplice viral',NULL,NULL,NULL,NULL,(SELECT REF(m) FROM medico m WHERE m.funcionario.num_funcionario = 115),
    (SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 115), (SELECT REF(pos) FROM posto pos WHERE UPPER(pos.nome_unidade) LIKE '%BELENZINHO%')))
WHERE p.num_sus = 64641331;

UPDATE paciente p
SET p.atendimentos_realizados = tab_atendimento( tipoatendimento(3, current_date + 1, 'Pneumonia grave', 'Infeccao por Sars Cov 2','Internacao','ANDAMENTO',
    'Paciente asmatica',NULL,'31250200799','Maria Alvarenga',NULL,(SELECT REF(m) FROM medico m WHERE m.funcionario.num_funcionario = 100),
    (SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 110), (SELECT REF(h) FROM hospital h WHERE UPPER(h.nome_unidade) LIKE '%SAMARITANO%')))
WHERE p.num_sus = 11334455;

UPDATE paciente p
SET p.atendimentos_realizados = tab_atendimento( tipoatendimento(4, current_date + 7, 'Atualizacao cart vac', 'Vacina Aplicada', 'Vacinacao', 'FINALIZADO',
    'Aplicacao segunda dose anti tetanica',NULL,NULL,NULL,NULL,(SELECT REF(m) FROM medico m WHERE m.funcionario.num_funcionario = 115),
    (SELECT REF(f) FROM funcionario f WHERE f.num_funcionario = 125),(SELECT REF(pos) FROM posto pos WHERE UPPER(pos.nome_unidade) LIKE '%BELENZINHO%')))
WHERE p.num_sus = 22446677;

-- Populando a tabela de carteira de vacinacao aninhada em paciente
UPDATE paciente p
SET p.carteira_vacinas = tab_carteira_vacinacao( tipovacinacao(2,(SELECT REF(v) FROM vacina v WHERE UPPER(v.tipo_vacina) LIKE '%TRIPLICE VIRAL%'),1,2))
WHERE p.num_sus = 64641331;

UPDATE paciente p
SET p.carteira_vacinas = tab_carteira_vacinacao( tipovacinacao(4,(SELECT REF(v) FROM vacina v WHERE UPPER(v.tipo_vacina) LIKE '%TETANICA%'),2,1))
WHERE p.num_sus = 22446677;

-- Exercicio 9 -- Realizando Consultas

-- i) Mostre o nome, logradouro, bairro e cidade, e numero dos telefones para os pacientes com menos de 60 anos cujo final de telefone seja numero par
SELECT p.nome_paciente AS paciente, p.endereco.tipo_logradouro || ' ' ||  p.endereco.logradouro AS Logradouro, p.endereco.bairro AS Bairro,
p.endereco.cidade AS Cidade, t.column_value AS Telefone
FROM paciente p, TABLE(p.endereco.telefone) t
WHERE ROUND(MONTHS_BETWEEN(current_date,p.dt_nascimento_paciente)/12,0) < 60 AND MOD(TO_NUMBER(t.column_value),2) = 0;

-- ii) Refaca a consulta 6-iii) Mostre a lista dos atendimentos diarios de uma determinada Unidade de Saude:
-- Tipo Atendimento, Numero, Data Hora Agendada, Paciente, Responsavel Paciente, Sexo, Fone, Email, Agendado por
SELECT ar.unidade_atendimento.nome_unidade AS "Unidade de Atendimento", EXTRACT(DAY FROM ar.data_hora_atend) AS Dia,
ar.tipo_atendimento AS "Tipo de atendimento", ar.num_atendimento AS "Numero do atendimento",
ar.data_hora_agendad AS "Data e hora do agendamento", p.nome_paciente AS Paciente, ar.cpf_acompanhente AS "CPF do acompanhante",
DECODE(p.sexo_paciente,'M','Masculino','F','Feminino') AS Sexo, fones.column_value AS Telefone, p.endereco.email AS Email,
ar.agendado_por AS "Agendado por"
FROM paciente p, TABLE(p.atendimentos_realizados) ar, TABLE(p.endereco.telefone) fones
ORDER BY EXTRACT(DAY FROM ar.data_hora_atend), ar.unidade_atendimento;

-- iii) Mostre todos os dados da carteira de vacinacao de pacientes que tomaram a vacina contra a febre amarela nos ultimos dois anos:
-- nome do paciente, nome do responsavel, data de vacinacao, numero do atendimento, nome da unidade de saude, regiao, distrito e fones da unidade
SELECT p.nome_paciente AS Paciente, cv.vacina.tipo_vacina AS Vacina, cv.dose_recebida AS "Dose recebida", cv.vacina.doses_recomendadas AS "Doses Recomendadas", cv.doses_faltantes AS "Doses Faltantes",
ar.medico_responsavel.funcionario.nome_funcionario AS "Medico Responsavel", ar.nome_responsavel AS "Responsavel Paciente",
ar.data_hora_atend AS "Data da vacinacao", cv.num_atendimento AS "Numero do atendimento", ar.unidade_atendimento.nome_unidade AS "Unidade de Atendimento",
ar.unidade_atendimento.endereco.regiao AS Regiao, ar.unidade_atendimento.endereco.bairro AS Distrito, t.column_value AS Telefones
FROM paciente p, TABLE(p.atendimentos_realizados) ar, TABLE(carteira_vacinas) cv, TABLE (ar.unidade_atendimento.endereco.telefone) t
WHERE ar.num_atendimento = cv.num_atendimento AND ar.data_hora_atend >= current_date - INTERVAL '2' YEAR
AND UPPER(cv.vacina.tipo_vacina) LIKE '%FEBRE AMARELA%';

-- iv) Mostre os dados de atendimento de internacao motivados por 'hipertensao' (pressao alta) em pacientes do sexo feminino com menos de
-- 35 anos: numero do atendimento, data e hora, nome da unidade de saude, tipo da unidade, medico responsavel, diagnostico, observacoes
SELECT ar.num_atendimento AS "Numero do atendimento", ar.data_hora_atend AS "Data e hora do atendimento",
ar.unidade_atendimento.nome_unidade AS "Unidade de Atendimento",
CASE
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%HOSPITAL%' THEN 'Hospital'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%UBS%' THEN 'Posto de saude: UBS'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%UPA%' THEN 'UPA'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%POSTO%' THEN 'Posto de saude'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%AMA%' THEN 'Posto de saude: AMA'
    ELSE 'Tipo nao cadastrado'
END AS "Tipo da unidade",
ar.medico_responsavel.funcionario.nome_funcionario AS "Medico responsavel", ar.diagnostico AS Diagnostico, ar.observacao AS Observacoes
FROM paciente p, TABLE(p.atendimentos_realizados) ar
WHERE ROUND(MONTHS_BETWEEN(current_date,p.dt_nascimento_paciente)/12,0) < 35 AND p.sexo_paciente = 'F'
AND UPPER(ar.tipo_atendimento) LIKE '%INTERNA__O%' AND (UPPER(ar.motivo) LIKE '%HIPERTENS_O%' OR UPPER(ar.motivo) LIKE '%PRESS_O ALTA%'
OR UPPER(ar.diagnostico) LIKE '%HIPERTENS_O%' OR UPPER(ar.diagnostico) LIKE '%PRESS_AO ALTA%');

-- v) Refaca a consulta 6-viii) Mostre os pacientes que realizam consultas mas nao tomam vacina:
-- Nome do paciente, idade e sexo
SELECT p.nome_paciente AS Paciente, ROUND(MONTHS_BETWEEN(current_date,p.dt_nascimento_paciente)/12,0) AS Idade,
DECODE(p.sexo_paciente,'M','Masculino','F','Feminino') AS Sexo
FROM paciente p
WHERE p.nome_paciente NOT IN (SELECT p.nome_paciente FROM paciente p, TABLE(p.atendimentos_realizados) ar WHERE UPPER(ar.tipo_atendimento) LIKE '%VACINA__O%');

-- vi) Refaca a consulta 6-x) Mostre os funcionarios da area de enfermagem (Enfermeiro, Auxiliar de Enfermagem, etc) que nunca aplicaram vacina:
-- Nome Funcionario, Cargo, data admissao, tempo de trabalho (quantidade de anos que trabalha na unidade de saude).
SELECT f.nome_funcionario AS Funcionario, f.cargo AS Cargo, f.dt_admissao AS "Data de Admissao",
ROUND(MONTHS_BETWEEN(current_date,f.dt_admissao)/12,0) || ' anos' AS "Tempo de trabalho"
FROM funcionario f
WHERE f.num_funcionario NOT IN (SELECT ar.atendente.num_funcionario FROM paciente p, TABLE(p.atendimentos_realizados) ar WHERE UPPER(ar.tipo_atendimento) LIKE '%VACINA__O%')
AND UPPER(f.cargo) LIKE '%ENFER%';

-- vii) Refaca a consulta 6-vii) Mostre um ranking das 10 unidades de saude que mais atenderam pacientes da "melhor idade" nos ultimos 120 dias
-- por motivo de "depressao": nome da unidade, tipo da unidade, quantidade, independente do tipo de atendimento
SELECT ar.unidade_atendimento.nome_unidade AS Unidade,
CASE
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%HOSPITAL%' THEN 'Hospital'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%UBS%' THEN 'Posto de saude: UBS'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%UPA%' THEN 'UPA'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%POSTO%' THEN 'Posto de saude'
    WHEN UPPER(ar.unidade_atendimento.nome_unidade) LIKE '%AMA%' THEN 'Posto de saude: AMA'
    ELSE 'Tipo nao cadastrado'
END AS "Tipo da unidade",
COUNT(*) AS "Atendimentos realizados"
FROM paciente p, TABLE(p.atendimentos_realizados) ar
WHERE ar.data_hora_atend BETWEEN current_date AND current_date - 120 AND ROUND(MONTHS_BETWEEN(current_date,p.dt_nascimento_paciente)/12,0) >= 60
AND UPPER(ar.motivo) LIKE '%DEPRESS_O%'
GROUP BY ar.unidade_atendimento.nome_unidade FETCH FIRST 10 ROWS ONLY;
