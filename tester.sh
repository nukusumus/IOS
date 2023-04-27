#!/bin/bash

if [ ! -z $1 ]; then
    if [ $1 == "-h" ]; then
        echo -e "
    Skript testuje random vstupy v intervalech ze zadani a kontroluje:
        - urednik nesmi odejit z posty pred zavrenim posty
        - urednik si nesmi dat prestavku po zavreni posty
        - zakaznik nesmi vejit, kdyz je posta zavrena
        - je stejny pocet "entering" a "serving"
        - btw se da poznat deadlock/jina chyba cekani - skript se zasekne
        - nemusi testovat nulove parametry!
            
    Potrebne soubory:
        Ve stejne slozce musi byt makefile, Proj2.c a tento skript.
        proj2 musi ukladat vystup "proj2.out" do teto slozky.
        Vytvori se slozka OUTPUT, kde se kopiruji mimoradne vystupy.

    Pouziti:
        ./tester.sh [-h] [N]
            -h: - tiskne napovedu, konci
            N - pocet opakovani testu, vychozi je 50

    Disclaimer:
        Nemuzu zarucit uplnou spolehlivost, kdyztak dm @Nukusumus na Discordu\n"
        exit 0
    fi
fi

if [ -z $1 ]; then
    max_counter=50
else
    max_counter=$1
fi

if [ -d "./OUTPUT/" ]; then
    echo -e -n "\u001b[33m[INFO]\u001b[0m Content of ./OUTPUT folder will be removed. Continue? [Y / n] "
    read yes_no
    if [ -z $yes_no ] || [ $yes_no == "Y" ] || [ $yes_no == "y" ]; then
        if [ "$(ls -A OUTPUT)" ]; then
            rm OUTPUT/*
        fi
    else
        exit 1
    fi
else
    mkdir "./OUTPUT/"
fi

make
counter=0
echo -e "\u001b[33mrunning $max_counter tests\u001b[0m"

while [ $counter -lt $max_counter ]; do

    counter=$((counter + 1))

    v=$((RANDOM % 80 + 1))
    w=$((RANDOM % 80 + 1))
    x=$((RANDOM % (10000 / $counter)))
    y=$((RANDOM % 100))
    z=$((RANDOM % (10000 / $counter)))

    printf %\ 3d $counter
    echo " [$(date +%H:%M:%S)] running: ./proj2 $v $w $x $y $z"
    ./proj2 $v $w $x $y $z
    if [ $? -eq 1 ]; then
        echo -e "./proj2 $v $w $x $y $z -\u001b[31m ended with exit code 1\u001b[0m"
        exit 1
    fi

    #echo -e -n "\r"
    #printf %\ 3d $counter
    #echo -n "% [$(date +%H:%M:%S)] "
    #echo -n "testing: "
    closing=$(grep -a "closing" proj2.out | grep -o '^[0-9]*')
    Z_enter=$(grep -a "entering" proj2.out | tail -n -1 | grep -o '^[0-9]*')
    U_break=$(grep -a "taking" proj2.out | tail -n -1 | grep -o '^[0-9]*')
    U_home=$(grep -a " U " proj2.out | grep "going home" | tail -n -1 | grep -o '^[0-9]*')
    NUM_of_entering=$(grep -a "entering" proj2.out | wc -l)
    NUM_of_serving=$(grep -a "serving" proj2.out | wc -l)

    # urednik nesmi odpocivat po zavreni posty

    if [ -z $U_break ]; then
        echo -e -n "\n \u001b[33m[INFO]\u001b[0m no officer taking break, output copied"
        cp proj2.out "OUTPUT/$counter-missing_officer_break"
    else
        if [ $U_break -ge $closing ]; then
            echo -e "\n \u001b[31m[FAIL] \u001b[0mline $U_break: officer taking break after closing, output copied"
            cp proj2.out "OUTPUT/$counter-break_after_close"
            exit 1
        fi
    fi

    # urednik nesmi jit domu pred zavrenim posty

    if [ -z $U_home ]; then
        echo -e "\n \u001b[33m[FAIL]\u001b[0m no officer going home, output copied"
        cp proj2.out "OUTPUT/$counter-missing_officer_home"
        exit 1
    else
        if [ $U_home -lt $closing ]; then
            echo -e "\n \u001b[31m[FAIL] \u001b[0mline $U_home: officer going home before closing, output copied"
            cp proj2.out "OUTPUT/$counter-home_before_closing"
            exit 1
        fi
    fi

    # zakaznik nesmi vejit na postu po zavreni posty

    if [ -z $Z_enter ]; then
        echo -e -n "\n \u001b[33m[INFO]\u001b[0m no customer entering, output copied"
        cp proj2.out "OUTPUT/$counter-missing_customer_entering"
    else
        if [ $Z_enter -gt $closing ]; then
            echo -e "\n \u001b[31m[FAIL] \u001b[0mline $Z_enter: customer entered after closing, output copied"
            cp proj2.out "OUTPUT/$counter-enter_after_close"
            exit 1
        fi
    fi

    if [ ! $NUM_of_entering -eq $NUM_of_serving ]; then
        echo -e "\n \u001b[31m[FAIL] \u001b[0mdifferent number of \"entering\" and \"serving\", output copied"
        cp proj2.out "OUTPUT/$counter-different_entering_serving"
        exit 1
    fi

    echo -e "\u001b[32m[OK]\u001b[0m"
done

echo -e "\n \u001b[32mTest OK\u001b[0m"
exit 0
