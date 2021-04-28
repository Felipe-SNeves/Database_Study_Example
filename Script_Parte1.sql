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
