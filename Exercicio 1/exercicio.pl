:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

:- op( 900,xfy,'::' ).
:- dynamic utente/4.
:- dynamic prestador/5.
:- dynamic cuidado/5.

%---------------------------------------------%
%----------- BASE DE CONHECIMENTO ------------%
%---------------------------------------------%

% utente: #IdUt, Nome, Idade, Morada, Contacto -> {V,F} %
utente(1,'Antonio',21,'Rua de Groias','Braga','253456789').
utente(2,'Filipa',14,'Rua do Caires','Braga','929876543').
utente(3,'Carolina',34,'Rua das Victorias','Guimaraes','913122199').
utente(4,'Carlos',53,'Rua da Fabrica','Braga','253433582').
utente(5,'Julio',21,'Rua da Ramada','Guimaraes','253987654').
utente(6,'Dinis',42,'Av.da Boavista','Porto','912090133').
utente(7,'Fernando',9,'Rua do Pinheiro','Ponte de Lima','966668569').
utente(8,'Rute',22,'Av. da Liberdade','Braga','916386423').
utente(9,'Raul',31,'Rua das Flores','Porto','935731290').
utente(10,'Joao',27,'Largo de Camoes','Ponte de Lima','289347681').
utente(11,'Filipe',24,'Rua do Loureiro','Viana do Castelo','258444392').
utente(12,'Manuel',87,'Rua D.Pedro V','Braga','244000045').
utente(13,'Jaime',69,'Av. Norton Matos','Ponte de Lima','258768180').
utente(14,'Rui',30,'Rua da Boavista','Guimaraes','966306127').
utente(15,'Tiago',17,'Alameda do Lago','Braga','926150873').


% prestador: #IdPrest, Nome, Especialidade, Instituição, Cidade -> {V,F}

prestador('1','Sianna Summerley','Pediatria','Hospital de Braga','Braga').
prestador('2','Donica Putman','Obstreticia','Trofa Saúde Hospital','Braga').
prestador('3','Curran Shore','Oftomalogia','Hospital de Braga','Braga').
prestador('4','Shauna Goodbody','Maternidade','Hospital de Santa Maria','Porto').
prestador('5','Madge Crossan','Cardiologia','Trofa Saúde Hospital','Braga').
prestador('6','Carolyne Simonetti','Medicina Geral','Hospital de Braga','Braga').
prestador('7','Haily Dadge','Enfermagem','Trofa Saúde Hospital','Braga').
prestador('8','Althea Poynor','Ginecologia','Hospital da Luz','Guimarães').
prestador('9','Mayer Likely','Medicina Geral','Trofa Saúde Hospital','Braga').
prestador('10','Krystal Karran','Medicina Geral','Hospital de Santa Maria','Porto').
prestador('11','Gerrilee Cordova','Ginecologia','Hospital da Luz','Guimarães').
prestador('12','Marcelia Bemment','Medicina Geral','Trofa Saúde Hospital','Braga').
prestador('13','Darn Weeds','Psiquiatria','Hospital de Braga','Braga').
prestador('14','Mariam Nuschke','Ortopedia','Hospital de Santa Maria','Porto').
prestador('15','Virgil Spreull','Medicina Geral','Trofa Saúde Hospital','Braga').

% cuidado: Data, #IdUt, #IdPrest, Descrição, Custo -> {V,F}

cuidado('2018-03-02','9','14','Dedo fraturado','€75,30').
cuidado('2017-12-28','12','15','Intoxicação alimentar','€61,23').
cuidado('2018-03-02','9','9','Amigdalite','€43,39').
cuidado('2018-01-12','8','14','Perna partida','€33,97').
cuidado('2018-01-15','5','12','Alergia de pelo','€32,30').
cuidado('2018-01-23','5','14','Traumatismo craniano','€35,76').
cuidado('2018-01-30','8','13','Insônia','€42,00').
cuidado('2018-03-02','2','2','Pré-natal de risco ...','€53,29').
cuidado('2018-02-05','1','5','Eletrocardiograma','€24,57').
cuidado('2018-02-14','5','12','Análises Clinicas','€45,13').
cuidado('2018-02-19','6','12','Exame Polmunar','€71,03').
cuidado('2018-02-22','14','6','Vomitos','€54,31').
cuidado('2018-02-27','9','6','Febre','€58,16').
cuidado('2018-03-02','6','10','Ferimento no abdomen','€89,71').
cuidado('2018-03-05','10','11','Consulta de rotina','€24,94').
cuidado('2018-03-07','9','9','Pedras nos rins','€65,59').
cuidado('2018-03-08','8','7','Radiografia Joelho','€41,65').
cuidado('2018-03-10','7','7','Radiografia Perna','€45,60').
cuidado('2018-03-13','12','10','Queimadura de segundo grau','€85,79').
cuidado('2018-03-17','9','12','Consulta de rotina','€30,29').
%------------------------------------------------------------------%
%-> Extensão do predicado que permite a evolução do conhecimento <-%
%------------------------------------------------------------------%

insert(T) :- assert(T).
insert(T) :- retract(T),!,fail.

test([]).
test([H|T]) :- H,test(T).

len([],0).
len([H|T],R) :- len(T,C), R is 1+C.

learn(T) :- solutions(I,+T::I,L),
	    insert(T),
	    test(L).

%-----------------------------------------------------------------%
%-> Extensão do predicado que permite a redução do conhecimento <-%
%-----------------------------------------------------------------%

remove(T) :- retract(T).

forget(T) :- solutions(I,+T::I,L),
	     test(L),
             remove(T).

%------------------------------------------------------------------%
%-> Extensão do predicado que permite a procura de conhecimento  <-%
%------------------------------------------------------------------%

solutions(X,Y,Z) :- findall(X,Y,Z).

%---------------------------------------------------------------------%
%-> Invariante Estrutural do Utente (não permite inserção repetida) <-%
%---------------------------------------------------------------------%

+utente(ID,N,A,Z) :: (solutions(ID,(utente(ID,_,_,_)),L),
		      len(L,C),
		      C == 1).

%------------------------------------------------------------------------%
%-> Invariante Estrutural do Prestador (não permite inserção repetida) <-%
%------------------------------------------------------------------------%

+prestador(ID,N,S,I) :: (solutions(ID,(prestador(ID,_,_,_,_)),L),
			 len(L,C),
			 C == 1).

%----------------------------------------------------------------------%
%-> Invariante Estrutural do Cuidado (não permite inserção repetida) <-%
%----------------------------------------------------------------------%

+cuidado(D,UID,PID,DG,P) :: (solutions((D,UID,PID,DG,P),(cuidado(D,UID,PID,DG,P)),L),
			     len(L,C),
			     C == 1).

+cuidado(D,UID,PID,DG,P) :: ((utente(UID,_,_,_)),(prestador(PID,_,_,_,_))).

% Query 1
%- Registar utentes
registaUtente(ID,N,A,Z) :- learn(utente(ID,N,A,Z)).
%- Registar prestadores
registaPrestador(ID,N,S,I,C) :- learn(prestador(ID,N,S,I,C)).
%- Registar cuidados
registaCuidado(D,UID,PID,DSC,P) :- learn(cuidado(D,UID,PID,DSC,P)).

% Query 2
%- Remover utente
removeUtente(ID) :- forget(utente(ID,_,_,_)).
% ao remover utentes -> removemos os cuidados a ele prestados?

%- Remover prestador
removePrestador(ID) :- forget(prestador(ID,_,_,_,_)).
% ao remover prestadores -> removemos os cuidados por ele prestados?

%- Remover cuidado
removeCuidado(D,UID,PID,DG,P) :- forget(cuidado(D,UID,PID,DG,P)).

% Query 3
%- Identificar utentes por critérios
utenteID(ID,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utenteName(N,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utenteAge(A,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utenteZone(Z,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)). 

% Query 4		 
%- Identificar Instituições prestadoras de saúde
instituicoesAtivas(R) :- solutions((I,C),(cuidado(_,_,PID,_,_),prestador(PID,_,_,I,C)),L1),
			 repRemove(L1,LI),
			 sortL(LI,R).

% Query 5
%- Identificar cuidados de saúde prestados por instituição/cidade/datas

%- Por instituicao
cuidadosInstituicao(I,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(D,UID,PID,DG,C)),LC),
		  sortL(LC,R).

%- Por cidade
cuidadosCidade(C,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,_,C),cuidado(D,UID,PID,DG,C)),LC),
		       sortL(LC,R).

%- Por data
cuidadosData(D,R) :- solutions((D,IU,IP,DG,C),cuidado(D,IU,IP,DG,C),R).		      

% Query 6
%- Identificar os utentes de um prestador/especialidade/instituição

%- prestador
utentes_P(PID,R) :- solutions(utente(UID,N,A,Z),(cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
			 repRemove(L1,LU),
			 sortL(LU,R).

%- especialidade
utentes_ESP(E,R) :- solutions(utente(UID,N,A,Z),(prestador(PID,_,E,_,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
		     repRemove(L1,LU),
		     sortL(LU,R).

%- instituicao
utentes_I(I,R) :- solutions(utente(UID,N,A,Z),(prestador(PID,_,_,I,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
		   	    repRemove(L1,LU),
		            sortL(LU,R).
% Query 7
%- Identificar cuidados de saúde realizados por utente/instituição/prestador

%- utente
cuidados_UT(UID,R) :- solutions(cuidado(D,UID,PID,DG,C),cuidado(D,UID,PID,DG,C),LC),
		      sortL(LC,R).

%- instituicao
cuidados_I(I,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(D,UID,PID,DG,C),LC),
		   sortL(LC,R).

%- prestador
cuidados_P(PID,R) :- solutions(cuidado(D,UID,PID,DG,C),cuidado(D,UID,PID,DG,C)),LC),
		     sortL(LC,R).

% Query 8
%- Determinar todas as instituições/prestadores a que um utente já recorreu
		         
%- instituicoes
instituicoes_UT(UID,R) :- solutions((I,C),(cuidado(_,UID,PID,_,_),prestador(PID,_,_,I,C)),L1),
			     repRemove(L1,LI),
			     sortL(LI,R).

%- prestadores
prestadores_UT(UID,R) :- solutions(prestador(PID,N,E,I,C),(cuidado(_,UID,PID,_,_),prestador(PID,N,E,I,C)),L1),
			  repRemove(L1,LP),
			  sortL(LP,R).

% Query 9
% Calcular custo por Utente
custoUtente(UID,R) :- solutions(C,cuidado(_,UID,_,_,C),LC),
		      sumL(LC,R).

% Calcular custo por Especialidade 
custoEspecialidade(E,R) :- solutions(C,(prestador(PID,_,E,_,_),cuidado(_,_,PID,_,C)),LC),
			   sumL(LC,R).

% Calcular custo por Prestador
custoPrestador(PID,R) :- solutions(C,cuidado(_,_,PID,_,C),LC),
			 sumL(LC,R).


% Calcular custo por Datas
custoData(D,R) :- solutions(C,cuidado(D,_,_,_,C),L1),
		  sumL(LC,R).

%--
repRemove([],[]).
repRemove([X|A],R) :- elemRemove(X,A,L),
                      repRemove(L,T),
                      R = [X|T].

elemRemove(A,[],[]).
elemRemove(A,[A|Y],T) :- elemRemove(A,Y,T).
elemRemove(A,[X|Y],T) :- X \== A,
                         elemRemove(A,Y,R),
			 T = [X|R].

sortL([],[]).
sortL([X],[X]).
sortL([H|T],R) :- sortL(T,L1),
                  ins(H,L1,R).

ins(X,[],[X]).
ins(X,[H|T],[X,H|T]) :- X @=< H.
ins(X,[H|T],[H|NT]) :- X @> H,
                       ins(X,T,NT).

sumL([],0).
sumL([H|T],R) :- sumL(T,N),
		     R is H+N.
