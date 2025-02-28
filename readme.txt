CĂTĂNUȘ BOGDAN-MARIUS 335CC

Am realizat programul in Visual Studio Code si am folosit cod C++ pentru
structurile de date in care am stocat informatiile despre gramatici si automate
si pentru implementarea a 3 functii ajutatoare.

Functii ajutatoare implementate:
- int getIndex(const string& text): returneaza indexul gramaticii/automatului
din structurile de harta (map);
- string determineGrammarType(int index): determina tipul unei gramatici;
- string determineAutomataType(int index): determina tipul unui automat.

In sectiunea de reguli FLEX m-am folosit de mai multe stari, pe care le-am
definit, pentru a parsa textul din fisierul de intrare folosind doar sintaxa
FLEX. Am definit neterminalele si terminalele posibile, dar si "qexterminal"
care exclude litera "q", prezenta in definitia starilor automatelor (imi facea
match cand voiam sa parsez date pentru gramatici si am decis s-o exclud). O
problema pe care am intampinat-o a fost ca sirul "yytext" retinea uneori
caractere in plus fata de ce doream sa extrag. Astfel, am adaugat niste stari
suplimentare de forma <STARE_CLEAN> in care am facut match pe caracterele in
plus si le-am indepartat. Cu ajutorul variabilelor currentGrammarIndex si
currentAutomataIndex am putut sa populez structurile de date, iar cu
currentTransition si currentSymbol am reusit sa parsez pentru fiecare stare
a automatului tranzitiile acesteia. In final, am afisat datele in consola sub
formatul dorit la fiecare final de definire a gramaticii/automatului.

Parcursul starilor pentru regulile FLEX:
- <INITIAL>: incepe parsarile pentru variabile globale, gramatici si automate;
- <GLOBAL_VARIABLE>: parseaza datele variabilelor globale si se intoarce in
starea INITIAL;
- <GRAMMAR>: parseaza datele gramaticilor si se intoarce in starea INITIAL;
- <AUTOMATA>: parseaza datele automatelor si se intoarce in starea INITIAL;