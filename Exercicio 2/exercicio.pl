:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( unknown,fail ).
:- set_prolog_flag( answer_write_options,[max_depth(0)] ).

:- op( 400, yfx, '&&').
:- op( 400, yfx, '$$').
:- op( 600, xfx, 'eq').
:- op( 900,xfy,'::' ).

:- style_check(-discontiguous).
:- dynamic (-)/1.
:- dynamic excecao/2.
:- dynamic utente/7.
:- dynamic prestador/5.
:- dynamic cuidado/6.
:- dynamic sangue/2.

:- include(knowledge).
:- include(functionalities).

%----------------------%
% TABELA DE INFERÊNCIA %
%----------------------%

equal(verdadeiro  , &&(verdadeiro  , verdadeiro)).
equal(desconhecido, &&(desconhecido, verdadeiro)).
equal(desconhecido, &&(verdadeiro  , deconhecido)).
equal(desconhecido, &&(desconhecido, desconhecido)).
equal(falso       , &&(falso       , _)).
equal(falso       , &&(_           , falso)).

equal(falso       , $$(falso       , falso)).
equal(desconhecido, $$(falso       , desconhecido)).
equal(desconhecido, $$(desconhecido, falso)).
equal(desconhecido, $$(desconhecido, desconhecido)).
equal(verdadeiro  , $$(verdadeiro  , _)).
equal(verdadeiro  , $$(_           , verdadeiro)).

%------------------------------------------------------------------%
%-> Extensão do predicado que permite a evolução do conhecimento <-%
%------------------------------------------------------------------%

insert(T) :- assert(T).
insert(T) :- retract(T),!,fail.

test([]).
test([H|T]) :- H,test(T).

len([],0).
len([_|T],R) :- len(T,C), R is 1+C.

learn(T) :- solutions(I,+T::I,L),
	    insert(T),
	    test(L).

%-----------------------------------------------------------------%
%-> Extensão do predicado que permite a redução do conhecimento <-%
%-----------------------------------------------------------------%

remove(T) :- retract(T).

forget(T) :- solutions(I,-T::I,L),
	     test(L),
             remove(T).

%------------------------------------------------------------------%
%-> Extensão do predicado que permite a procura de conhecimento  <-%
%------------------------------------------------------------------%

solutions(X,Y,Z) :- findall(X,Y,Z).


%--------------------------%	
%-> INVARIANTES [UTENTE] <-%
%--------------------------%

+utente(ID,_,_,_,_,_,_) :: (solutions(ID,(utente(ID,_,_,_,_,_,_)),L),
		                  len(L,C),
		                  C == 1).

+utente(_,_,_,_,_,_,TEL) :: (solutions(TEL,(utente(_,_,_,_,_,_,TEL)),L),
		                 len(L,C),
				 C == 1).

+utente(_,N,A,S,RUA,CDD,_) :: (solutions((N,A,S,RUA,CDD),(utente(_,N,A,S,RUA,CDD,_)),L),
				 len(L,C),
				 C == 1).

+utente(_,_,_,S,_,_,_) :: (sangue(S,_)).

-utente(ID,_,_,_,_,_,_) :: (solutions(ID,cuidado(_,_,ID,_,_,_),[])).

%-----------------------------%
%-> INVARIANTES [PRESTADOR] <-%
%-----------------------------%

+prestador(ID,_,_,_,_) :: (solutions(ID,(prestador(ID,_,_,_,_)),L),
			      len(L,C),
			      C == 1).
		     
+prestador(_,N,ESP,I,CDD) :: (solutions((N,ESP,I,CDD),(prestador(_,N,ESP,I,CDD)),L),
				len(L,C),
				C == 1).

-prestador(ID,_,_,_,_) :: (solutions(ID,cuidado(_,_,_,ID,_,_),[])).

%---------------------------%
%-> INVARIANTES [CUIDADO] <-%
%---------------------------%

+cuidado(ID,_,_,_,_,_) :: (solutions(ID,(cuidado(ID,_,_,_,_,_)),L),
			     len(L,C),
			     C == 1).

+cuidado(_,D,UID,PID,DG,C) :: (solutions((D,UID,PID,DG,C),(cuidado(_,D,UID,PID,DG,C)),L),
				len(L,K),
				K == 1).

+cuidado(ID,_,UID,PID,_,_) :: ((utente(UID,_,_,_,_,_,_)),(prestador(PID,_,_,_,_))).

%------------------------------------------------------------%
%-> Extensão dos meta-predicados demo, demoConj e demoDisj <-%
%------------------------------------------------------------%

% demo : Q -> {V,F,D}
demo(Questao,verdadeiro) :- Questao.
demo(Questao,falso) :- -Questao.
demo(Questao,desconhecido) :- nao(Questao),nao(-Questao).

% demoConj : [Q] -> {V, F, D}
demoConj(Questoes, R) :- maplist(demo, Questoes, Rs),
                         and(Rs, R).

% and : Qs -> {V,F,R}
and([], Verdadeiro).
and([Q|Qs], R) :- and(Qs, Rs), R eq Q && Rs.

% demoDisj : [Q] -> {V, F, D}
demoDisj(Questoes, R) :- maplist(demo, Questoes, Rs),
                         or(Rs, R).

% or : Qs -> {V,F,R}
or([], Falso).
or([Q|Qs], R) :- or(Qs, Rs), R eq Q $$ Rs.

%------------------------------------%
%-> Extensão do meta-predicado nao <-%
%------------------------------------%

% nao : Q -> {V,F}
nao(Questao) :- Questao,!,fail.
nao(_).

%-> CONHECIMENTO IMPERFEITO <-%

%--------------------------------------------%
%-> Representação de Conhecimento Negativo <-%
%--------------------------------------------%

%-> Negação Por Falha <-%

-utente(ID,N,A,S,RUA,CDD,TEL) :- nao(utente(ID,N,A,S,RUA,CDD,TEL)),
				 nao(excecao(nome,utente(ID,N,A,S,RUA,CDD,TEL))),
				 nao(excecao(idade,utente(ID,N,A,S,RUA,CDD,TEL))),
				 nao(excecao(sangue,utente(ID,N,A,S,RUA,CDD,TEL))),
				 nao(excecao(rua,utente(ID,N,A,S,RUA,CDD,TEL))),
				 nao(excecao(cidade,utente(ID,N,A,S,RUA,CDD,TEL))),
				 nao(excecao(contacto,utente(ID,N,A,S,RUA,CDD,TEL))).

-prestador(ID,N,ESP,I,CDD) :- nao(prestador(ID,N,ESP,I,CDD)),
			      nao(excecao(nome,prestador(ID,N,ESP,I,CDD))),
                              nao(excecao(especialidade,prestador(ID,N,ESP,I,CDD))),
			      nao(excecao(instituicao,prestador(ID,N,ESP,I,CDD))),
			      nao(excecao(cidade,prestador(ID,N,ESP,I,CDD))).

-cuidado(ID,D,UID,PID,DG,P) :- nao(cuidado(ID,D,UID,PID,DG,P)),
			       nao(excecao(data,cuidado(ID,D,UID,PID,DG,P))),
		               nao(excecao(uid,cuidado(ID,D,UID,PID,DG,P))),
		               nao(excecao(pid,cuidado(ID,D,UID,PID,DG,P))),
		               nao(excecao(diagnostico,cuidado(ID,D,UID,PID,DG,P))),
			       nao(excecao(custo,cuidado(ID,D,UID,PID,DG,P))).

%---------------------------------------------%
%-> Declaração de Conhecimento Incerto      <-%
%---------------------------------------------%

%-> UTENTES <-%

% Nome Desconhecido %
unaware_UT_nome(ID) :- utenteID(ID,utente(_,N,_,_,_,_,_)),atom(N),
		       nao(excecao(nome,utente(ID,_,_,_,_,_,_))),
		       learn(excecao(nome,utente(ID,_,A,S,RUA,CDD,TEL)) :-
				   utente(ID,N,A,S,RUA,CDD,TEL)).

% Idade Desconhecida %
unaware_UT_idade(ID) :- utenteID(ID,utente(_,_,A,_,_,_,_)),atom(A),
		        nao(excecao(idade,utente(ID,_,_,_,_,_,_))),
                        learn(excecao(idade,utente(ID,N,_,S,RUA,CDD,TEL)) :- 
				    utente(ID,N,A,S,RUA,CDD,TEL)).

% Sangue Desconhecido %
unaware_UT_sangue(ID) :- utenteID(ID,utente(_,_,_,S,_,_,_)),atom(S),
		         nao(excecao(sangue,utente(ID,_,_,_,_,_,_))),
		         learn(excecao(sangue,utente(ID,N,A,_,RUA,CDD,TEL)) :- 
		    	         utente(ID,N,A,S,RUA,CDD,TEL)).

% Rua Desconhecido %
unaware_UT_rua(ID) :- utenteID(ID,utente(_,_,_,_,RUA,_,_)),atom(RUA),
	   	      nao(excecao(rua,utente(ID,_,_,_,_,_,_))),
	              learn(excecao(rua,utente(UID,N,A,S,_,CDD,TEL)) :- 
	  	    	      utente(ID,N,A,S,RUA,CDD,TEL)).
		
% Cidade Desconhecido %	      
unaware_UT_cidade(ID) :- utenteID(ID,utente(_,_,_,_,_,CDD,_)),atom(CDD),
			 nao(excecao(cidade,utente(ID,_,_,_,_,_,_))),
			 learn(excecao(cidade,utente(ID,N,A,S,RUA,_,TEL)) :- 
		        	     utente(ID,N,A,S,RUA,CDD,TEL)).

% Contacto Desconhecido %
unaware_UT_contacto(ID) :- utenteID(ID,utente(_,_,_,_,_,_,TEL)),atom(TEL),
			   nao(excecao(contacto,utente(ID,_,_,_,_,_,_))),
			   learn(excecao(contacto,utente(ID,N,A,S,RUA,CDD,_)) :- 
			   	    utente(ID,N,A,S,RUA,CDD,TEL)).

%-> PRESTADORES <-%

% Nome Desconhecido %
unaware_PRT_nome(ID) :- prestadorID(ID, prestador(_,N,_,_,_)),atom(N),
			nao(excecao(nome,prestador(ID,_,_,_,_))),
			learn(excecao(nome,prestador(ID,_,ESP,I,CDD)) :- 
		        	prestador(ID,N,ESP,I,CDD)).

% Especialidade Desconhecida %
unaware_PRT_especialidade(ID) :- prestadorID(ID, prestador(_,_,ESP,_,_)),atom(ESP),
				 nao(excecao(especialidade,prestador(ID,_,_,_,_))),
			    	 learn(excecao(especialidade,prestador(ID,N,_,I,CDD)) :- 
				     prestador(ID,N,ESP,I,CDD)).

% Instituicao Desconhecida %
unaware_PRT_instituicao(ID) :- prestadorID(ID, prestador(_,_,_,I,_)),atom(I),
			       nao(excecao(instituicao,prestador(ID,_,_,_,_))),
			       learn(excecao(instituicao,prestador(ID,N,ESP,_,CDD)) :- 				 
			           prestador(ID,N,ESP,I,CDD)).

% Cidade Desconhecida %
unaware_PRT_cidade(ID) :- prestadorID(ID, prestador(_,_,_,_,CDD)),atom(CDD),
			  nao(excecao(cidade,prestador(ID,_,_,_,_))),
                          learn(excecao(cidade,prestador(ID,N,ESP,I,_)) :- 
				  prestador(ID,N,ESP,I,CDD)).

%-> CUIDADOS <-%

% Data Desconhecida %
unaware_CD_data(ID) :- cuidadoID(ID, cuidado(_,D,_,_,_,_)),atom(D),
		       nao(excecao(data,cuidado(ID,_,_,_,_,_))),
		       learn(excecao(data,cuidado(ID,_,UID,PID,DG,C)) :- 
		           cuidado(ID,D,UID,PID,DG,C)).

% ID de Utente Desconhecido %
unaware_CD_uID(ID) :- cuidadoID(ID, cuidado(_,_,UID,_,_,_)),atom(UID),
	              nao(excecao(uid,cuidado(ID,_,_,_,_,_,_))),
                      learn(excecao(uid,cuidado(ID,D,_,PID,DG,C)) :- 
	              	    cuidado(ID,D,UID,PID,DG,C)).

% ID de Prestador Desconhecido %
unaware_CD_pID(ID) :- cuidadoID(ID, cuidado(_,_,_,PID,_,_)),atom(PID),
		      nao(excecao(pid,cuidado(ID,_,_,_,_,_))),
                      learn(excecao(pid,cuidado(ID,D,UID,_,DG,C)) :- 
                      	    cuidado(ID,D,UID,PID,DG,C)).

% Diagnostico Desconhecido %
unaware_CD_diagnostico(ID) :- cuidadoID(ID, cuidado(_,_,_,_,DG,_)),atom(DG),
			      nao(excecao(diagnostico,cuidado(ID,_,_,_,_,_))),
                              learn(excecao(diagnostico,cuidado(ID,D,UID,PID,_,C)) :- 
	                	          cuidado(ID,D,UID,PID,DG,C)).

% Custo Desconhecido %
unaware_CD_custo(ID) :- cuidadoID(ID, cuidado(_,_,_,_,_,C)),atom(C),
			nao(excecao(custo,cuidado(ID,_,_,_,_,_))),
                        learn(excecao(custo,cuidado(ID,D,UID,PID,DG,_)) :- 
	                	    cuidado(ID,D,UID,PID,DG,C)).

%----------------------------%
%-> Conhecimento Impreciso <-%
%----------------------------%

%-> UTENTES <-%

% Nome Desconhecido dentro de um conjunto de valores [H|T] %
unaware_UT_nome(_,[]).
unaware_UT_nome(ID,[H|T]) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(N),
			     learn(excecao(nome,utente(ID,H,A,S,RUA,CDD,TEL))),unaware_UT_nome(ID,T).

% Idade Desconhecida dentro de um conjunto de valores entre Min e Max %
unaware_UT_idade(ID,Min,Max) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(A),
				learn(excecao(idade,utente(ID,N,Idade,S,RUA,CDD,TEL)) :- 
					(Idade >= Min, Idade =< Max)).

% Sangue Desconhecido dentro de um conjunto de valores [H|T] %					
unaware_UT_sangue(_,[]).
unaware_UT_sangue(ID,[H|T]) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(S),
			       learn(excecao(sangue,utente(ID,N,A,H,RUA,CDD,TEL))),unaware_UT_sangue(ID,T).

% Rua Desconhecida dentro de um conjunto de valores [H|T] %
unaware_UT_rua(_,[]).
unaware_UT_rua(ID,[H|T]) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(RUA),
			       learn(excecao(rua,utente(ID,N,A,S,H,CDD,TEL))),unaware_UT_rua(ID,T).

% Cidade Desconhecida dentro de um conjunto de valores [H|T] %
unaware_UT_cidade(_,[]).
unaware_UT_cidade(ID,[H|T]) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(CDD),
			       learn(excecao(cidade,utente(ID,N,A,S,RUA,H,TEL))),unaware_UT_cidade(ID,T).

% Contacto Desconhecido dentro de um conjunto de valores [H|T] %
unaware_UT_contacto(_,[]).
unaware_UT_contacto(ID,[H|T]) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,TEL)),atom(TEL),
			       learn(excecao(contacto,utente(ID,N,A,S,RUA,CDD,H))),unaware_UT_contacto(ID,T).

% Invariantes de Inserção de Exceções - Impede a inserção de excecoes repetidas %
+excecao(nome,utente(ID,N,A,S,RUA,CDD,TEL)) :: (solutions(N,excecao(nome,utente(ID,N,A,S,RUA,CDD,TEL)),R),len(R,C),C == 1).
+excecao(sangue,utente(ID,N,A,S,RUA,CDD,TEL)) :: (solutions(S,excecao(sangue,utente(ID,N,A,S,RUA,CDD,TEL)),R),len(R,C),C == 1).
+excecao(rua,utente(ID,N,A,S,RUA,CDD,TEL)) :: (solutions(RUA,excecao(rua,utente(ID,N,A,S,RUA,CDD,TEL)),R),len(R,C),C == 1).
+excecao(cidade,utente(ID,N,A,S,RUA,CDD,TEL)) :: (solutions(CDD,excecao(cidade,utente(ID,N,A,S,RUA,CDD,TEL)),R),len(R,C),C == 1).
+excecao(contacto,utente(ID,N,A,S,RUA,CDD,TEL)) :: (solutions(TEL,excecao(contacto,utente(ID,N,A,S,RUA,CDD,TEL)),R),len(R,C),C == 1).

%-> PRESTADORES <-%

% Nome Desconhecido dentro de um conjunto de valores [H|T] %
unaware_PRT_nome(_,[]).
unaware_PRT_nome(ID,[H|T]) :- prestadorID(ID,prestador(ID,N,ESP,I,CDD)),atom(N),
                              learn(excecao(nome,prestador(ID,H,ESP,I,CDD))),unaware_PRT_nome(ID,T).

% Especialidade Desconhecida dentro de um conjunto de valores [H|T] %
unaware_PRT_especialidade(_,[]).
unaware_PRT_especialidade(ID,[H|T]) :- prestadorID(ID,prestador(ID,N,ESP,I,CDD)),atom(ESP),
			 	       learn(excecao(especialidade,prestador(ID,N,H,I,CDD))),unaware_PRT_especialidade(ID,T).

% Instituicao Desconhecida dentro de um conjunto de valores [H|T] %
unaware_PRT_instituicao(_,[]).
unaware_PRT_instituicao(ID,[H|T]) :- prestadorID(ID,prestador(ID,N,ESP,I,CDD)),atom(I),
			             learn(excecao(instituicao,prestador(ID,N,ESP,H,CDD))),unaware_PRT_instituicao(ID,T).

% Cidade Desconhecida dentro de um conjunto de valores [H|T] %
unaware_PRT_cidade(_,[]).
unaware_PRT_cidade(ID,[H|T]) :- prestadorID(ID,prestador(ID,N,ESP,I,CDD)),atom(CDD),
			        learn(excecao(cidade,prestador(ID,N,ESP,I,H))),unaware_PRT_cidade(ID,T).

% Invariantes de Inserção de Exceções - Impede a inserção de excecoes repetidas %
+excecao(nome,prestador(ID,N,ESP,I,CDD)) :: (solutions(N,excecao(nome,prestador(ID,N,ESP,I,CDD)),R),len(R,C),C == 1).
+excecao(especialidade,prestador(ID,N,ESP,I,CDD)) :: (solutions(ESP,excecao(especialidade,prestador(ID,N,ESP,I,CDD)),R),len(R,C),C == 1).
+excecao(instituicao,prestador(ID,N,ESP,I,CDD)) :: (solutions(I,excecao(instituicao,prestador(ID,N,ESP,I,CDD)),R),len(R,C),C == 1).
+excecao(cidade,prestador(ID,N,ESP,I,CDD)) :: (solutions(CDD,excecao(cidade,prestador(ID,N,ESP,I,CDD)),R),len(R,C),C == 1).

%-> CUIDADOS <-%

% Data Desconhecida dentro de um conjunto de valores [H|T] %
unaware_CD_data(_,[]).
unaware_CD_data(ID,[H|T]) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,C)),
			     atom(D),atom(H),
			     learn(excecao(data,cuidado(ID,H,UID,PID,DG,C))),unaware_CD_data(ID,T).

% ID de Utente Descohecido dentro de um conjunto de valores entre Min e Max %
unaware_CD_uid(ID,Min,Max) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,C)),
			      atom(UID),integer(Min),integer(Max),
			      learn(excecao(uid,cuidado(ID,D,Uid,PID,DG,C)) :- Uid >= Min, Uid =< Max).

% ID de Prestador Desconhecido dentro de um conjunto de valores entre Min e Max %
unaware_CD_pid(ID,Min,Max) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,C)),
			      atom(PID),integer(Min),integer(Max),
			      learn(excecao(pid,cuidado(ID,H,Pid,PID,DG,C)) :- Pid >= Min, Pid =< Max).

% Diagnostico Desconhecido dentro de um conjunto de valores [H|T] %
unaware_CD_diagnostico(_,[]).
unaware_CD_diagnostico(ID,[H|T]) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,C)),atom(DG),atom(H),
			     learn(excecao(diagnostico,cuidado(ID,D,UID,PID,H,C))),unaware_CD_diagnostico(ID,T).

% Custo Desconhecido dentro de um conjunto de valores entre Min e Max %
unaware_CD_uid(ID,Min,Max) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,C)),
			      atom(C),integer(Min),integer(Max),
			      learn(excecao(custo,cuidado(ID,D,Uid,PID,DG,Custo)) :- Custo >= Min, Custo =< Max).

% Invariantes de Inserção de Exceções - Impede a inserção de excecoes repetidas %
+excecao(data,cuidado(ID,D,UID,PID,DG,C)) :: (solutions(D,excecao(data,cuidado(ID,D,UID,PID,DG,C)),R),len(R,C), C == 1).
+excecao(diagnostico,cuidado(ID,D,UID,PID,DG,C)) :: (solutions(DG,excecao(diagnostico,cuidado(ID,D,UID,PID,DG,C)),R),len(R,C), C == 1).

%--------------------------------%
%-> Interdição de Conhecimento <-%
%--------------------------------%

%-> UTENTES <-%

% Intedição de Nome %
disallow_UT_nome(ID) :- utenteID(ID,utente(_,N,_,_,_,_,_)),
			learn(nulo(N)),
	                learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Nome,(utente(ID,Nome,_,_,_,_,_),nao(nulo(Nome))),L),len(L,C),C == 0)).

% Interdiçao de Idade %
disallow_UT_idade(ID) :- utenteID(ID,utente(_,_,A,_,_,_,_)),
		         learn(nulo(A)),
	                 learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Idade,(utente(ID,_,Idade,_,_,_,_),nao(nulo(Idade))),L),len(L,C),C == 0)).

% Interdição de Sangue %
disallow_UT_sangue(ID) :- utenteID(ID,utente(_,_,_,S,_,_,_)),
			  learn(nulo(S)),
	                  learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Sangue,(utente(ID,_,_,Sangue,_,_,_),nao(nulo(Sangue))),L),len(L,C),C == 0)).

% Interdição de Rua %
disallow_UT_rua(ID) :- utenteID(ID,utente(_,_,_,_,RUA,_,_)),
		       learn(nulo(RUA)),
	               learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Rua,(utente(ID,_,_,_,Rua,_,_),nao(nulo(Rua))),L),len(L,C),C == 0)).

% Interdição de Cidade %
disallow_UT_cidade(ID) :- utenteID(ID,utente(_,_,_,_,_,CDD,_)),
			  learn(nulo(CDD)),
	                  learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Cidade,(utente(ID,_,_,_,_,Cidade,_),nao(nulo(Cidade))),L),len(L,C),C == 0)).

% Interdição de Contacto %
disallow_UT_contacto(ID) :- utenteID(ID,utente(_,_,_,_,_,_,TEL)),
			    learn(nulo(TEL)),
	                    learn(+utente(ID,_,_,_,_,_,_) :: (solutions(Contacto,(utente(ID,_,_,_,_,_,contacto),nao(nulo(Contacto))),L),len(L,C),C == 0)).

%-> PRESTADORES <-%

% Interdição de Nome %
disallow_PRT_nome(ID) :- prestadorID(ID,prestador(_,N,_,_,_)),
			 learn(nulo(N)),
			 learn(+prestador(ID,_,_,_,_) :: (solutions(Nome,(prestador(ID,Nome,_,_,_),nao(nulo(Nome))),L),len(L,C),C == 0)).

% Interdição de Especialidade %
disallow_PRT_especialidade(ID) :- prestadorID(ID,prestador(_,_,ESP,_,_)),
			 	  learn(nulo(ESP)),
			 	  learn(+prestador(ID,_,_,_,_) :: (solutions(Especialidade,(prestador(ID,_,Especialidade,_,_),nao(nulo(Especialidade))),L),len(L,C),C == 0)).

% Interdição de Instituição %
disallow_PRT_instituicao(ID) :- prestadorID(ID,prestador(_,_,_,I,_)),
			        learn(nulo(I)),
			        learn(+prestador(ID,_,_,_,_) :: (solutions(Instituicao,(prestador(ID,_,_,Instituicao,_),nao(nulo(Instituicao))),L),len(L,C),C == 0)).

% Interdição de Cidade %
disallow_PRT_cidade(ID) :- prestadorID(ID,prestador(_,_,_,_,CDD)),
			   learn(nulo(CDD)),
			   learn(+prestador(ID,_,_,_,_) :: (solutions(Cidade,(prestador(ID,_,_,_,Cidade),nao(nulo(Cidade))),L),len(L,C),C == 0)).

%-> CUIDADOS <-%

% Interdição de Data %
disallow_CD_data(ID) :- cuidadoID(ID,cuidado(_,D,_,_,_,_)),
			learn(nulo(D)),
			learn(+cuidado(ID,_,_,_,_,_) :: (solutions(Data,(cuidado(ID,Data,_,_,_,_),nao(nulo(Data))),L),len(L,C),C == 0)).

% Interdição de ID de Utente %
disallow_CD_uid(ID) :- cuidadoID(ID,cuidado(_,_,UID,_,_,_)),
		       learn(nulo(UID)),
		       learn(+cuidado(ID,_,_,_,_,_) :: (solutions(Uid,(cuidado(ID,_,Uid,_,_,_),nao(nulo(Uid))),L),len(L,C),C == 0)).

% Interdição de ID de Prestador %
disallow_CD_pid(ID) :- cuidadoID(ID,cuidado(_,_,_,PID,_,_)),
		       learn(nulo(PID)),
	               learn(+cuidado(ID,_,_,_,_,_) :: (solutions(Pid,(cuidado(ID,_,Pid,_,_,_),nao(nulo(Pid))),L),len(L,C),C == 0)).

% Interdição de Diagnóstico %
disallow_CD_diagnostico(ID) :- cuidadoID(ID,cuidado(_,_,_,_,DG,_)),
			       learn(nulo(DG)),
			       learn(+cuidado(ID,_,_,_,_,_) :: (solutions(Diagnostico,(cuidado(ID,_,_,_,Diagnostico,_),nao(nulo(Diagnostico))),L),len(L,C),C == 0)).

% Interdição de Custo %
disallow_CD_custo(ID) :- cuidadoID(ID,cuidado(_,_,_,_,_,C)),
			 learn(nulo(C)),
			 learn(+cuidado(ID,_,_,_,_,_) :: (solutions(Custo,(cuidado(ID,_,_,_,_,Custo),nao(nulo(Custo))),L),len(L,C),C == 0)).

% Invariante de inserção de Interdições - Impede interdições duplicadas %
+nulo(N) :: (solutions(N,nulo(N),R),len(R,C),C==1).

%---------------------------------------------%
%-> Evolução de Conhecimento Imperfeito     <-%
%---------------------------------------------%

%-> UTENTES <-%

% Evolui Nome %
learn_UT_nome(ID,Nome) :- utenteID(ID,utente(ID,X,A,S,RUA,CDD,TEL)),
			  atom(X),atom(Nome),
			  retractall(excecao(nome,utente(ID,_,_,_,_,_,_))),
			  replace(utente(ID,X,A,S,RUA,CDD,TEL),utente(ID,Nome,A,S,RUA,CDD,TEL)).
% Evolui Idade %
learn_UT_idade(ID,Idade) :- utenteID(ID,utente(ID,N,X,S,RUA,CDD,TEL)),
			    atom(X),integer(Idade),
			    retractall(excecao(idade,utente(ID,_,_,_,_,_,_))),
			    replace(utente(ID,N,X,S,RUA,CDD,TEL),utente(ID,N,Idade,S,RUA,CDD,TEL)).

% Evolui Sangue %
learn_UT_sangue(ID,Sangue) :- utenteID(ID,utente(ID,N,A,X,RUA,CDD,TEL)),
			      atom(X),atom(Sangue),
			      retractall(excecao(sangue,utente(ID,_,_,_,_,_,_))),
			      replace(utente(ID,N,A,X,RUA,CDD,TEL),utente(ID,N,A,Sangue,RUA,CDD,TEL)).

% Evolui Rua %
learn_UT_rua(ID,Rua) :- utenteID(ID,utente(ID,N,A,S,X,CDD,TEL)),
			atom(X),atom(Rua),
			retractall(excecao(rua,utente(ID,_,_,_,_,_,_))),
		        replace(utente(ID,N,A,S,X,CDD,TEL),utente(ID,N,A,S,Rua,CDD,TEL)).

% Evolui Cidade %
learn_UT_cidade(ID,Cidade) :- utenteID(ID,utente(ID,N,A,S,RUA,X,TEL)),
			      atom(X),atom(Cidade),
			      retractall(excecao(cidade,utente(ID,_,_,_,_,_,_))),
			      replace(utente(ID,N,A,S,RUA,X,TEL),utente(ID,N,A,S,RUA,Cidade,TEL)).

% Evolui Contacto %
learn_UT_contacto(ID,Contacto) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,X)),
			          atom(X),atom(Contacto),
				  retractall(excecao(contacto,utente(ID,_,_,_,_,_,_))),
			          replace(utente(ID,N,A,S,RUA,CDD,X),utente(ID,N,A,S,RUA,CDD,Contacto)).

%-> PRESTADORES <-%

% Evolui Nome %
learn_PRT_nome(ID,Nome) :- prestadorID(ID,prestador(ID,X,ESP,I,CDD)),
			    atom(X),atom(Nome),
			    retractall(excecao(nome,prestador(ID,_,_,_,_))),
			    replace(prestador(ID,X,ESP,I,CDD),prestador(ID,Nome,ESP,I,CDD)).

% Evolui Especialidade %
learn_PRT_especialidade(ID,Especialidade) :- prestadorID(ID,prestador(ID,N,X,I,CDD)),
		                              atom(X),atom(Especialidade),
					      retractall(excecao(especialidade,prestador(ID,_,_,_,_))),
			    		      replace(prestador(ID,N,X,I,CDD),prestador(ID,N,Especialidade,I,CDD)).

% Evolui Instituicao %
learn_PRT_instituicao(ID,Instituicao) :- prestadorID(ID,prestador(ID,N,ESP,X,CDD)),
			   		  atom(X),atom(Instituicao),
					  retractall(excecao(instituicao,prestador(ID,_,_,_,_))),
			                  replace(prestador(ID,N,ESP,X,CDD),prestador(ID,N,ESP,Instituicao,CDD)).

% Evolui Cidade %
learn_PRT_cidade(ID,Cidade) :- prestadorID(ID,prestador(ID,N,ESP,I,X)),
			        atom(X),atom(Cidade),
				retractall(excecao(cidade,prestador(ID,_,_,_,_))),
			        replace(prestador(ID,N,ESP,I,X),prestador(ID,N,ESP,I,Cidade)).

%-> CUIDADOS <-%

% Evolui Data %
learn_CD_data(ID,D) :- cuidadoID(ID,cuidado(ID,X,UID,PID,DG,C)),
		       atom(X),atom(D),
		       retractall(excecao(data,cuidado(ID,_,_,_,_,_))),
		       replace(cuidado(ID,X,UID,PID,DG,C),cuidado(ID,D,UID,PID,DG,C)).

% Evolui ID de Utente %
learn_CD_uid(ID,idUT) :- cuidadoID(ID,cuidado(ID,D,X,PID,DG,C)),
		         atom(X),integer(idUT),
		         retractall(excecao(uid,cuidado(ID,_,_,_,_,_))),
		         replace(cuidado(ID,D,X,PID,DG,C),cuidado(ID,D,idUT,PID,DG,C)).

% Evolui ID de Prestador %
learn_CD_pid(ID,idPRT) :- cuidadoID(ID,cuidado(ID,D,UID,X,DG,C)),
		          atom(X),integer(idPRT),
		          retractall(excecao(pid,cuidado(ID,_,_,_,_,_))),
		          replace(cuidado(ID,D,UID,X,DG,C),cuidado(ID,D,UID,idPRT,DG,C)).

% Evolui Diagnostico %
learn_CD_diagnostico(ID,Diagnostico) :- cuidadoID(ID,cuidado(ID,D,UID,PID,X,C)),
		                        atom(X),atom(Diagnostico),
			                retractall(excecao(diagnostico,cuidado(ID,_,_,_,_,_))),
			                replace(cuidado(ID,D,UID,PID,X,C),cuidado(ID,D,UID,PID,Diagnostico,C)).

% Evolui Custo %
learn_CD_custo(ID,Custo) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,X)),
			    atom(X),integer(Custo),
			    retractall(excecao(custo,cuidado(ID,_,_,_,_,_))),
			    replace(cuidado(ID,D,UID,PID,DG,X),cuidado(ID,D,UID,PID,DG,Custo)).

%-----------------------------------------------%
%-> Predicado de substituição de conhecimento <-%
%-----------------------------------------------%

% replace : Old,New -> {V,F}
replace(Old, New) :- forget(Old), learn(New).
replace(Old, _) :- forget(Old), !, fail.
