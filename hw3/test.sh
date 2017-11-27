#!/bin/bash

echo "Compiling..."
javac UnsafeMemory.java

printf "Synchronized\n"
for ((j=1;j<=32;j*=2))
do
	printf "Threads %d\n" $j
	for ((i=1;i<=5;i+=1))
	do
		>&2 echo $i
	
		java UnsafeMemory Synchronized $j 100000000 127 50 20 58 25 75 | sed 's/[^0-9.]*//g'
	done
done

printf "Synchronized\n"
for ((j=1;j<=32;j*=2))
do
        printf "Threads %d\n" $j
        for ((i=1;i<=5;i+=1))
        do
                >&2 echo $i

                java UnsafeMemory BetterSafe $j 100000000 127 50 20 58 25 75 | s\
ed 's/[^0-9.]*//g'
        done
done
