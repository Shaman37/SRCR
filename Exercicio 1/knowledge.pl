:- module(database,[utente/7, prestador/5, cuidado/5]).
:- dynamic utente/7.
:- dynamic prestador/5.
:- dynamic cuidado/5.

% utente: #IdUt, Nome, Idade, Tipo de Sangue, Rua, Cidade, Contacto -> {V,F}
utente(1,'Antonio',21,'A','Rua de Groias','Braga','253456789').
utente(2,'Filipa',14,'O','Rua do Caires','Braga','929876543').
utente(3,'Carolina',34,'AB','Rua das Victorias','Guimaraes','913122199').
utente(4,'Carlos',53,'A','Rua da Fabrica','Braga','253433582').
utente(5,'Julio',21,'A','Rua da Ramada','Guimaraes','253987654').
utente(6,'Dinis',42,'B','Av.da Boavista','Porto','912090133').
utente(7,'Fernando',9,'B','Rua do Pinheiro','Ponte de Lima','966668569').
utente(8,'Rute',22,'B','Av. da Liberdade','Braga','916386423').
utente(9,'Raul',31,'O','Rua das Flores','Porto','935731290').
utente(10,'Joao',27,'AB','Largo de Camoes','Ponte de Lima','289347681').
utente(11,'Filipe',24,'B','Rua do Loureiro','Viana do Castelo','258444392').
utente(12,'Manuel',87,'A','Rua D.Pedro V','Braga','244000045').
utente(13,'Jaime',69,'A','Av. Norton Matos','Ponte de Lima','258768180').
utente(14,'Rui',30,'B','Rua da Boavista','Guimaraes','966306127').
utente(15,'Tiago',17,'AB','Alameda do Lago','Braga','926150873').

% prestador: #IdPrest, Nome, Especialidade, Instituição, Cidade -> {V,F}
prestador(1,'Sianna Summerley','Pediatria','Hospital de Braga','Braga').
prestador(2,'Donica Putman','Obstreticia','Trofa Saúde Hospital','Braga').
prestador(3,'Curran Shore','Oftomalogia','Hospital de Braga','Braga').
prestador(4,'Shauna Goodbody','Maternidade','Hospital de Santa Maria','Porto').
prestador(5,'Madge Crossan','Cardiologia','Trofa Saúde Hospital','Braga').
prestador(6,'Carolyne Simonetti','Medicina Geral','Hospital de Braga','Braga').
prestador(7,'Haily Dadge','Enfermagem','Trofa Saúde Hospital','Braga').
prestador(8,'Althea Poynor','Ginecologia','Hospital da Luz','Guimarães').
prestador(9,'Mayer Likely','Medicina Geral','Trofa Saúde Hospital','Braga').
prestador(10,'Krystal Karran','Medicina Geral','Hospital de Santa Maria','Porto').
prestador(11,'Gerrilee Cordova','Ginecologia','Hospital da Luz','Guimarães').
prestador(12,'Marcelia Bemment','Medicina Geral','Trofa Saúde Hospital','Braga').
prestador(13,'Darn Weeds','Psiquiatria','Hospital de Braga','Braga').
prestador(14,'Mariam Nuschke','Ortopedia','Hospital de Santa Maria','Porto').
prestador(15,'Virgil Spreull','Medicina Geral','Trofa Saúde Hospital','Braga').

% cuidado: Data, #IdUt, #IdPrest, Descrição, Custo -> {V,F}
cuidado('2017-12-28',12,15,'Intoxicação alimentar',61.23).
cuidado('2018-01-12',8,14,'Perna partida',33.97).
cuidado('2018-01-15',5,12,'Alergia de pelo',32.3).
cuidado('2018-01-23',5,14,'Traumatismo craniano',35.76).
cuidado('2018-01-30',8,13,'Insônia',42.0).
cuidado('2018-02-05',1,5,'Eletrocardiograma',24.57).
cuidado('2018-02-14',5,12,'Análises Clinicas',45.13).
cuidado('2018-02-19',6,12,'Exame Polmunar',71.03).
cuidado('2018-02-22',14,6,'Vomitos',54.31).
cuidado('2018-02-27',9,6,'Febre',58.16).
cuidado('2018-03-02',2,2,'Pré-natal de risco',53.29).
cuidado('2018-03-02',6,10,'Ferimento no abdomen',89.71).
cuidado('2018-03-02',9,9,'Amigdalite',43.39).
cuidado('2018-03-02',9,14,'Dedo fraturado',75.3).
cuidado('2018-03-05',10,11,'Consulta de rotina',24.94).
cuidado('2018-03-07',9,9,'Pedras nos rins',65.59).
cuidado('2018-03-08',8,7,'Radiografia Joelho',41.65).
cuidado('2018-03-10',7,7,'Radiografia Perna',45.6).
cuidado('2018-03-13',12,10,'Queimadura de segundo grau',85.79).
cuidado('2018-03-17',9,12,'Consulta de rotina',30.29).

