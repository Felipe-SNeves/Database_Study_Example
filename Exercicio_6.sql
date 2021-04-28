-- Exercicio 6

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
