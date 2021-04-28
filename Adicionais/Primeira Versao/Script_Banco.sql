/*** ESQUEMA DE RELAÇÕES - SISTEMA DE SAÚDE
Unidade(cod_uni(PK),nome_uni,end_uni,fone_uni,cood_uni,zona_uni,dist_uni);
Hospital(cod_uni(PK)(FK),num_emergencia,num_uti);
Posto(cod_uni(PK)(FK),desc_vacinas,atend_pres);
Medico(num_funcionario(PK),cod_uni(FK),num_crm(U),hora_trab,nome_med);
Atendimento(num_atendimento(PK),num_funcionario(FK),id_paciente(FK),tipo(CK),estado(CK),diagnostico,data_hora_atend,prescricao,cid);
Paciente(id_paciente(PK),nome_paciente,end_paciente,fone_paciente,num_rg(U),num_cpf(U),num_sus(U),email,dt_nascimento);
***/

-- Tabela de Unidade de Atendimento
DROP TABLE unidade CASCADE CONSTRAINTS;
CREATE TABLE unidade(
    cod_uni INTEGER NOT NULL PRIMARY KEY,
    nome_uni VARCHAR2(40) NOT NULL,
    end_uni VARCHAR2(50) NOT NULL,
    fone_uni CHAR(8) NOT NULL,
    cood_uni VARCHAR2(40) NOT NULL,
    zona_uni VARCHAR2(15) NOT NULL,
    dist_uni VARCHAR2(20) NOT NULL
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
    cod_uni INTEGER NOT NULL,
    num_crm INTEGER NOT NULL,
    nome_med VARCHAR2(40) NOT NULL,
    hora_trab CHAR(15) NOT NULL,
    FOREIGN KEY(cod_uni) REFERENCES unidade(cod_uni) ON DELETE CASCADE,
    UNIQUE(num_crm)
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

-- Criação da sequência de código identificadores de atendimentos
DROP SEQUENCE atendimento_seq;
CREATE SEQUENCE atendimento_seq START WITH 220000 INCREMENT BY 1
MINVALUE 220000 MAXVALUE 920000 NOCYCLE;

-- Tabela de atendimentos
DROP TABLE atendimento CASCADE CONSTRAINTS;
CREATE TABLE atendimento(
    num_atendimento INTEGER NOT NULL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    tipo VARCHAR2(11) NOT NULL,
    estado VARCHAR2(9) NOT NULL,
    diagnostico VARCHAR2(50) NOT NULL,
    data_hora_atend TIMESTAMP NOT NULL,
    prescricao VARCHAR2(40) NOT NULL,
    cid CHAR(3) NOT NULL,
    num_funcionario INTEGER NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (num_funcionario) REFERENCES medico(num_funcionario) ON DELETE CASCADE
);

-- Constraint check do tipo de atendimento da tabela de atendimentos
ALTER TABLE atendimento
ADD CONSTRAINT ck_tipo_atendimento CHECK (tipo IN ('CONSULTA','ATENDIMENTO','INTERNACAO','VACINACAO'));

-- Constraint check do estado do atendimento da tabela de atendimentos
ALTER TABLE atendimento
ADD CONSTRAINT ck_estado_atendimento CHECK (estado IN ('AGENDADA','ANDAMENTO','CANCELADA','CONCLUIDA'));