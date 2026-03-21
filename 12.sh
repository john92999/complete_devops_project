#!/bin/bash


case expression in
    pattern1 )
        statements;;
    pattern2 )
        statements;;
    ...
esac

vehicle = $1

case $vehicle in
    "car" )
        echo "Rent of the $vehicle is 100 dollars";;
    "van" )
        echo "Rent of the $vehicle" is 80 dollars;;
    "bicycle" )
        echo "Rent of the $vehicle" is 5 dollars;;
    "truck" )
        echo "Rent of the $vehicle" is 150 dollars;;
    * )
        echo "unknown vehicle";;
esac
