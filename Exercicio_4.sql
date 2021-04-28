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

