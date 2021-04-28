/*** ESQUEMA DE RELAÇÕES - SISTEMA DE SAÚDE REFORMALADO
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
Vacinacao(num_atendimento(PK)(FK),num_funcionario(FK),tipo,dose,data_anterior);
Atendimento(num_atendimento(PK),id_paciente(FK),num_funcionario(FK),cod_uni(FK),cod_tipo(FK),estado(CK),data_hora_atend);
Paciente(id_paciente(PK),nome_paciente,end_paciente,fone_paciente,num_rg(U),num_cpf(U),num_sus(U),email,sexo(CK),dt_nascimento);
Atend_pres(cod_tipo(PK)(FK),cod_uni(PK)(FK));
Tipo(cod_tipo(PK),tipo,procedimento);
***/

-- Tabela de Tipo de Atendimento
DROP TABLE tipo CASCADE CONSTRAINTS;
CREATE TABLE tipo(
    cod_tipo SMALLINT NOT NULL PRIMARY KEY,
    tipo VARCHAR2(20) NOT NULL,
    procedimento VARCHAR2(50) NOT NULL
);

-- Tabele de Horários
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
ADD num_funcionario INTEGER NOT NULL;

-- Tabela funcionário
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

-- Tabela de Hospital (Especilização da tabela Unidade de Atendimento)
DROP TABLE hospital CASCADE CONSTRAINTS;
CREATE TABLE hospital(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    num_emergencia SMALLINT NOT NULL,
    num_uti SMALLINT NOT NULL,
    FOREIGN KEY(cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE
);

-- Tabela de Posto de Saúde (Especilização de Unidade de Atendimento)
DROP TABLE posto CASCADE CONSTRAINTS;
CREATE TABLE posto(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    desc_vacinas VARCHAR2(50) NOT NULL,
    atend_pres VARCHAR2(50) NOT NULL,
    FOREIGN KEY(cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE
);

-- Tabela de Médicos
DROP TABLE medico CASCADE CONSTRAINTS;
CREATE TABLE medico(
    num_funcionario INTEGER NOT NULL PRIMARY KEY,
    especialidade VARCHAR2(15) NOT NULL,
    num_crm INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (num_funcionario) REFERENCES funcionario(num_funcionario) ON DELETE CASCADE
);

-- Tabela de escala de horários
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

-- Criação da sequência de códigos identificadores de pacientes
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

-- Criação da sequência de código identificadores de atendimentos
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

-- Tabela de Vacinação
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

-- Tabela de Internação
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