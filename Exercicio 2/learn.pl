listing(excecao).
:- dynamic excecao/2.

excecao(sangue, utente(10, 'Joao', 27, 'A', 'Largo de Camoes', 'Ponte de Lima', '289347681')).
excecao(sangue, utente(10, 'Joao', 27, 'B', 'Largo de Camoes', 'Ponte de Lima', '289347681')).
excecao(sangue, utente(10, 'Joao', 27, 'AB', 'Largo de Camoes', 'Ponte de Lima', '289347681')).

true.

learn_UT_sangue(10,'AB').
true.

listing(excecao).
:- dynamic excecao/2.

true.
