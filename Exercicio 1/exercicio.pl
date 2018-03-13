:- set_prolog_flag(discontiguous_warnings,off).
:- set_prolog_flag(single_var_warnings,off).
:- set_prolog_flag(unknown,fail).

:- op(900,xfy,'::').
:- dynamic utente/4.
:- dynamic prestador/4.
:- dynamic cuidado/5.

%---------------------------------------------%
%----------- BASE DE CONHECIMENTO ------------%
%---------------------------------------------%

% utente: #IdUt, Nome, Idade, Morada -> {V,F} 
utente(1,'Utente1',1,'primeiro').
utente(2,'Utente2',2,'segundo').
utente(3,'Utente3',3,'terceiro')


% prestador: #IdPrest, Nome, Especialidade, Instituição -> {V,F}

prestador(1,'Prestador1','Especialidade1','Instituição1').
prestador(2,'Prestador2','Especialidade2','Instituição2').
prestador(3,'Prestador3','Especialidade3','Instituição3').


% cuidado: Data, #IdUt, #IdPrest, Descrição, Custo -> {V,F}

cuidado('1-1-2018',1,1,'Era rabeta',2).
cuidado('2-2-2018',2,2,'Tinha um lego no nariz',3).
cuidado('2-2-2018',2,3,'Pisou o lego, depois de o ter tirado do nariz',4).


%------------------------------------------------------------------%
%-> Extensão do predicado que permite a procura de conhecimento  <-%
%------------------------------------------------------------------%

solutions(X,Y,Z) :- findall(X,Y,Z).

%------------------------------------------------------------------%
%-> Extensão do predicado que permite a evolução do conhecimento <-%
%------------------------------------------------------------------%

insert(T) :- assert(T),
             retract(T),!,fail.

test([]).
test([H|T]) :- H,test(T).

length([],0).
length([H|T],R) :- length(T,C), R is 1+C.

learn(Term) :- solutions(I,+F::I,L),
	       insert(F),
	       test(L).

%-----------------------------------------------------------------%
%-> Extensão do predicado que permite a redução do conhecimento <-%
%-----------------------------------------------------------------%

remove(T) :- retract(T).

forget(Term) :- solutions(I,+F::I,L),
	        test(L),
            	remove(F).

%---------------------------------------------------------------------%
%-> Invariante Estrutural do Utente (não permite inserção repetida) <-%
%---------------------------------------------------------------------%

+utente(ID,N,A,Z) :- (solutions(ID,utente(ID,_,_,_),L),
		      length(L,N),
		      N is 1).

%------------------------------------------------------------------------%
%-> Invariante Estrutural do Prestador (não permite inserção repetida) <-%
%------------------------------------------------------------------------%

+prestador(ID,N,S,I) :- (solutions(ID,prestador(ID,_,_,_),L),
			 length(L,N),
			 N is 1).

%----------------------------------------------------------------------%
%-> Invariante Estrutural do Cuidado (não permite inserção repetida) <-%
%----------------------------------------------------------------------%

+cuidado(D,uID,pID,DSC,P) :- (solutions((D,uID,pID,DSC,P),cuidado(D,uID,pID,DSC,P),L),
			      length(L,N),
			      N is 1).
		      
		      
% Query 1
%- Registar utentes
utentRegist(id,n,a,z) :- learn(utente(id,n,a,z)).
%- Registar prestadores
prestRegist(id,n,s,i) :- learn(prestador(id,n,s,i)).
%- Registar cuidados
cuidaRegist(d,uid,pid,dsc,p) :- learn(cuidado(d,uid,pid,dsc,p)).

% Query 2
%- Remover utente
utentRemove(uid) :- forget(utente(uid,_,_,_)).
% ao remover utentes -> removemos os cuidados a ele prestados?

%- Remover prestador
prestRemove(pid) :- forget(pretador(pid,_,_,_)).
% ao remover prestadores -> removemos os cuidados por ele prestados?

%- Remover cuidado
cuidaRemove(d,uid,pid,dsc,p) :- forget(cuidado(d,uid,pid,dsc,p)).

% Query 3
%- Identificar utentes por critérios
utentID(ID,R) :- (solutions((ID,X,Y,Z),utente(,_,_,_),L)).
utentName(N,R) :- (solutions((X,N,Y,Z),utente(_,nm,_,_),L)).
utentAge(A,R) :- (solutions((X,Y,A,Z),utente(_,_,ag,_),L)).
utenteZone(Z,R) :- (solutions((X,Y,W,Z),utente(_,_,_,zn),L)). 

% Query 4		 

