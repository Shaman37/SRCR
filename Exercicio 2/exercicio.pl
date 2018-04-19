:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( unknown,fail ).
:- set_prolog_flag( answer_write_options,[max_depth(0)] ).

:- op( 400, yfx, '&&').
:- op( 400, yfx, '$$').
:- op( 600, xfx, 'eq').
:- op( 900,xfy,'::' ).

:- style_check(-discontiguous).
:- dynamic (-)/1.
:- dynamic excecao/1.
:- dynamic utente/7.
:- dynamic prestador/5.
:- dynamic cuidado/6.
:- dynamic sangue/2.

:- include(knowledge).
:- include(functionalities).

%----------------------%
% TABELA DE INFERÊNCIA %
%----------------------%

equal(Verdadeiro  , &&(Verdadeiro  , Verdadeiro)).
equal(Desconhecido, &&(Desconhecido, Verdadeiro)).
equal(Desconhecido, &&(Verdadeiro  , Deconhecido)).
equal(Desconhecido, &&(Desconhecido, Desconhecido)).
equal(Falso       , &&(Falso       , _)).
equal(Falso       , &&(_           , Falso)).

equal(Falso       , $$(Falso       , Falso)).
equal(Desconhecido, $$(Falso       , Desconhecido)).
equal(Desconhecido, $$(Desconhecido, Falso)).
equal(Desconhecido, $$(Desconhecido, Desconhecido)).
equal(Verdadeiro  , $$(Verdadeiro  , _)).
equal(Verdadeiro  , $$(_           , Verdadeiro)).

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

+utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(ID,(utente(ID,_,_,_,_,_,_)),L),
		                  len(L,C),
		                  C == 1).

+utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(TEL,(utente(_,_,_,_,_,_,TEL)),L),
		                 len(L,C),
				 C == 1).

+utente(ID,N,A,S,RUA,CDD,TEL) :: (sangue(S,_)).


-utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(ID,(utente(ID,N,A,S,RUA,CDD,TEL)),L),
		                  len(L,C),
		                  C == 1).

-utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(TEL,(utente(ID,N,A,S,RUA,CDD,TEL)),L),
		                 len(L,C),
		                 C == 1).

%-----------------------------%
%-> INVARIANTES [PRESTADOR] <-%
%-----------------------------%

+prestador(ID,N,ESP,I,CDD) :: (solutions(ID,(prestador(ID,_,_,_,_)),L),
			      len(L,C),
			      C == 1).

+prestador(ID,N,ESP,I,CDD) :: (solutions(ID,(prestador(ID,N,ESP,I,CDD)),L),
			      len(L,C),
			      C == 1).	
		     
%---------------------------%
%-> INVARIANTES [CUIDADO] <-%
%---------------------------%

+cuidado(ID,D,UID,PID,DG,P) :: (solutions((ID,D,UID,PID,DG,P),(cuidado(ID,D,UID,PID,DG,P)),L),
			     len(L,C),
			     C == 1).

+cuidado(ID,D,UID,PID,DG,P) :: ((utente(UID,_,_,_,_,_,_)),(prestador(PID,_,_,_,_))).



%------------------------------------------------------------%
%-> Extensão dos meta-predicados demo, demoConj e demoDisj <-%
%------------------------------------------------------------%

% demo : Q -> {V,F,D}
demo(Questao,Verdadeiro) :- Questao.
demo(Questao,Falso) :- -Questao,!,fail.
demo(Questao,Desconhecido) :- nao(Questao),nao(-Questao).

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
				 nao(execao(utente(ID,N,A,S,RUA,CDD,TEL))).

-prestador(ID,N,ESP,I,CDD) :- nao(prestador(ID,N,ESP,I,CDD)),
			      nao(execao(prestador(ID,N,ESP,I,CDD))).

-cuidado(D,UID,PID,DG,P) :- nao(cuidado(ID,D,UID,PID,DG,P)),
			    nao(execao(cuidado(ID,D,UID,PID,DG,P))).

%-> Negação Forte <-%

-utente(37,'João',45,'AB','Rua do Raio','Braga','911271020').
-prestador(45,'Ana','Medicina Geral','Hospital de Braga','Braga').
-cuidado(30,'2018-04-20',12,7,'Gastroentrite',61.23).

%---------------------------------------------%
%-> Declaração de Conhecimento Imperfeito   <-%
%---------------------------------------------%

%-> UTENTES <-%

desconhecer_UT_nome(ID) :- utenteID(ID, utente(_,N,_,_,_,_,_)),atom(N),
			   assert(excecao(utente(UID,_,A,S,RUA,CDD,TEL)) :- 
			   utente(UID,N,A,S,RUA,CDD,TEL)).

desconhecer_UT_idade(ID) :- utenteID(ID, utente(_,_,A,_,_,_,_)),atom(A),
			    assert(excecao(utente(UID,N,_,S,RUA,CDD,TEL)) :- 
			    utente(UID,N,A,S,RUA,CDD,TEL)).

desconhecer_UT_sangue(ID) :- utenteID(ID, utente(_,_,_,S,_,_,_)),atom(S),
			     assert(excecao(utente(UID,N,A,_,RUA,CDD,TEL)) :- 
		             utente(UID,N,A,S,RUA,CDD,TEL)).

desconhecer_UT_rua(ID) :- utenteID(ID, utente(_,_,_,_,RUA,_,_)),atom(RUA),
			  assert(excecao(utente(UID,N,A,S,_,CDD,TEL)) :- 
	  	          utente(UID,N,A,S,RUA,CDD,TEL)).
			   
desconhecer_UT_cidade(ID) :- utenteID(ID, utente(_,_,_,_,_,CDD,_)),atom(CDD),
			     assert(excecao(utente(UID,N,A,S,RUA,_,TEL)) :- 
		             utente(UID,N,A,S,RUA,CDD,TEL)).

desconhecer_UT_contacto(ID) :- utenteID(ID, utente(_,_,_,_,_,_,TEL)),atom(TEL),
			       assert(excecao(utente(UID,_,A,S,RUA,CDD,_)) :- 
			       utente(UID,N,A,S,RUA,CDD,TEL)).

%-> PRESTADORES <-%

desconhecer_PRT_nome(ID) :- prestador(ID, prestador(_,N,_,_,_)),atom(N),
			    assert(excecao(prestador(PID,_,ESP,I,CDD)) :- 
		            prestador(PID,N,ESP,I,CDD)).

desconhecer_PRT_especialidade(ID) :- prestador(ID, prestador(_,_,ESP,_,_)),atom(ESP),
			    	     assert(excecao(prestador(PID,N,_,I,CDD)) :- 
				     prestador(PID,N,ESP,I,CDD)).

desconhecer_PRT_instituicao(ID) :- prestador(ID, prestador(_,_,_,I,_)),atom(I),
			           assert(excecao(prestador(PID,N,ESP,_,CDD)) :- 				 
			           prestador(PID,N,ESP,I,CDD)).

desconhecer_PRT_cidade(ID) :- prestador(ID, prestador(_,_,_,_,CDD)),atom(CDD),
			      assert(excecao(prestador(PID,N,ESP,I,_)) :- 
		              prestador(PID,N,ESP,I,CDD)).

%-> CUIDADOS <-%

desconhecer_CD_data(ID) :- cuidado(ID, cuidado(_,D,_,_,_,_)),atom(D),
			   assert(excecao(cuidado(CID,_,UID,PID,DG,C)) :- 
		           cuidado(CID,D,UID,PID,DG,C)).

desconhecer_CD_uID(ID) :- cuidado(ID, cuidado(_,_,UID,_,_,_)),atom(UID),
                          assert(excecao(cuidado(CID,D,_,PID,DG,C)) :- 
	                  cuidado(CID,D,UID,PID,DG,C)).

desconhecer_CD_pID(ID) :- cuidado(ID, cuidado(_,_,_,PID,_,_)),atom(PID),
                          assert(excecao(cuidado(CID,D,UID,_,DG,C)) :- 
                          cuidado(CID,D,UID,PID,DG,C)).

desconhecer_CD_diagnostico(ID) :- cuidado(ID, cuidado(_,_,_,_,DG,_)),atom(DG),
                                  assert(excecao(cuidado(CID,D,UID,PID,_,C)) :- 
	                          cuidado(CID,D,UID,PID,DG,C)).

desconhecer_CD_custo(ID) :- cuidado(ID, cuidado(_,_,_,_,_,C)),atom(C),
                            assert(excecao(cuidado(CID,D,UID,PID,DG,_)) :- 
	                    cuidado(CID,D,UID,PID,DG,C)).


%---------------------------------------------%
%-> Evolução de Conhecimento Imperfeito     <-%
%---------------------------------------------%

%-> UTENTES <-%

learn_UT_nome(ID,Nome) :- utenteID(ID,utente(ID,X,A,S,RUA,CDD,TEL)),
			  atom(X),nao(atom(Nome)),
			  replace(utente(ID,X,A,S,RUA,CDD,TEL),utente(ID,Nome,A,S,RUA,CDD,TEL)).

learn_UT_idade(ID,Idade) :- utenteID(ID,utente(ID,N,X,S,RUA,CDD,TEL)),
			    atom(X),nao(atom(Idade)),
			    replace(utente(ID,N,X,S,RUA,CDD,TEL),utente(ID,N,Idade,S,RUA,CDD,TEL)).

learn_UT_sangue(ID,Sangue) :- utenteID(ID,utente(ID,N,A,X,RUA,CDD,TEL)),
			      atom(X),nao(atom(Sangue)),
			      replace(utente(ID,N,A,X,RUA,CDD,TEL),utente(ID,N,A,Sangue,RUA,CDD,TEL)).

learn_UT_rua(ID,Rua) :- utenteID(ID,utente(ID,N,A,S,X,CDD,TEL)),
			atom(X),nao(atom(Rua)),
		        replace(utente(ID,N,A,S,X,CDD,TEL),utente(ID,N,A,S,Rua,CDD,TEL)).

learn_UT_cidade(ID,Cidade) :- utenteID(ID,utente(ID,N,A,S,RUA,X,TEL)),
			      atom(X),nao(atom(Cidade)),
			      replace(utente(ID,N,A,S,RUA,X,TEL),utente(ID,N,A,S,RUA,Cidade,TEL)).

learn_UT_contacto(ID,Contacto) :- utenteID(ID,utente(ID,N,A,S,RUA,CDD,X)),
			          atom(X),nao(atom(Contacto)),
			          replace(utente(ID,N,A,S,RUA,CDD,X),utente(ID,N,A,S,RUA,CDD,Contacto)).

%-> PRESTADORES <-%

learn_PRT_nome(ID,Nome) :- prestadorID(ID,prestador(ID,X,ESP,I,CDD)),
			    atom(X),nao(atom(Nome)),
			    replace(prestador(ID,X,ESP,I,CDD),prestador(ID,Nome,ESP,I,CDD)).

learn_PRT_especialidade(ID,Especialidade) :- prestadorID(ID,prestador(ID,N,X,I,CDD)),
		                              atom(X),nao(atom(Especialidade)),
			    		      replace(prestador(ID,N,X,I,CDD),prestador(ID,N,Especialidade,I,CDD)).

learn_PRT_instituicao(ID,Instituicao) :- prestadorID(ID,prestador(ID,N,ESP,X,CDD)),
			   		  atom(X),nao(atom(Instituicao)),
			                  replace(prestador(ID,N,ESP,X,CDD),prestador(ID,N,ESP,Instituicao,CDD)).

learn_PRT_cidade(ID,Cidade) :- prestadorID(ID,prestador(ID,N,ESP,I,X)),
			        atom(X),nao(atom(Cidade)),
			        replace(prestador(ID,N,ESP,I,X),prestador(ID,N,ESP,I,Cidade)).

%-> CUIDADOS <-%

learn_CD_data(ID,Data) :- cuidadoID(ID,cuidado(ID,X,UID,PID,DG,C)),
			   atom(X),nao(atom(Data)),
			   replace(cuidado(ID,X,UID,PID,DG,C),cuidado(ID,Data,UID,PID,DG,C)).

learn_CD_idUT(ID,idUT) :- cuidadoID(ID,cuidado(ID,D,X,PID,DG,C)),
			   atom(X),nao(atom(idUT)),
			   replace(cuidado(ID,D,X,PID,DG,C),cuidado(ID,D,idUT,PID,DG,C)).

learn_CD_idPRT(ID,idPRT) :- cuidadoID(ID,cuidado(ID,D,UID,X,DG,C)),
			   atom(X),nao(atom(idPRT)),
			   replace(cuidado(ID,D,UID,X,DG,C),cuidado(ID,D,UID,idPRT,DG,C)).

learn_CD_data(ID,Diagnostico) :- cuidadoID(ID,cuidado(ID,D,UID,PID,X,C)),
			   atom(X),nao(atom(Diagnostico)),
			   replace(cuidado(ID,D,UID,PID,X,C),cuidado(ID,D,UID,PID,Diagnostico,C)).

learn_CD_data(ID,Custo) :- cuidadoID(ID,cuidado(ID,D,UID,PID,DG,X)),
			   atom(X),nao(atom(Custo)),
			   replace(cuidado(ID,D,UID,PID,DG,X),cuidado(ID,D,UID,PID,DG,Custo)).


