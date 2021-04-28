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
