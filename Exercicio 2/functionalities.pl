:- ensure_loaded(exercicio).

%-----------------------------------------%
% Registo de Utentes/Prestadores/Cuidados %
%-----------------------------------------%

%- Registar utentes
registaUtente(ID,N,A,S,RUA,CDD,TEL) :- learn(utente(ID,N,A,S,RUA,CDD,TEL)).

%- Registar prestadores
registaPrestador(ID,N,S,I,C) :- learn(prestador(ID,N,S,I,C)).

%- Registar cuidados
registaCuidado(ID,D,UID,PID,DSC,P) :- learn(cuidado(ID,D,UID,PID,DSC,P)).

%-----------------------------------------%
% Remoção de Utentes/Prestadores/Cuidados %
%-----------------------------------------%

%- Remover utente
removeUtente(ID) :- forget(utente(ID,_,_,_,_,_,_)).

%- Remover prestador
removePrestador(ID) :- forget(prestador(ID,_,_,_,_)).

%- Remover cuidado
removeCuidado(ID,D,UID,PID,DG,P) :- forget(cuidado(ID,D,UID,PID,DG,P)).

%--------------------------------%
% Identifica Utente por critério %
%--------------------------------%

utenteID(ID,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),R)).
utenteName(N,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R).
utenteIdade(A,R) :- (solutions(utente(ID,N,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R).
utenteRua(RUA,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R). 
utenteCidade(CDD,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),LU)), sortL(LU,R). 
utenteContacto(TEL,R) :- (solutions(utente(ID,N,A,S,RUA,CDD,TEL),utente(ID,N,A,S,RUA,CDD,TEL),R)). 

prestadorID(ID,R) :- (solutions(prestador(ID,N,ESP,I,CDD),prestador(ID,N,ESP,I,CDD),R)).
cuidadoID(ID,R) :- (solution(cuidado(ID,D,UID,PID,DSC,P),cuidado(ID,D,UID,PID,DSC,P),R)).

%--------------------------------------------------------------------%
% Identifica Instituições e Cidades prestadores de cuidados de saúde %
%--------------------------------------------------------------------%

%-> Instituições
instituicoesPrestadoras(R) :- solutions((C,I),(cuidado(_,_,_,PID,_,_),prestador(PID,_,_,I,C)),L1),
		              repRemove(L1,LI),
			      sortL(LI,R).

%-> Cidades
cidadesPrestadoras(R) :- solutions(CDD,(cuidado(_,_,_,PID,_,_),prestador(PID,_,_,I,CDD)),L1),
		         repRemove(L1,LI),
 		         sortL(LI,R).

%---------------------------------------------------------------------%
% Identificar cuidados de saúde prestados por Instituição/Cidade/Data %
%---------------------------------------------------------------------%

%-> Por instituicao
cuidadosInstituicao(I,R) :- solutions(cuidado(D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(ID,D,UID,PID,DG,C)),LC),
		  	    sortL(LC,R).

%-> Por cidade
cuidadosCidade(CDD,R) :- solutions(cuidado(ID,D,UID,PID,DG,C),(prestador(PID,_,_,_,CDD),cuidado(ID,D,UID,PID,DG,C)),LC),
		         sortL(LC,R).

%-> Por data
cuidadosData(D,R) :- solutions(cuidado(ID,D,IU,IP,DG,C),cuidado(ID,D,IU,IP,DG,C),LC),sortL(LC,R).	      

%-------------------------------------------------------------%
% Identificar Utentes por Prestador/Especialidade/Instituição %
%-------------------------------------------------------------%

%-> prestador
utentes_P(PID,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(cuidado(_,_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
	            repRemove(L1,LU),
	            sortL(LU,R).

%-> especialidade
utentes_ESP(E,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(prestador(PID,_,E,_,_),cuidado(_,_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
		    repRemove(L1,LU),
		    sortL(LU,R).

%-> instituicao
utentes_I(I,R) :- solutions(utente(UID,N,A,S,RUA,CDD,TEL),(prestador(PID,_,_,I,_),cuidado(_,_,UID,PID,_,_),utente(UID,N,A,S,RUA,CDD,TEL)),L1),
		  repRemove(L1,LU),
		  sortL(LU,R).

%----------------------------------------------------------------%
% Identificar cuidados de saúde por Utente/Instituição/Prestador %
%----------------------------------------------------------------%

%-> utente
cuidados_UT(UID,R) :- solutions(cuidado(ID,D,UID,PID,DG,C),cuidado(ID,D,UID,PID,DG,C),LC),
		      sortL(LC,R).

%-> instituicao
cuidados_I(I,R) :- solutions(cuidado(ID,D,UID,PID,DG,C),(prestador(PID,_,_,I,_),cuidado(ID,D,UID,PID,DG,C)),LC),
		   sortL(LC,R).

%-> prestador
cuidados_P(PID,R) :- solutions(cuidado(ID,D,UID,PID,DG,C),cuidado(ID,D,UID,PID,DG,C),LC),
		     sortL(LC,R).

%---------------------------------------------------%
% Identificar Instituições/Prestadores de um Utente %
%---------------------------------------------------%
		         
%-> instituicoes
instituicoes_UT(UID,R) :- solutions((C,I),(cuidado(_,_,UID,PID,_,_),prestador(PID,_,_,I,C)),L1),
			  repRemove(L1,LI),
			  sortL(LI,R).

%-> prestadores
prestadores_UT(UID,R) :- solutions(prestador(PID,N,E,I,C),(cuidado(_,_,UID,PID,_,_),prestador(PID,N,E,I,C)),L1),
			  repRemove(L1,LP),
			  sortL(LP,R).
%-------------------------------------------------------------------------------%
% Calcular despesa/rendimento médico de um Utente/Especialidade/Prestador/Data  %
%-------------------------------------------------------------------------------%

% Calcular custo por Utente
custoUtente(UID) :- solutions(C,(cuidado(_,_,UID,_,_,C),integer(C)),LC),
		    sumL(LC,T),
		    write('ID do Utente: '),write(UID),nl,
		    write('Despesa Médica: '),write(T),write('€'),nl.
                     

% Calcular custo por Especialidade 
custoEspecialidade(E) :- solutions(C,(prestador(PID,_,E,_,_),cuidado(_,_,_,PID,_,C),integer(C)),LC),
			   sumL(LC,T),
		           write('Especialidade Médica: '),write(E),nl,
		 	   write('Rendimento: '),write(T),write('€'),nl.


% Calcular custo por Prestador
custoPrestador(PID) :- solutions(C,(cuidado(_,_,_,PID,_,C),integer(C)),LC),
			 sumL(LC,T),
			 write('ID do Prestador: '),write(PID),nl,
			 write('Rendimento :'),write(T),write('€'),nl.


% Calcular custo por Datas
custoData(D) :- solutions(C,(cuidado(_,D,_,_,_,C),integer(C)),LC),
		sumL(LC,T),
		write('Data (Ano-Mês-Dia): '),write(D),nl,
		write('Balanço Diário): '),write(T),write('€'),nl.

%----------------------------------------------------------------------------%
% Identificar Doadores de Sangue por Tipo, de uma Cidade/Instituição, ou não %
%----------------------------------------------------------------------------%

% Doadores para o Tipo de Sangue 'S'
doadoresTipo(S,R) :- solutions(utente(ID,N,A,D,RUA,CDD,TEL),(sangue(S,D),utente(ID,N,A,D,RUA,CDD,TEL)),LU),sortL(LU,R).

% Doadores para o Tipo de Sangue 'S' de uma dada cidade 'CDD'
doadoresCidade(S,CDD,R) :- solutions(utente(ID,N,A,D,RUA,CDD,TEL),(sangue(S,D),utente(ID,N,A,D,RUA,CDD,TEL)),LU), sortL(LU,R).

% Doadores para o Tipo de Sangue 'S' de uma dada instituição 'I'
doadoresInstituicao(S,I,R) :- solutions(utente(UID,N,A,D,RUA,CDD,TEL),
		              (sangue(S,D),prestador(PID,_,_,I,_),cuidado(_,_,UID,PID,_,_),utente(UID,N,A,D,RUA,CDD,TEL)),LU), 
			      sortL(LU,R).

%---------------------------------------------------------------------------------------------------%
% Calcular Despesa/Rendimento médico, entre datas, de um Utente/Prestador/Instituição/Especialidade %
%---------------------------------------------------------------------------------------------------%

% Despesa Médica de um Utente desde a data 'D1' até à data 'D2'
despesaEntre_UT(UID,D1,D2) :- ((utente(UID,_,_,_,_,_,_)) -> 
			          
			           solutions(C,(cuidado(_,D,UID,_,_,C),(D1 @=< D),(D @=< D2),integer(C)),LC),
			           sumL(LC,T),
			   	   write('ID do Utente: '),write(UID),nl,
		   		   write('Despesa Médica, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Utente inexistente'),fail).

% Rendimento de um Prestador desde a data 'D1' até à data 'D2'
rendimentoEntre_P(PID,D1,D2) :- ((prestador(PID,_,_,_,_)) ->
			   
       			           solutions(C,(cuidado(_,D,_,PID,_,C),(D1 @=< D),(D @=< D2),integer(C)),LC),
			           sumL(LC,T),
			   	   write('ID do Prestador: '),write(PID),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Prestador inexistente'),fail).

% Rendimento de uma Instituição desde a data 'D1' até à data 'D2'
rendimentoEntre_I(I,D1,D2) :- ((prestador(_,_,_,I,_)) ->

				   solutions(C,(prestador(PID,_,_,I,_),cuidado(_,D,_,PID,_,C),(D1 @=< D),(D @=< D2),integer(C)),LC),
			           sumL(LC,T),
			   	   write('Instituição: '),write(I),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Instituição inexistente'),fail).

% Rendimento de uma Especialdiade desde a data 'D1' até _à data 'D2'
rendimentoEntre_ESP(E,D1,D2) :- ((prestador(_,_,E,_,_)) ->
		
				   solutions(C,(prestador(PID,_,E,_,_),cuidado(D,_,PID,_,C),(D1 @=<D),(D @=< D),integer(C)),LC),
				   sumL(LC,T),
			   	   write('Especialidade Médica: '),write(E),nl,
		   		   write('Rendimento, entre '),write(D1),write(' e'),write(D2),write(': '),
				   write(T),write('€'),nl ;

				   write('Especialidade inexistente'),fail).

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
