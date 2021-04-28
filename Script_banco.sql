/*** ESQUEMA DE RELACOES - SISTEMA DE SAUDE - PARTE 2
Unidade(cod_uni(PK),num_funcionario(FK),nome_uni,end_uni,fone_uni,zona_uni,dist_uni,tipo_uni(CK));
Hospital(cod_uni(PK)(FK),num_emergencia,num_uti);
Posto(cod_uni(PK)(FK),desc_vacinas,atend_pres);
Funcionario(num_funcionario(PK),cod_uni(FK),nome,end_funcionario,sexo(CK),dt_nascimento,fone,email);
Escala(cod_hora(PK)(FK),num_funcionario(PK)(FK),data_inicio(PK),data_fim,regime);
Horario(cod_hora(PK),dia,hora_inicio,hora_fim,turno);
Medico(num_funcionario(PK)(FK),especialidade,num_crm(U));
Consulta(num_atendimento(PK)(FK),num_funcionario(FK),diagnostico,procedimento);
Socorro(num_atendimento(PK)(FK),num_funcionario(FK),motivo,diagnostico,procedimento);
Internacao(num_atendimento(PK)(FK),num_funcionario(FK),motivo,quarto,leito);
Vacinacao(num_atendimento(PK)(FK),num_funcionario(FK),cod_vac(FK));
Atendimento(num_atendimento(PK),id_paciente(FK),num_funcionario(FK),cod_uni(FK),cod_tipo(FK),estado(CK),data_hora_atend);
Paciente(id_paciente(PK),nome_paciente,end_paciente,fone_paciente,num_rg(U),num_cpf(U),num_sus(U),email,sexo(CK),dt_nascimento,senha);
Atend_pres(cod_tipo(PK)(FK),cod_uni(PK)(FK));
Tipo(cod_tipo(PK),tipo,procedimento);
Vacina(cod_vac(PK),tipo,lote,qntd_vac,dt_validade,info_add,mes_campanha(CK),reg_vac);
Historico(num_atendimento(PK)(FK),id_paciente(FK),dt_vacinacao,local,data_anterior,info_add,dose);
***/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;

-- Tabela de Tipo de Atendimento
DROP TABLE tipo CASCADE CONSTRAINTS;
CREATE TABLE tipo(
    cod_tipo SMALLINT NOT NULL PRIMARY KEY,
    tipo VARCHAR2(20) NOT NULL,
    procedimento VARCHAR2(50) NOT NULL
);

-- Tabele de Horarios
DROP TABLE horario CASCADE CONSTRAINTS;
CREATE TABLE horario(
    cod_hora SMALLINT NOT NULL PRIMARY KEY,
    dia CHAR(3) NOT NULL,
    hora_inicio CHAR(5) NOT NULL,
    hora_fim CHAR(5) NOT NULL,
    turno VARCHAR2(10) NOT NULL
);

-- Tabela de Unidade de Atendimento
DROP TABLE unidade CASCADE CONSTRAINTS;
CREATE TABLE unidade(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    nome_uni VARCHAR2(40) NOT NULL,
    end_uni VARCHAR2(50) NOT NULL,
    fone_uni CHAR(8) NOT NULL,
    tipo_uni VARCHAR2(20) NOT NULL,
    zona_uni VARCHAR2(15) NOT NULL,
    dist_uni VARCHAR2(20) NOT NULL
);

ALTER TABLE unidade
ADD CONSTRAINT ck_tipo_unidade CHECK(tipo_uni IN ('HOSPITAL','UPA','AMA','UBS'));

ALTER TABLE unidade
ADD num_funcionario INTEGER;

-- Tabela funcionario
DROP TABLE funcionario CASCADE CONSTRAINTS;
CREATE TABLE funcionario(
    num_funcionario INTEGER NOT NULL PRIMARY KEY,
    nome VARCHAR2(40) NOT NULL,
    end_funcionario VARCHAR2(50) NOT NULL,
    sexo CHAR(1) NOT NULL,
    dt_nascimento DATE NOT NULL,
    fone CHAR(9) NOT NULL,
    email VARCHAR2(40),
    cod_uni INTEGER NOT NULL,
    FOREIGN KEY (cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE
);

ALTER TABLE funcionario
ADD CONSTRAINT ck_sexo_funcionario CHECK(sexo IN ('M','F'));

ALTER TABLE unidade
ADD CONSTRAINT fk_num_funcionario FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE;

-- Tabela Atendimentos Prestados
DROP TABLE atend_pres CASCADE CONSTRAINTS;
CREATE TABLE atend_pres(
    cod_uni INTEGER NOT NULL,
    cod_tipo SMALLINT NOT NULL,
    PRIMARY KEY (cod_uni,cod_tipo),
    FOREIGN KEY (cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE,
    FOREIGN KEY (cod_tipo) REFERENCES tipo(cod_tipo) ON DELETE CASCADE
);

-- Tabela de Hospital (Especilizacao da tabela Unidade de Atendimento)
DROP TABLE hospital CASCADE CONSTRAINTS;
CREATE TABLE hospital(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    num_emergencia SMALLINT NOT NULL,
    num_uti SMALLINT NOT NULL,
    FOREIGN KEY(cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE
);

-- Tabela de Posto de Saude (Especilizacao de Unidade de Atendimento)
DROP TABLE posto CASCADE CONSTRAINTS;
CREATE TABLE posto(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    desc_vacinas VARCHAR2(50) NOT NULL,
    atend_pres VARCHAR2(50) NOT NULL,
    FOREIGN KEY(cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE
);

-- Tabela de Medicos
DROP TABLE medico CASCADE CONSTRAINTS;
CREATE TABLE medico(
    num_funcionario INTEGER NOT NULL PRIMARY KEY,
    especialidade VARCHAR2(15) NOT NULL,
    num_crm INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE
);

-- Tabela de escala de horarios
DROP TABLE escala CASCADE CONSTRAINTS;
CREATE TABLE escala(
    cod_hora SMALLINT NOT NULL,
    num_funcionario INTEGER NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    regime VARCHAR2(10) NOT NULL,
    PRIMARY KEY(cod_hora,num_funcionario,data_inicio),
    FOREIGN KEY (cod_hora) REFERENCES horario(cod_hora) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE
);

-- Criacao da sequencia de codigos identificadores de pacientes
DROP SEQUENCE paciente_seq;
CREATE SEQUENCE paciente_seq START WITH 1 INCREMENT BY 1
MINVALUE 1 MAXVALUE 100000 NOCYCLE;

-- Tabela de Pacientes
DROP TABLE paciente CASCADE CONSTRAINTS;
CREATE TABLE paciente(
    id_paciente INTEGER NOT NULL PRIMARY KEY,
    nome_paciente VARCHAR2(40) NOT NULL,
    end_paciente VARCHAR2(50) NOT NULL,
    fone_paciente CHAR(9),
    num_rg CHAR(9) NOT NULL UNIQUE,
    num_cpf CHAR(11) NOT NULL UNIQUE,
    num_sus INTEGER NOT NULL UNIQUE,
    email VARCHAR2(40),
    dt_nascimento DATE NOT NULL
);

ALTER TABLE paciente
ADD sexo CHAR(1) NOT NULL;

ALTER TABLE paciente
ADD CONSTRAINT ck_sexo_paciente CHECK(sexo IN ('M','F'));

-- Criacao da sequencia de codigo identificadores de atendimentos
DROP SEQUENCE atendimento_seq;
CREATE SEQUENCE atendimento_seq START WITH 220000 INCREMENT BY 1
MINVALUE 220000 MAXVALUE 920000 NOCYCLE;

-- Tabela de atendimentos
DROP TABLE atendimento CASCADE CONSTRAINTS;
CREATE TABLE atendimento(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    estado VARCHAR2(9) NOT NULL,
    data_hora_atend TIMESTAMP NOT NULL,
    num_funcionario INTEGER NOT NULL,
    cod_uni INTEGER NOT NULL,
    cod_tipo SMALLINT NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE,
    FOREIGN KEY (cod_uni,cod_tipo) REFERENCES atend_pres(cod_uni,cod_tipo) ON DELETE CASCADE
);

-- Constraint check do estado do atendimento da tabela de atendimentos
ALTER TABLE atendimento
ADD CONSTRAINT ck_estado_atendimento CHECK (estado IN ('AGENDADA','ANDAMENTO','CANCELADA','CONCLUIDA'));

-- Tabela de Vacinacao
DROP TABLE vacinacao CASCADE CONSTRAINTS;
CREATE TABLE vacinacao(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    tipo VARCHAR2(20) NOT NULL,
    dose VARCHAR2(15) NOT NULL,
    num_funcionario INTEGER NOT NULL,
    data_anterior DATE,
    FOREIGN KEY (num_atendimento) REFERENCES atendimento(num_atendimento) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE
);

-- Tabela de Internacao
DROP TABLE internacao CASCADE CONSTRAINTS;
CREATE TABLE internacao(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    motivo VARCHAR2(20) NOT NULL,
    quarto SMALLINT NOT NULL,
    leito VARCHAR2(10) NOT NULL,
    num_funcionario INTEGER NOT NULL,
    FOREIGN KEY (num_atendimento) REFERENCES atendimento(num_atendimento) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES medico(num_funcionario) ON DELETE CASCADE
);

-- Tabela de pronto-atendimento
DROP TABLE socorro CASCADE CONSTRAINTS;
CREATE TABLE socorro(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    motivo VARCHAR2(20) NOT NULL,
    diagnostico VARCHAR2(40) NOT NULL,
    procedimento VARCHAR2(40) NOT NULL,
    num_funcionario INTEGER NOT NULL,
    FOREIGN KEY (num_atendimento) REFERENCES atendimento(num_atendimento) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES medico(num_funcionario) ON DELETE CASCADE
);

-- Tabela de consulta
DROP TABLE consulta CASCADE CONSTRAINTS;
CREATE TABLE consulta(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    diagnostico VARCHAR2(40) NOT NULL,
    procedimento VARCHAR2(40) NOT NULL,
    num_funcionario INTEGER NOT NULL,
    FOREIGN KEY (num_atendimento) REFERENCES atendimento(num_atendimento) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES medico(num_funcionario) ON DELETE CASCADE
);

--------------------------------------------------------------------------------------------------------------------------------
-- PARTE 2 ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

-- Exercicio 4

-- Adicionando o atributo senha a tabela Paciente
ALTER TABLE paciente
ADD senha VARCHAR2(20) NOT NULL;

-- Criando a tabela vacina
DROP TABLE vacina CASCADE CONSTRAINTS;
CREATE TABLE vacina(
    cod_vac INTEGER NOT NULL PRIMARY KEY,
    tipo VARCHAR2(15) NOT NULL,
    lote INTEGER NOT NULL,
    qntd_vac SMALLINT NOT NULL,
    dt_validade DATE NOT NULL,
    info_add VARCHAR2(300) NOT NULL,
    mes_campanha CHAR(3) NOT NULL,
    reg_vac VARCHAR2(10) NOT NULL
);

ALTER TABLE vacina
ADD CONSTRAINT ck_mes_vacina CHECK(mes_campanha IN('JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ'));

-- Removendo os atributos da tabela Vacinacao
ALTER TABLE vacinacao
DROP COLUMN tipo;

ALTER TABLE vacinacao
DROP COLUMN dose;

ALTER TABLE vacinacao
DROP COLUMN data_anterior;

ALTER TABLE vacinacao
ADD cod_vac INTEGER NOT NULL;

ALTER TABLE vacinacao
ADD CONSTRAINT fk_cod_vacina FOREIGN KEY (cod_vac) REFERENCES vacina(cod_vac) ON DELETE CASCADE;

-- Criando a tabela historico (carteira digital)
DROP TABLE historico CASCADE CONSTRAINTS;
CREATE TABLE historico(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    dt_vacinacao DATE NOT NULL,
    data_anterior DATE,
    info_add VARCHAR2(100),
    dose VARCHAR2(15) NOT NULL,
    FOREIGN KEY (num_atendimento) REFERENCES atendimento(num_atendimento) ON DELETE CASCADE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE
);

ALTER TABLE atendimento
ADD data_hora_agend DATE;

ALTER TABLE atendimento
ADD responsavel CHAR(11) NOT NULL;

ALTER TABLE atendimento
ADD agendado_por CHAR(40);

ALTER TABLE funcionario
ADD cargo VARCHAR2(20) NOT NULL;

ALTER TABLE funcionario
ADD data_admissao DATE NOT NULL;

ALTER TABLE vacinacao
ADD doses_rec INTEGER NOT NULL;

ALTER TABLE vacinacao
ADD doses_fat INTEGER NOT NULL;

ALTER TABLE vacinacao
ADD meses_prox INTEGER NOT NULL;

-- Exercicio 5 -- Populando as tabelas

-- Populando a tabela unidade
INSERT INTO unidade VALUES (100,'Hospital das Clinicas','Av. Dr. Eneas Carneiro', '23330000','HOSPITAL','Centro','Consolacao',NULL);
INSERT INTO funcionario VALUES (1,'Rodrigo Alvarez','Rua Cachoeiras 145','M',current_date - INTERVAL '42' YEAR, '941745623','rodalvarez@gmail.com',100,'Coordenador e Medico','17-SET-1994');
UPDATE unidade
SET num_funcionario = 1
WHERE cod_uni = 100;
INSERT INTO unidade VALUES (101, 'UPA Agua Clara','Avenida Campo Belo, 741', '41798546','UPA','Zona Oeste','Campo Belo', 1);
INSERT INTO funcionario VALUES(2,'Thais Souza Xavier', 'Av. Dr. Arnaldo, 468', 'F', current_date - INTERVAL '38' YEAR, '951753824', 'thaisouza@outlook.com',100,'Coord. e enfermeira', '14-MAI-1980');
INSERT INTO unidade VALUES (102, 'UBS Vila Militar', 'Av. Armada, 841', '75395182', 'UBS', 'Zona Norte', 'Santana', 2);
INSERT INTO unidade VALUES (103, 'AMA Vila das lagrimas', 'Rua Floresta Nublada, 9351','71934681', 'AMA', 'Zona Sul', 'Ana Rosa', 2);

-- Populando a tabela hospital
INSERT INTO hospital VALUES(100,456,65);
INSERT INTO hospital VALUES(101,321,25);

-- Populando a tabela posto
INSERT INTO posto VALUES(102,'Sarampo, Triplice Viral, Gripe', 'Vacinacao e primeiros-socorros');
INSERT INTO posto VALUES(103,'Tetano, Poliomelite, Malaria', 'Vacinacao e atend. psicologico');

-- Populando a tabela funcionario
INSERT INTO funcionario VALUES (3,'Leandro Oliveira Carvalho','Rua da alegria, 943', 'M', current_date - INTERVAL '28' YEAR, '159753497', 'olivleandro@yahoo.com', 102,'Enferemeiro','20-JUN-1987');
INSERT INTO funcionario VALUES (4, 'Fabiana Albuquerque da Silva', 'Av. Paulista, 1459 Ap. 87','F', current_date - INTERVAL '55' YEAR, '415674165', 'fabialbuquerque@hotmail.com', 103,'Medica', '05-JAN-2004');

-- Populando a tabela medico
INSERT INTO medico VALUES (1,'Cardiologia',45685246);
INSERT INTO medico VALUES (4,'Reumatologista',19735487);

-- Populando a tabela horario
INSERT INTO horario VALUES (10,'SEG','08:00','17:00','Integral');
INSERT INTO horario VALUES (15,'QUA', '18:00', '05:00', 'Noturno');

-- Populando a tabela escala
INSERT INTO escala VALUES(10,1,current_date + 14, current_date + 365, 'Interno');
INSERT INTO escala VALUES(15,4,current_date, current_date + 30, 'Temp.');

-- Populando a tabela tipo de atendimento
INSERT INTO tipo VALUES(1,'Consulta', 'Solcitar exame de sangue e eletrocardiograma');
INSERT INTO tipo VALUES(2,'Vacinacao', 'Vacinar e dar recomendacoes');
INSERT INTO tipo VALUES(3,'Internacao','Diagnosticar e tratamento estabelecer adequado');
INSERT INTO tipo VALUES(4,'Socorro','Avaliar estado do paciente e chamar especialista');

-- Populando a tabela atendimentos prestados
INSERT INTO atend_pres VALUES (100,1);
INSERT INTO atend_pres VALUES (101,3);
INSERT INTO atend_pres VALUES (102,4);
INSERT INTO atend_pres VALUES (103,2);

-- Populando a tabela paciente
INSERT INTO paciente VALUES (paciente_seq.nextval,'Luiza Siqueira Ramos', 'Av. Sapopemba, 1011', '943167175', '157419568','32145841243',65495174,NULL,'20-04-1964','F','123456');
INSERT INTO paciente VALUES (paciente_seq.nextval,'Daniel Fragoso Reis', 'Rua Junqueira, 198', '941526573','24964127','16848651014',392347459,'fragreis@gmail.com','02-05-1978','M','qwerty');
INSERT INTO paciente VALUES (paciente_seq.nextval, 'Renata Schneider', 'Rua Itapura, 9647', '993663206','793591863', '35991156744',13576864,'retschneider@terra.com.br','15-09-1998','F','kasa123');
INSERT INTO paciente VALUES (paciente_seq.nextval, 'Silvio Matarazzo Fabris', 'Av. Sao Joao, 7146', '941678954','51879345X','15634823677',566453221,NULL,'18-07-2005','M','provz457');

-- Populando a tabela vacina
INSERT INTO vacina VALUES (500,'Gripe',10546,300,current_date + 28,'Vacina imunizadora do virus da gripe','JUN','AX54RD43');
INSERT INTO vacina VALUES (510,'Tetano',19765,150,current_date + 14, 'Vacina imunizadora de tetano', 'MAR', 'HGX5457RF');

-- Populando a tabela atendimento
INSERT INTO atendimento VALUES (atendimento_seq.nextval,1,'CONCLUIDA',current_date - 7, 3,103,2,NULL,'32145841243',NULL);
INSERT INTO atendimento VALUES (atendimento_seq.nextval,2,'CONCLUIDA', current_date - 3,3,103,2,NULL,'16848651014',NULL);
INSERT INTO atendimento VALUES (atendimento_seq.nextval,3, 'AGENDADA', current_date + 5,1,100,1,current_date,'35991156744','Fernanda Gaes');
INSERT INTO atendimento VALUES (atendimento_seq.nextval,3,'AGENDADA', current_date + 31,1,100,1,current_date,'35991156744','Fernanda Gaes');
INSERT INTO atendimento VALUES (atendimento_seq.nextval,4,'ANDAMENTO', '22-MAI-2020',2,101,3,NULL,'19462757295',NULL);
INSERT INTO atendimento VALUES (atendimento_seq.nextval,1,'CANCELADA', '18-AGO-2020',2,101,3,NULL,'32145841243',NULL);
INSERT INTO atendimento VALUES (atendimento_seq.nextval,2,'CONCLUIDA','14-JUL-2018',3,102,4,NULL,'16848651014',NULL);
INSERT INTO atendimento VALUES (atendimento_seq.nextval,3,'CONCLUIDA','09-JAN-2019',3,102,4,NULL,'35991156744',NULL);

-- Populando a tabela internacao
INSERT INTO internacao VALUES (220004,'Infeccao COVID-19',25,'Emergencia',4);
INSERT INTO internacao VALUES (220005,'Calculos nos rins',74,'Emergencia',4);

-- Populando a tabela de pronto-atendimento
INSERT INTO socorro VALUES (220006,'Acidente transito','Costelas fraturadas','Medicacao e repouso',4);
INSERT INTO socorro VALUES (220007,'Crise alergica', 'Glandulas inflamadas', 'Medicacao', 4);

-- Populando a tabela consulta
INSERT INTO consulta VALUES (220002,'Consulta cardiologista rotina', 'Solicitacao de exames', 1);
INSERT INTO consulta VALUES (220003,'Consulta cardiologista retorno', 'Avaliacao dos exames', 1);

-- Populando a tabela vacinacao
INSERT INTO vacinacao VALUES (220000,3,500,2,1,0);
INSERT INTO vacinacao VALUES (220001,3,510,0,0,5);

-- Populando a tabela historico
INSERT INTO historico VALUES (220000,1,current_date - 7, NULL, 'Imunizacaoo da gripe por um ano', 'UNICA');
INSERT INTO historico VALUES (220001,2,current_date - 3, '15-06-2017','Imunizacao do tetano por 4 anos', 'PRIMEIRA');

-- Exercicio 6 - Realizando Consultas

-- 1- Mostre os pacientes do sexo feminino com mais de 21 anos de idade que nao tem as letras k,w ou y no nome no formato:
-- "Maria Adelaide Ferreira tem 32 anos e reside em Rua Vergueiro, 1990"

SELECT nome_paciente || ' tem ' || ROUND(MONTHS_BETWEEN(current_date,dt_nascimento)/12,0) || ' anos e reside em ' || end_paciente AS Dados
FROM paciente
WHERE sexo='F' AND ROUND(MONTHS_BETWEEN(current_date,dt_nascimento)/12,0) > 21 AND
(UPPER(nome_paciente) NOT LIKE '%K%' AND UPPER(nome_paciente) NOT LIKE '%W%' AND UPPER(nome_paciente) NOT LIKE '%Y%');

-- 2- Mostre a escala de trabalho dos medicos ortopedistas para a semana de 05 a 11 de outubro:
-- Nome da Unidade - Nome do medico - Dia da semana - Hora inicio - Hora Termino. Ordenado pelo dia da semana e horario de inicio

SELECT u.nome_uni AS Unidade, f.nome AS Medico, h.dia AS "Dia da semana", h.hora_inicio AS "Hora inicio", h.hora_fim AS "Hora termino"
FROM unidade u JOIN funcionario f ON (u.cod_uni = f.cod_uni) JOIN escala e ON (e.num_funcionario = f.num_funcionario) JOIN horario h ON (h.cod_hora = e.cod_hora)
JOIN medico m ON (m.num_funcionario = f.num_funcionario)
WHERE UPPER(m.especialidade) LIKE 'ORTOPEDISTA' AND e.data_inicio BETWEEN '05-OUT-2020' AND '11-OUT-2020'
ORDER BY h.dia,h.hora_inicio;

-- 3- Mostre a lista dos atendimentos diarios de uma determinada unidade de saude:
-- Tipo do atendimento, Numero do atendimento, Data-hora agendada, Paciente, Responsavel pelo paciente, Sexo, Telefone, Email, Agendado por

SELECT DECODE(a.cod_tipo,1,'Consulta',2,'Vacinacao',3,'Internacao',4,'Socorro','Atendimento cadastrado incorretamente') AS "Tipo do Atendimento",
a.num_atendimento AS "Numero do atendimento", a.data_hora_agend AS "Agendado em", p.nome_paciente AS Paciente, a.responsavel AS "CPF do Responsavel",
DECODE(p.sexo,'M','Masculino','F','Feminino') AS Sexo, p.fone_paciente AS Telefone, p.email AS Email, a.agendado_por AS "Responsavel pelo agendamento",
u.nome_uni AS Unidade, EXTRACT(DAY FROM a.data_hora_atend) AS Dia
FROM paciente p JOIN atendimento a ON (a.id_paciente = p.id_paciente) JOIN atend_pres at ON (a.cod_tipo = at.cod_tipo AND a.cod_uni = at.cod_uni)
JOIN unidade u ON (at.cod_uni = u.cod_uni)
ORDER BY u.cod_uni, EXTRACT(DAY FROM a.data_hora_atend);

-- 4- Mostre os medicos que internaram pacientes que ficaram no mesmo quarto e leito no primeiro semestre de 2020.
-- Nome do medico, nome do paciente, data, motivo, quarto e leito.

SELECT f.nome AS Medico, p.nome_paciente AS Paciente, a.data_hora_atend AS "Data da internacao", i.motivo AS Motivo, i.quarto AS Quarto, i.leito AS Leito
FROM paciente p JOIN atendimento a ON (p.id_paciente = a.id_paciente) JOIN internacao i ON (a.num_atendimento = i.num_atendimento)
JOIN medico m ON (m.num_funcionario = i.num_funcionario) JOIN funcionario f ON (m.num_funcionario = f.num_funcionario)
WHERE a.data_hora_atend < '01-JUL-2020' AND i.quarto IN (SELECT quarto FROM internacao HAVING COUNT(quarto) > 1 GROUP BY quarto)
AND i.leito IN (SELECT leito FROM internacao HAVING COUNT(leito) > 1 GROUP BY leito);

-- 5- Mostre a quantidade de Pronto Atendimento (socorro) a cada ano, desde 2015, por motivo para UPAs do distrito do Ipiranga.

SELECT COUNT(*) AS Quantidade, s.motivo AS Motivo, EXTRACT(YEAR FROM a.data_hora_atend) AS Ano
FROM socorro s JOIN atendimento a ON (a.num_atendimento = s.num_atendimento) JOIN atend_pres at ON (at.cod_uni = a.cod_uni AND at.cod_tipo = a.cod_tipo)
JOIN unidade u ON (u.cod_uni = at.cod_uni)
WHERE a.data_hora_atend >= '01-JAN-2015' AND UPPER(tipo_uni) LIKE 'UPA' AND UPPER(dist_uni) LIKE '%IPIRANGA%'
GROUP BY s.motivo, EXTRACT(YEAR FROM a.data_hora_atend);

-- 6- Mostre para cada atendente a quantidade de agendamentos realizados por mes e por tipo nos ultimos 6 meses desde que ultrapasse 50 agendamentos/mes/tipo
SELECT f.nome AS Funcionario, COUNT(*) AS Atendimentos, DECODE(cod_tipo,1,'Consulta',2,'Vacinacao',3,'Internacao',4,'Socorro','Atualizar atendimentos') AS Tipo,
EXTRACT(MONTH FROM data_hora_atend) AS Mes
FROM atendimento a JOIN funcionario f ON (f.num_funcionario = a.num_funcionario)
WHERE data_hora_atend >= current_date - INTERVAL '6' MONTH
HAVING COUNT(*) > 50
GROUP BY f.nome, cod_tipo, EXTRACT(MONTH FROM data_hora_atend);

-- 7- Mostre um ranking das 10 unidades de saude que mais atenderam pacientes "da melhor idade" no ultimos 120 dias por motivo de "depressao":
-- Nome da Unidade, Tipo da Unidade, Quantidade de atendimento, independente do tipo de atendimento

SELECT u.nome_uni AS Unidade, u.tipo_uni AS "Tipo da unidade", COUNT(*) AS Atendimentos
FROM unidade u JOIN atend_pres at ON (at.cod_uni = u.cod_uni) JOIN atendimento a ON (a.cod_tipo = at.cod_tipo AND a.cod_uni = at.cod_uni)
JOIN paciente p ON (p.id_paciente = a.id_paciente) JOIN consulta c ON (c.num_atendimento = a.num_atendimento) JOIN socorro s ON (s.num_atendimento = a.num_atendimento)
JOIN internacao i ON (i.num_atendimento = a.num_atendimento)
WHERE a.data_hora_atend BETWEEN current_date AND current_date - 120 AND ROUND(MONTHS_BETWEEN(current_date,p.dt_nascimento)/12,0) >= 60 AND
(UPPER(i.motivo) LIKE '%DEPRESS_O%' OR UPPER(s.motivo) LIKE '%DEPRESS_O%' OR UPPER(c.diagnostico) LIKE '%DEPRESS_O%')
GROUP BY u.nome_uni, u.tipo_uni FETCH FIRST 10 ROWS ONLY;

-- 8- Mostre os pacientes que realizam consultas mas nao tomam vacina: nome do paciente, idade e sexo

SELECT DISTINCT p.nome_paciente AS Paciente, ROUND(MONTHS_BETWEEN(current_date, p.dt_nascimento)/12,0) AS Idade, DECODE(p.sexo,'M','Masculino','F','Feminino') AS Sexo
FROM paciente p JOIN atendimento a ON (a.id_paciente = p.id_paciente) JOIN consulta c ON (a.num_atendimento = c.num_atendimento)
WHERE p.id_paciente NOT IN (SELECT p.id_paciente FROM paciente p JOIN atendimento a ON (p.id_paciente = a.id_paciente) WHERE a.cod_tipo=2);

-- 9- Mostre as unidades de saude que possuem uma taxa de cancelamento de atendimentos superior a 20% nos ultimos 12 meses:
-- Nome da Unidade, Tipo da Unidade, Qntd de Agendamentos, Qntd de Cancelamento

SELECT u.nome_uni AS Unidade, u.tipo_uni AS Tipo, COUNT(a.data_hora_agend) AS Agendados,(SELECT COUNT(*) FROM atendimento WHERE UPPER(estado) LIKE '%CANCELADA%' AND data_hora_agend IS NOT NULL) AS "Agendamentos Cancelados"
FROM unidade u JOIN atend_pres at ON (at.cod_uni = u.cod_uni) JOIN atendimento a ON (a.cod_tipo = at.cod_tipo AND a.cod_uni = at.cod_uni)
WHERE a.data_hora_agend >= current_date - INTERVAL '12' MONTH
HAVING (SELECT COUNT(*) FROM atendimento WHERE UPPER(estado) LIKE '%CANCELADA%' AND data_hora_agend IS NOT NULL) > COUNT(a.data_hora_agend)*0.2
GROUP BY u.nome_uni, u.tipo_uni;

-- 10- Mostre os funcionario da area de enfermagem (enfermeiro, auxiliar de enfermagem, etc.) que nunca aplicaram vacina:
-- Nome do Funcionario, Cargo, Data de Admissao, Tempo de Trabalho (quantidade em anos que trabalha na unidade de saude).
-- Resolva de tres formas diferentes, sendo uma com juncao externa.

SELECT f.nome AS Funcionario, f.cargo AS Cargo, f.data_admissao AS "Data de Admissao", ROUND(MONTHS_BETWEEN(current_date,f.data_admissao)/12,0) AS "Tempo de trabalho"
FROM vacinacao v RIGHT OUTER JOIN funcionario f ON (f.num_funcionario = v.num_funcionario)
WHERE v.num_funcionario IS NULL AND UPPER(f.cargo) LIKE '%ENFER%';

SELECT f.nome AS Funcionario, f.cargo AS Cargo, f.data_admissao AS "Data de Admissao", ROUND(MONTHS_BETWEEN(current_date,f.data_admissao)/12,0) AS "Tempo de trabalho"
FROM funcionario f
WHERE UPPER(f.cargo) LIKE '%ENFER%' AND f.num_funcionario NOT IN (SELECT v.num_funcionario FROM vacinacao v);

SELECT f.nome AS Funcionario, f.cargo AS Cargo, f.data_admissao AS "Data de Admissao", ROUND(MONTHS_BETWEEN(current_date,f.data_admissao)/12,0) AS "Tempo de trabalho"
FROM funcionario f
WHERE UPPER(f.cargo) LIKE '%ENFER%' AND f.num_funcionario IN ((SELECT f.num_funcionario FROM funcionario f) MINUS (SELECT v.num_funcionario FROM vacinacao v));

-- 11- Mostre os pacientes que tomaram a primeira dose de uma vacina mas nao tomaram as demais neste ano, ou seja, que esta faltando tomar vacina,
-- o prazo para tomar a dose seguinte ja se esgotou. Lembre-se que vacinas com mais de uma dose devem ter a informacao do intervalo entre doses.
-- Formato: Tipo da Vacina, Doses Recomendadas, Nome do Paciente, Numero do SUS, Numero da dose, Data de Vacinacao, Aplicado por, Nome da Unidade,
-- Tipo da Unidade, Regiao, Distrito, Doses Faltantes.

SELECT va.tipo AS Tipo, v.doses_rec AS "Doses Recomendadas", p.nome_paciente AS Paciente, p.num_sus AS "Numero do SUS",v.doses_rec - v.doses_fat AS "Numero da dose", h.dt_vacinacao AS "Data da Vacinacao",
f.nome AS "Aplicador", u.nome_uni AS Unidade, u.tipo_uni AS "Tipo de Unidade", u.zona_uni AS Regiao, u.dist_uni AS Distrito, v.doses_fat AS "Doses Faltantes"
FROM vacina va JOIN vacinacao v ON (v.cod_vac = va.cod_vac) JOIN atendimento a ON (a.num_atendimento = v.num_atendimento) JOIN historico h ON
(h.num_atendimento = a.num_atendimento) JOIN paciente p ON (p.id_paciente = h.id_paciente) JOIN funcionario f ON (v.num_funcionario = f.num_funcionario)
JOIN unidade u ON (u.cod_uni = f.cod_uni)
WHERE v.doses_fat >= 1 AND ADD_MONTHS(h.dt_vacinacao,v.meses_prox) < current_date;
