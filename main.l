/*CĂTĂNUȘ BOGDAN-MARIUS 335CC*/
%{
#include <iostream>
#include <fstream>
#include <string>
#include <cctype>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <vector>
#include <unordered_map>
#include <regex>

using namespace std;

// Numele gramaticilor
unordered_map<int, string> grammarNames;

// Regulile de productie ale gramaticilor
unordered_map<int, pair<vector<string>, vector<string>>> grammarProductions;

// Alfabetul gramaticilor
unordered_map<int, vector<string>> grammarAlphabet;

// Simbolul de start al gramaticilor
unordered_map<int, string> grammarStartSymbol;

// Numele automatelor
unordered_map<int, string> automataNames;

// Alfabetul automatelor
unordered_map<int, vector<string>> automataAlphabet;

// Starile automatelor
unordered_map<int, vector<string>> automataStates;

// Starile finale ale automatelor
unordered_map<int, vector<string>> automataFinalStates;

// Starea initiala a automatelor
unordered_map<int, string> automataInitialState;

// Tranzitiile automatelor
unordered_map<int, vector<vector<string>>> automataTransitions;

// Variabile pentru a retine indexul gramaticii/automatului curent
int currentGrammarIndex = 0;
int currentAutomataIndex = 0;

// Variabile pentru a popula corect structura cu tranzitiile automatelor
string currentTransition, currentSymbol;

// Functie pentru a returna indexul gramaticii/automatului
int getIndex(const string& text)
{
    string index;
    // Parcurg sirul
    for (char ch : text)
    {
        // Daca caracterul este cifra, il adaug la index
        if (isdigit(ch))
        {
            index += ch;
        }
    }
    // Returnez indexul
    return !index.empty() ? std::stoi(index) - 1 : -1;
}

// Functie pentru a determina tipul unei gramatici
string determineGrammarType(int index)
{
    // Regulile gramaticii
    const auto& rules = grammarProductions[index].second;
    // "Neterminalele" gramaticii (de fapt, sunt neterminalele si terminalele)
    const auto& nonterminals = grammarProductions[index].first;

    // Flag-uri pentru a determina tipul gramaticii
    bool isRegularLeft = true;
    bool isRegularRight = true;
    bool isContextFreeRight = true;
    bool isContextSensitiveLeft = true;

    // Expresii regulate pentru tipurile de gramatici
    regex regularRule("^[a-z]+[A-Z]?[0-9]*$");
    regex regularNonterminal("^[A-Z][0-9]*$");
    regex contextFreeRule("^[a-z]+[A-Z0-9]*[a-zA-Z]*$|^[A-Z][0-9]*$");
    regex contextSensitiveNonterminal("^[a-z]+[A-Z0-9]*[a-zA-Z]*$|^[A-Z][0-9]*$");

    // Parcurg regulile gramaticii
    for (string rule : rules)
    {
        // Elimin caracterul '&' din reguli
        rule.erase(remove(rule.begin(), rule.end(), '&'), rule.end());

        // Daca regula nu este in format pentru GR
        if (!regex_match(rule, regularRule))
        {
            isRegularRight = false;
        }

        // Daca regula nu este in format pentru GIC
        if (!regex_match(rule, contextFreeRule))
        {
            isContextFreeRight = false;
        }
    }

    // Parcurg "neterminalele" gramaticii
    for (string nonterminal : nonterminals)
    {
        // Daca "neterminalul" nu este in format pentru GR
        if (!regex_match(nonterminal, regularNonterminal))
        {
            isRegularLeft = false;
        }

        // Daca "neterminalul" nu este in format pentru GDC
        if (!regex_match(nonterminal, contextSensitiveNonterminal))
        {
            isContextSensitiveLeft = false;
        }
    }

    if (isRegularRight && isRegularLeft)
    {
        return "GR";
    }
    else if (isContextFreeRight && isRegularLeft)
    {
        return "GIC";
    }
    else if (isContextFreeRight && isContextSensitiveLeft)
    {
        return "GDC";
    }
    else
    {
        return "GFR";
    }
}


// Functie pentru a determina tipul unui automat
string determineAutomataType(int index)
{
    // Tranzitiile automatului
    const auto& transitions = automataTransitions[index];

    // Structura pentru a numara tranzitiile
    map<pair<string, string>, int> transitionCount;

    // Flag pentru a determina daca automatul are tranzitii epsilon
    bool hasEpsilonTransitions = false;

    // Parcurg tranzitiile automatului
    for (const vector<string>& transition : transitions)
    {
        // Daca tranzitia este epsilon
        if (transition[1] == "e")
        {
            // Deja este automat finit nedeterminist
            hasEpsilonTransitions = true;
        }

        // Numar tranzitiile
        transitionCount[{transition[0], transition[1]}]++;
    }

    // Parcurg tranzitiile si verific daca exista tranzitii multiple
    for (const auto& [key, count] : transitionCount)
    {
        // Daca exista tranzitii multiple
        if (count > 1)
        {
            return "Automat finit nedeterminist";
        }
    }

    if (hasEpsilonTransitions)
    {
        return "Automat finit nedeterminist";
    }
    else
    {
        return "Automat finit determinist";
    }
}

%}

%option noyywrap

%s GLOBAL_VARIABLE
%s GLOBAL_VARIABLE_CLEAN
%s GRAMMAR
%s GRAMMAR_CLEAN
%s PRODUCTION
%s NONTERMINALS
%s ALPHABET_GRAMMAR
%s START_SYMBOL
%s AUTOMATA
%s AUTOMATA_CLEAN
%s ALPHABET_AUTOMATA
%s AUTOMATA_STATES
%s AUTOMATA_FINAL_STATES
%s AUTOMATA_INITIAL_STATE
%s LOCAL_VARIABLE
%s LOCAL_VARIABLE_CLEAN
%s AUTOMATA_TRANSITIONS


nonterminal [A-Z][A-Za-z0-9]*
terminal [a-z][a-z0-9]*
qexterminal [a-p|r-z][a-z0-9]*

%%  

"%"[^\n]* {}
. {}
[ \t\n] {}

<INITIAL>"variable " {
    cout << "Variabila globala: " << endl;
    BEGIN(GLOBAL_VARIABLE);
}

<GLOBAL_VARIABLE>{terminal}+/" ::= {" {
    cout << "\tIdentificator: " << yytext << endl;
    cout << "\tDomeniu: ";
    BEGIN(GLOBAL_VARIABLE_CLEAN);
}

<GLOBAL_VARIABLE_CLEAN>"::= { " {
    BEGIN(GLOBAL_VARIABLE);
}

<GLOBAL_VARIABLE>{terminal}+(", "{terminal}+)*/" } ;" {
    cout << "{" << yytext << "}" << endl;
    cout << endl;
    BEGIN(GLOBAL_VARIABLE_CLEAN);
}

<GLOBAL_VARIABLE_CLEAN>" } ;" {
    BEGIN(INITIAL);
}

<INITIAL>{terminal}+/" ::= Grammar (" {
    currentGrammarIndex = getIndex(yytext);
    cout << "Numele gramaticii: " << yytext << endl;
    grammarNames[currentGrammarIndex] = yytext;
    BEGIN(GRAMMAR_CLEAN);
}

<GRAMMAR_CLEAN>" ::= Grammar (" {
    BEGIN(GRAMMAR);
}

<GRAMMAR>({nonterminal}|{qexterminal})+" -> " {
    BEGIN(PRODUCTION);
}

<PRODUCTION>({nonterminal}|{qexterminal})+("&"({nonterminal}|{qexterminal})*)*/(" |") {
    grammarProductions[currentGrammarIndex].second.push_back(yytext);
}

<PRODUCTION>({nonterminal}|{qexterminal})+("&"({nonterminal}|{qexterminal})*)*/(" ;") {
    grammarProductions[currentGrammarIndex].second.push_back(yytext);
    BEGIN(GRAMMAR);
}

<GRAMMAR>"nonterminals :: { " {
    BEGIN(NONTERMINALS);
}

<NONTERMINALS>{nonterminal}/(", ") {
    grammarProductions[currentGrammarIndex].first.push_back(yytext);
}

<NONTERMINALS>{nonterminal}/(" } ;") {
    grammarProductions[currentGrammarIndex].first.push_back(yytext);
    BEGIN(GRAMMAR);
}

<GRAMMAR>"alphabet :: { " {
    BEGIN(ALPHABET_GRAMMAR);
}

<ALPHABET_GRAMMAR>{terminal}/(", ") {
    grammarAlphabet[currentGrammarIndex].push_back(yytext);
}

<ALPHABET_GRAMMAR>{terminal}/(" } ;\n\t") {
    grammarAlphabet[currentGrammarIndex].push_back(yytext);
    BEGIN(GRAMMAR);
}

<GRAMMAR>"start_symbol :: " {
    BEGIN(START_SYMBOL);
}

<START_SYMBOL>{nonterminal}/(" ;") {
    grammarStartSymbol[currentGrammarIndex] = yytext;
    BEGIN(GRAMMAR);
}

<GRAMMAR>") ;;" {
    // Afisez datele gramaticii
    cout << "Tipul gramaticii: " << determineGrammarType(currentGrammarIndex) << endl;
    cout << "Numarul de reguli de productie: " << grammarProductions[currentGrammarIndex].second.size() << endl;
    cout << "Alfabetul gramaticii: {";

    for (int i = 0; i < grammarAlphabet[currentGrammarIndex].size() - 1; i++)
    {
        cout << grammarAlphabet[currentGrammarIndex][i] << ", ";
    }

    cout << grammarAlphabet[currentGrammarIndex].back() << "}" << endl;
    cout << endl;

    BEGIN(INITIAL);
}

<INITIAL>{terminal}+/" ::= FiniteAutomaton (" {
    currentAutomataIndex = getIndex(yytext);
    cout << "Numele automatului: " << yytext << endl;
    automataNames[currentAutomataIndex] = yytext;
    BEGIN(AUTOMATA_CLEAN);
}

<AUTOMATA_CLEAN>" ::= Finite" {
    BEGIN(AUTOMATA);
}

<AUTOMATA>"alphabet :: { " {
    BEGIN(ALPHABET_AUTOMATA);
}

<ALPHABET_AUTOMATA>{terminal}/(", ") {
    automataAlphabet[currentAutomataIndex].push_back(yytext);
}

<ALPHABET_AUTOMATA>{terminal}/(" } ;") {
    automataAlphabet[currentAutomataIndex].push_back(yytext);
    BEGIN(AUTOMATA);
}

<AUTOMATA>"states :: { " {
    BEGIN(AUTOMATA_STATES);
}

<AUTOMATA_STATES>{terminal}/(",") {
    automataStates[currentAutomataIndex].push_back(yytext);
}

<AUTOMATA_STATES>{terminal}/(" } ;") {
    automataStates[currentAutomataIndex].push_back(yytext);
    BEGIN(AUTOMATA);
}

<AUTOMATA>"final_states :: { " {
    BEGIN(AUTOMATA_FINAL_STATES);
}

<AUTOMATA_FINAL_STATES>{terminal}/(", ") {
    automataFinalStates[currentAutomataIndex].push_back(yytext);
}

<AUTOMATA_FINAL_STATES>{terminal}/(" } ;") {
    automataFinalStates[currentAutomataIndex].push_back(yytext);
    BEGIN(AUTOMATA);
}

<AUTOMATA>"initial_state :: " {
    BEGIN(AUTOMATA_INITIAL_STATE);
}

<AUTOMATA_INITIAL_STATE>{terminal}/(" ;") {
    automataInitialState[currentAutomataIndex] = yytext;
    BEGIN(AUTOMATA);
}

<AUTOMATA>"\tvariable " {
    cout << "Variabila locala: " << endl;
    BEGIN(LOCAL_VARIABLE);
}

<LOCAL_VARIABLE>{terminal}+/" ::= { " {
    cout << "\tIdentificator: " << yytext << endl;
    cout << "\tDomeniu: ";
    BEGIN(LOCAL_VARIABLE_CLEAN);
}

<LOCAL_VARIABLE_CLEAN>"::= { " {
    BEGIN(LOCAL_VARIABLE);
}

<LOCAL_VARIABLE>{terminal}+(", "{terminal}+)*/" } ;" {
    cout << "{" << yytext << "}" << endl;
    BEGIN(AUTOMATA);
}

<AUTOMATA>{terminal}/" -> (" {
    currentTransition = yytext;
    BEGIN(AUTOMATA_TRANSITIONS);
}

<AUTOMATA_TRANSITIONS>{terminal}+/" -> " {
    currentSymbol = yytext;
}

<AUTOMATA_TRANSITIONS>{terminal}/(" ;") {
    automataTransitions[currentAutomataIndex].push_back({currentTransition, currentSymbol, yytext});
}

<AUTOMATA_TRANSITIONS>") ;" {
    BEGIN(AUTOMATA);
}

<AUTOMATA>") ;;" {
    // Afisez datele automatului
    cout << "Tipul automatului: " << determineAutomataType(currentAutomataIndex) << endl;
    cout << "Alfabetul de intrare: {";

    for (int i = 0; i < automataAlphabet[currentAutomataIndex].size() - 1; i++)
    {
        cout << automataAlphabet[currentAutomataIndex][i] << ", ";
    }

    cout << automataAlphabet[currentAutomataIndex].back() << "}" << endl;
    cout << "Numarul de stari: " << automataStates[currentAutomataIndex].size() << endl;
    cout << "Starea initiala: " << automataInitialState[currentAutomataIndex] << endl;
    cout << "Starile finale: {";

    for (int i = 0; i < automataFinalStates[currentAutomataIndex].size() - 1; i++)
    {
        cout << automataFinalStates[currentAutomataIndex][i] << ", ";
    }

    cout << automataFinalStates[currentAutomataIndex].back() << "}" << endl;
    cout << "Functia de tranzitie: " << endl;

    for (const vector<string>& transition : automataTransitions[currentAutomataIndex])
    {
        cout << "\tm(" << transition[0] << ", " << transition[1] << ") = " << transition[2] << endl;
    }

    cout << endl;
    BEGIN(INITIAL);
}

%%

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror("Could not open file");
        return 1;
    }

    yyin = f;
    yylex();
    fclose(f);

    return 0;
}
