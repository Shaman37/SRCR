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

% utente: #IdUt, Nome, Idade, Morada -> {V,F} % 
utente(1,'Utente1',1,'primeiro').
utente(2,'Utente2',2,'segundo').
utente(3,'Utente3',3,'terceiro').


% prestador: #IdPrest, Nome, Especialidade, Instituição, Cidade -> {V,F}

prestador(1,'Prestador1','Especialidade1','Instituição1','cidade1').
prestador(2,'Prestador2','Especialidade1','Instituição2','cidade2').
prestador(3,'Prestador3','Especialidade3','Instituição3','cidade3').


% cuidado: Data, #IdUt, #IdPrest, Descrição, Custo -> {V,F}


cuidado('1-1-2018',1,1,'Tinha um lego no nariz',3).
cuidado('2-2-2018',1,1,'Pisou o lego, depois de o ter tirado do nariz',4).
cuidado('2-2-2018',1,1,'Era rabeta',2).
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
utentRegist(ID,N,A,Z) :- learn(utente(ID,N,A,Z)).
%- Registar prestadores
prestRegist(ID,N,S,I,C) :- learn(prestador(ID,N,S,I,C)).
%- Registar cuidados
cuidaRegist(D,UID,PID,DSC,P) :- learn(cuidado(D,UID,PID,DSC,P)).

% Query 2
%- Remover utente
utentRemove(ID) :- forget(utente(ID,_,_,_)).
% ao remover utentes -> removemos os cuidados a ele prestados?

%- Remover prestador
prestRemove(ID) :- forget(prestador(ID,_,_,_,_)).
% ao remover prestadores -> removemos os cuidados por ele prestados?

%- Remover cuidado
cuidaRemove(D,UID,PID,DG,P) :- forget(cuidado(D,UID,PID,DG,P)).

% Query 3
%- Identificar utentes por critérios
utentID(ID,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utentName(N,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utentAge(A,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)).
utentZone(Z,R) :- (solutions(utente(ID,N,A,Z),utente(ID,N,A,Z),R)). 

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
utentesPrestador(PID,R) :- solutions(utente(UID,N,A,Z),(cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
			 repRemove(L1,LU),
			 sortL(LU,R).

%- especialidade
utentesEspecalidade(E,R) :- solutions(utente(UID,N,A,Z),(prestador(PID,_,E,_,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
		     repRemove(L1,LU),
		     sortL(LU,R).

%- instituicao
utentesInstituicoes(I,R) :- solutions(utente(UID,N,A,Z),(prestador(PID,_,_,I,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,Z)),L1),
		   	    repRemove(L1,LU),
		            sortL(LU,R).
% Query 7
%- Identificar cuidados de saúde realizados por utente/instituição/prestador

%- utente
cuidadosUtente(U,R) :- solutions(cuidado(D,U,PID,DG,C),cuidado(D,U,PID,DG,C),R).

%- instituicao
cuidadosInst(I,R) :- solutions(ID,prestador(ID,_,_,I,_),LP),
		     cuidadosPL(LP,R).

%- prestador
cuidadosPrest(P,R) :- solutions(cuidado(D,IU,P,DG,C),cuidado(D,IU,P,DG,C),R).

% Query 8
%- Determinar todas as instituições/prestadores a que um utente já recorreu
		         
%- instituicoes
instituicoesUtente(UID,R) :- solutions((I,C),(cuidado(_,UID,PID,_,_),prestador(PID,_,_,I,C)),L1),
			     repRemove(L1,LI),
			     sortL(L1,R).

%- prestadores
prestadoresUtente(U,R) :- solutions(prestador(ID,N,E,I,C),(cuidado(_,U,ID,_,_),prestador(ID,N,E,I,C)),L1),
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
custoData(D,R) :- solutions(C,cuidado(D,_,_,_,C),LC),
		  sumL(LC,R).

%--
concat([],L2,L2).
concat(L1,[],L1).
concat([X|L1],L2,[X|L]) :- concat(L1,L2,L).

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
