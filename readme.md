# Random IOS 2 tester
## Spusteni
### Skript testuje random vstupy v intervalech ze zadani a kontroluje:
- urednik nesmi odejit z posty pred zavrenim posty
- urednik si nesmi dat prestavku po zavreni posty
- zakaznik nesmi vejit, kdyz je posta zavrena
- je stejny pocet "entering" a "serving"
- btw se da poznat deadlock/jina chyba cekani - skript se zasekne
- nemusi testovat nulove parametry!
            
### Potrebne soubory:
- Ve stejne slozce musi byt makefile, Proj2.c a tento skript.
- proj2 musi ukladat vystup "proj2.out" do teto slozky.
- Vytvori se slozka OUTPUT, kde se kopiruji mimoradne vystupy.

### Pouziti:
- ./tester.sh -h
    - tiskne napovedu, konci
- ./tester.sh [-m] [N]
    - spusti test s danym poctem opakovani, vychozi hodnota je 50
    - pokud je zadan prepinac -m, omezi max pocet procesu na 82, aby to fungovalo na merlinovi (default hodnota je 202)

### Disclaimer:
- Nemuzu zarucit uplnou spolehlivost, bugy -> kdyztak do dm @Nukusumus na Discordu"

## Zname bugy
