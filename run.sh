if [ $1 -eq 1 ]
then
    echo "Running 1st Instance";
    clingo warehouse.ls simpleInstances/inst1.asp -c n=10;
elif [ $1 -eq 2 ]
then
    echo "Running 2nd Instance";
    clingo warehouse.ls simpleInstances/inst2.asp -c n=11;
elif [ $1 -eq 3 ]
then
    echo "Running 3rd Instance";
    clingo warehouse.ls simpleInstances/inst3.asp -c n=7;
elif [ $1 -eq 4 ]
then
    echo "Running 4th Instance";
    clingo warehouse.ls simpleInstances/inst4.asp -c n=5;
elif [ $1 -eq 5 ]
then
    echo "Running 5th Instance";
    clingo warehouse.ls simpleInstances/inst5.asp -c n=7;
else
    echo "Running 1st Instance";
    clingo warehouse.ls simpleInstances/inst1.asp -c n=10;
fi
