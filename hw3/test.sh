#!/bin/bash

echo "Compiling..."
javac UnsafeMemory.java


printf "Synchronized\n"
for ((j=1;j<=8;j*=2))
do
    $sum=0
    printf "Threads %d\n" $j
        for ((i=1;i<=5;i+=1))
        do
                >&2 echo $i

                java UnsafeMemory Synchronzied $j 100000000 127 50 20 58 25 75 | s\
ed 's/[^0-9.]*//g'
        done
done

printf "BetterSafe\n"
for ((j=1;j<=8;j*=2))
do
    $sum=0
    printf "Threads %d\n" $j
        for ((i=1;i<=5;i+=1))
        do
                >&2 echo $i

                java UnsafeMemory BetterSafe $j 100000000 127 50 20 58 25 75 | s\
ed 's/[^0-9.]*//g'
        done
done
