:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( unknown,fail ).
:- set_prolog_flag( answer_write_options,[max_depth(0)] ).

:- op( 900,xfy,'::' ).
:- dynamic sangue/2.
:- use_module(knowledge).
%---------------------------------------------%
%----------- BASE DE CONHECIMENTO ------------%
%---------------------------------------------%

% sangue: Tipo do Recetor, Tipo do Dador -> {V,F}
sangue('A','A').
sangue('A','O').
sangue('B','B').
sangue('B','O').
sangue('AB','A').
sangue('AB','B').
sangue('AB','O').
sangue('O','O').

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

+utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(ID,(utente(ID,N,A,S,RUA,CDD,TEL)),L),
		      len(L,C),
		      C == 1).


+utente(ID,N,A,S,RUA,CDD,TEL) :: (solutions(TEL,(utente(ID,N,A,S,RUA,CDD,TEL)),L),
		      len(L,C),
		      C == 1).

+utente(ID,N,A,S,RUA,CDD,TEL) :: (sangue(S,_)).

%------------------------------------------------------------------------%
%-> Invariante Estrutural do Prestador (não permite inserção repetida) <-%
%------------------------------------------------------------------------%

+prestador(ID,N,ESP,I,CDD) :: (solutions(ID,(prestador(ID,N,ESP,I,CDD)),L),
			 len(L,C),
			 C == 1).

%----------------------------------------------------------------------%
%-> Invariante Estrutural do Cuidado (não permite inserção repetida) <-%
%----------------------------------------------------------------------%

+cuidado(D,UID,PID,DG,P) :: (solutions((D,UID,PID,DG,P),(cuidado(D,UID,PID,DG,P)),L),
			     len(L,C),
			     C == 1).

+cuidado(D,UID,PID,DG,P) :: ((utente(UID,_,_,_,_,_,_)),(prestador(PID,_,_,_,_))).

%---------%
% Query 1 %
%---------%

%- Registar utentes
registaUtente(ID,N,A,S,RUA,CDD,TEL) :- learn(utente(ID,N,A,S,RUA,CDD,TEL)).

%- Registar prestadores
registaPrestador(ID,N,S,I,C) :- learn(prestador(ID,N,S,I,C)).

%- Registar cuidados
registaCuidado(D,UID,PID,DSC,P) :- learn(cuidado(D,UID,PID,DSC,P)).

%---------%
% Query 2 %
%---------%
%
%- Remover utente
removeUtente(ID) :- forget(utente(ID,_,_,_,_,_,_)).

%- Remover prestador
removePrestador(ID) :- forget(prestador(ID,_,_,_,_)).

%- Remover cuidado
removeCuidado(D,UID,PID,DG,P) :- forget(cuidado(D,UID,PID,DG,P)).

%---------%
% Query 3 %
%---------%

%- Identificar utentes por critérios
utenteID(ID,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),R)).
utenteName(N,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R).
utenteIdade(A,R) :- (solutions(utente(ID,N,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R).
utenteRua(RUA,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R). 
utenteCidade(CDD,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R). 
utenteContacto(TEL,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),R)). 

%---------%
% Query 4 %
%---------%
		 
%- Identificar Instituições prestadoras de saúde
instituicoesPrestadoras(R) :- solutions((C,I),(cuidado(_,_,PID,_,_),prestador(PID,_,_,I,C)),L1),
		              repRemove(L1,LI),
			      sortL(LI,R).

cidadesPrestadoras(R) :- solutions(CDD,(cuidado(_,_,PID,_,_),prestador(PID,_,_,I,CDD)),L1),
		         repRemove(L1,LI),
 		         sortL(LI,R).
%---------%
% Query 5 %
%---------%

%- Identificar cuidados de saúde prestados por instituição/cidade/datas

%-> Por instituicao
cuidadosInstituicao(I,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(D,UID,PID,DG,C)),LC),
		  	    sortL(LC,R).

%-> Por cidade
cuidadosCidade(CDD,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,_,CDD),cuidado(D,UID,PID,DG,C)),LC),
		         sortL(LC,R).

%-> Por data
cuidadosData(D,R) :- solutions((D,IU,IP,DG,C),cuidado(D,IU,IP,DG,C),LC),sortL(LC,R).	      

%---------%
% Query 6 %
%---------%

%- Identificar os utentes de um prestador/especialidade/instituição

%-> prestador
utentes_P(PID,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(cuidado(_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
	            repRemove(L1,LU),
	            sortL(LU,R).

%-> especialidade
utentes_ESP(E,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(prestador(PID,_,E,_,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
		    repRemove(L1,LU),
		    sortL(LU,R).

%-> instituicao
utentes_I(I,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(prestador(PID,_,_,I,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
		  repRemove(L1,LU),
		  sortL(LU,R).

%---------%
% Query 7 %
%---------%

%- Identificar cuidados de saúde realizados por utente/instituição/prestador

%-> utente
cuidados_UT(UID,R) :- solutions(cuidado(D,UID,PID,DG,C),cuidado(D,UID,PID,DG,C),LC),
		      sortL(LC,R).

%-> instituicao
cuidados_I(I,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(D,UID,PID,DG,C)),LC),
		   sortL(LC,R).

%-> prestador
cuidados_P(PID,R) :- solutions(cuidado(D,UID,PID,DG,C),cuidado(D,UID,PID,DG,C),LC),
		     sortL(LC,R).

%---------%
% Query 8 %
%---------%

%- Determinar todas as instituições/prestadores a que um utente já recorreu
		         
%-> instituicoes
instituicoes_UT(UID,R) :- solutions((C,I),(cuidado(_,UID,PID,_,_),prestador(PID,_,_,I,C)),L1),
			  repRemove(L1,LI),
			  sortL(LI,R).

%-> prestadores
prestadores_UT(UID,R) :- solutions(prestador(PID,N,E,I,C),(cuidado(_,UID,PID,_,_),prestador(PID,N,E,I,C)),L1),
			  repRemove(L1,LP),
			  sortL(LP,R).
%---------%
% Query 9 %
%---------%

% Calcular custo por Utente
custoUtente(UID) :- solutions(C,cuidado(_,UID,_,_,C),LC),
		    sumL(LC,T),
		    write('ID do Utente: '),write(UID),nl,
		    write('Despesa Médica: '),write(T),write('€'),nl.
                     

% Calcular custo por Especialidade 
custoEspecialidade(E) :- solutions(C,(prestador(PID,_,E,_,_),cuidado(_,_,PID,_,C)),LC),
			   sumL(LC,T),
		           write('Especialidade Médica: '),write(E),nl,
		 	   write('Rendimento: '),write(T),write('€'),nl.


% Calcular custo por Prestador
custoPrestador(PID) :- solutions(C,cuidado(_,_,PID,_,C),LC),
			 sumL(LC,T),
			 write('ID do Prestador: '),write(PID),nl,
			 write('Rendimento :'),write(T),write('€'),nl.


% Calcular custo por Datas
custoData(D) :- solutions(C,cuidado(D,_,_,_,C),LC),
		sumL(LC,T),
		write('Data (Ano-Mês-Dia): '),write(D),nl,
		write('Balanço Diário): '),write(T),write('€'),nl.

%------------------------%
% FUNCIONALIDADES EXTRAS %
%------------------------%

% EXTRA 01 - Doadores %

% Doadores para o Tipo de Sangue 'S'
doadoresTipo(S,R) :- solutions(utente(ID,N,A,D,RUA,CDD,TEL),(sangue(S,D),utente(ID,N,A,D,RUA,CDD,TEL)),LU),sortL(LU,R).

% Doadores para o Tipo de Sangue 'S' de uma dada cidade 'CDD'
doadoresCidade(S,CDD,R) :- solutions(utente(ID,N,A,D,RUA,CDD,TEL),(sangue(S,D),utente(ID,N,A,D,RUA,CDD,TEL)),LU), sortL(LU,R).

% Doadores para o Tipo de Sangue 'S' de uma dada instituição 'I'
doadoresInstituicao(S,I,R) :- solutions(utente(UID,N,A,D,RUA,CDD,TEL),
		              (sangue(S,D),prestador(PID,_,_,I,_),cuidado(_,UID,PID,_,_),utente(UID,N,A,D,RUA,CDD,TEL)),LU), 
			      sortL(LU,R).

% EXTRA 02 - Despesas e Rendimentos intervalados %

% Despesa Médica de um Utente desde a data 'D1' até à data 'D2'
despesaEntre_UT(UID,D1,D2) :- ((utente(UID,_,_,_,_,_,_)) -> 
			          
			           solutions(C,(cuidado(D,UID,_,_,C),(D1 @=< D),(D @=< D2)),LC),
			           sumL(LC,T),
			   	   write('ID do Utente: '),write(UID),nl,
		   		   write('Despesa Médica, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Utente inexistente'),fail).

% Rendimento de um Prestador desde a data 'D1' até à data 'D2'
rendimentoEntre_P(PID,D1,D2) :- ((prestador(PID,_,_,_,_)) ->
			   
       			           solutions(C,(cuidado(D,_,PID,_,C),(D1 @=< D),(D @=< D2)),LC),
			           sumL(LC,T),
			   	   write('ID do Prestador: '),write(PID),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Prestador inexistente'),fail).

% Rendimento de uma Instituição desde a data 'D1' até à data 'D2'
rendimentoEntre_I(I,D1,D2) :- ((prestador(_,_,_,I,_)) ->

				   solutions(C,(prestador(PID,_,_,I,_),cuidado(D,_,PID,_,C),(D1 @=< D),(D @=< D2)),LC),
			           sumL(LC,T),
			   	   write('Instituição: '),write(I),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Instituição inexistente'),fail).

% Rendimento de uma Especialdiade desde a data 'D1' até _à data 'D2'
rendimentoEntre_ESP(E,D1,D2) :- ((prestador(_,_,E,_,_)) ->
		
				   solutions(C,(prestador(PID,_,E,_,_),cuidado(D,_,PID,_,C),(D1 @=<D),(D @=< D)),LC),
				   sumL(LC,T),
			   	   write('Especialidade Médica: '),write(E),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Especialidade inexistente'),fail).

% EXTRA 03 - Guardar o estado atual do programa num ficheiro, alterando o módulo que contem a nossa base de conhecimento de utentes,
% 	     prestadores e cuidados, sendo este novamente acedido quando o programa for corrido.

% Guarda estado atual do programa no ficheiro
save() :-  telling(OldStream), tell('knowledge.pl'),
		       write(':- module(database,[utente/7, prestador/5, cuidado/5]).'),nl,
		       write(':- dynamic utente/7.'),nl,
		       write(':- dynamic prestador/5.'),nl,
		       write(':- dynamic cuidado/5.'),nl,nl,

		       write('% utente: #IdUt, Nome, Idade, Tipo de Sangue, Rua, Cidade, Contacto -> {V,F}'),nl,
		       getUtentes(LU),
		       utenteSave(LU),nl,

		       write('% prestador: #IdPrest, Nome, Especialidade, Instituição, Cidade -> {V,F}'),nl,
		       getPrestadores(LP),
		       prestadorSave(LP),nl,

		       write('% cuidado: Data, #IdUt, #IdPrest, Descrição, Custo -> {V,F}'),nl,
		       getCuidados(LC),
		       cuidadoSave(LC),nl,

	               told, tell(OldStream).

% Gera uma lista organizada por ID, dos Utentes atuais do programa
getUtentes(R) :- solutions([UID,N,A,S,RUA,CDD,TEL],utente(UID,N,A,S,RUA,CDD,TEL),LU),
		 sortL(LU,R).

% Gera uma lista organizada por ID, dos Prestadores atuais do programa 
getPrestadores(R) :- solutions([PID,N,E,I,CDD],prestador(PID,N,E,I,CDD),LP),
	 	     sortL(LP,R).

% Gera uma lista organizada por Datas, dos Cuidados atuais do programa
getCuidados(R) :- solutions([D,UID,PID,DG,C],cuidado(D,UID,PID,DG,C),LC),
                  sortL(LC,R).

% Escreve a lista de utentes atuais (usada quando estamos a escrever num ficheiro)
utenteSave([]).	 
utenteSave([H|T]) :- format("utente(~w,'~w',~w,'~w','~w','~w','~w').",H),nl,
 		     utenteSave(T).				
% Escreve a lista de prestadores atuais (usada quando estamos a escrever num ficheiro)
prestadorSave([]).
prestadorSave([H|T]) :- format("prestador(~w,'~w','~w','~w','~w').",H),nl,
 		        prestadorSave(T).

% Escreve a lista de cuidados atuais (usada quando estamos a escrever num ficheiro)
cuidadoSave([]).
cuidadoSave([H|T]) :- format("cuidado('~w',~w,~w,'~w',~w).",H),nl,
 		      cuidadoSave(T).

% AUXILIARES %

% Remove repetidos de uma lista
repRemove([],[]).
repRemove([X|A],R) :- elemRemove(X,A,L),
                      repRemove(L,T),
                      R = [X|T].

% Remove a primeira ocorrência de um elemento de uma lista
elemRemove(A,[],[]).
elemRemove(A,[A|Y],T) :- elemRemove(A,Y,T).
elemRemove(A,[X|Y],T) :- X \== A,
                         elemRemove(A,Y,R),
			 T = [X|R].

% Organiza a lista do menor átomo para o maior
sortL([],[]).
sortL([X],[X]).
sortL([H|T],R) :- sortL(T,L1),
                  ins(H,L1,R).

% Insere na lista, do menor átomo para o maior
ins(X,[],[X]).
ins(X,[H|T],[X,H|T]) :- X @=< H.
ins(X,[H|T],[H|NT]) :- X @> H,
                       ins(X,T,NT).

% Soma dos elementos de uma lista
sumL([],0).
sumL([H|T],R) :- sumL(T,N),
		 R is H+N.
