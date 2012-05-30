#!/bin/bash

rm -rf _tmp 2>&1 >/dev/null

# Start by running the analysis tools
pushd Analysis
runghc analysis.hs
popd

# Copy the cluster files and images to a temporary directory

# The HD data
mkdir _tmp 2>&1 >/dev/null
mkdir _tmp/hd 2>&1 >/dev/null

mkdir _tmp/hd/CH_WTD 2>&1 >/dev/null
cp Analysis/gnu/hd/plot/CH_WTD_*.png _tmp/hd/CH_WTD
cp Analysis/cluster/hd/CH_WTD/cluster*.txt _tmp/hd/CH_WTD

mkdir _tmp/hd/COP 2>&1 >/dev/null
cp Analysis/gnu/hd/plot/COP_*.png _tmp/hd/COP
cp Analysis/cluster/hd/COP/cluster*.txt _tmp/hd/COP

mkdir _tmp/hd/KW 2>&1 >/dev/null
cp Analysis/gnu/hd/plot/KW_*.png _tmp/hd/KW
cp Analysis/cluster/hd/KW/cluster*.txt _tmp/hd/KW

mkdir _tmp/hd/Loads 2>&1 >/dev/null
cp Analysis/gnu/hd/plot/Loads_*.png _tmp/hd/Loads
cp Analysis/cluster/hd/Loads/cluster*.txt _tmp/hd/Loads

# The LD data
mkdir _tmp/ld 2>&1 >/dev/null

mkdir _tmp/ld/CH_WTD 2>&1 >/dev/null
cp Analysis/gnu/ld/plot/CH_WTD_*.png _tmp/ld/CH_WTD
cp Analysis/cluster/ld/CH_WTD/cluster*.txt _tmp/ld/CH_WTD

mkdir _tmp/ld/COP 2>&1 >/dev/null
cp Analysis/gnu/ld/plot/COP_*.png _tmp/ld/COP
cp Analysis/cluster/ld/COP/cluster*.txt _tmp/ld/COP

mkdir _tmp/ld/KW 2>&1 >/dev/null
cp Analysis/gnu/ld/plot/KW_*.png _tmp/ld/KW
cp Analysis/cluster/ld/KW/cluster*.txt _tmp/ld/KW

mkdir _tmp/ld/Loads 2>&1 >/dev/null
cp Analysis/gnu/ld/plot/Loads_*.png _tmp/ld/Loads
cp Analysis/cluster/ld/Loads/cluster*.txt _tmp/ld/Loads

# Build timeCluster
pushd clusterTools/timeCluster
make clean; make
popd

# Now, for each file in each directory, make the output.
pushd _tmp/hd/CH_WTD
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > CH_WTD_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > CH_WTD_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > CH_WTD_03.txt
../../../clusterTools/timeCluster/timeCluster CH_WTD_t01.png CH_WTD_t01_colored.png CH_WTD_01.txt 0
../../../clusterTools/timeCluster/timeCluster CH_WTD_t02.png CH_WTD_t02_colored.png CH_WTD_02.txt 0
../../../clusterTools/timeCluster/timeCluster CH_WTD_t03.png CH_WTD_t03_colored.png CH_WTD_03.txt 0
popd

pushd _tmp/hd/COP
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > COP_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > COP_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > COP_03.txt
../../../clusterTools/timeCluster/timeCluster COP_t01.png COP_t01_colored.png COP_01.txt 0
../../../clusterTools/timeCluster/timeCluster COP_t02.png COP_t02_colored.png COP_02.txt 0
../../../clusterTools/timeCluster/timeCluster COP_t03.png COP_t03_colored.png COP_03.txt 0
popd

pushd _tmp/hd/KW
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > KW_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > KW_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > KW_03.txt
../../../clusterTools/timeCluster/timeCluster KW_t01.png KW_t01_colored.png KW_01.txt 0
../../../clusterTools/timeCluster/timeCluster KW_t02.png KW_t02_colored.png KW_02.txt 0
../../../clusterTools/timeCluster/timeCluster KW_t03.png KW_t03_colored.png KW_03.txt 0
popd

pushd _tmp/hd/Loads
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > Loads_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > Loads_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > Loads_03.txt
../../../clusterTools/timeCluster/timeCluster Loads_t01.png Loads_t01_colored.png Loads_01.txt 0
../../../clusterTools/timeCluster/timeCluster Loads_t02.png Loads_t02_colored.png Loads_02.txt 0
../../../clusterTools/timeCluster/timeCluster Loads_t03.png Loads_t03_colored.png Loads_03.txt 0
popd

pushd _tmp/ld/CH_WTD
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > CH_WTD_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > CH_WTD_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > CH_WTD_03.txt
../../../clusterTools/timeCluster/timeCluster CH_WTD_t01.png CH_WTD_t01_colored.png CH_WTD_01.txt 0
../../../clusterTools/timeCluster/timeCluster CH_WTD_t02.png CH_WTD_t02_colored.png CH_WTD_02.txt 0
../../../clusterTools/timeCluster/timeCluster CH_WTD_t03.png CH_WTD_t03_colored.png CH_WTD_03.txt 0
popd

pushd _tmp/ld/COP
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > COP_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > COP_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > COP_03.txt
../../../clusterTools/timeCluster/timeCluster COP_t01.png COP_t01_colored.png COP_01.txt 0
../../../clusterTools/timeCluster/timeCluster COP_t02.png COP_t02_colored.png COP_02.txt 0
../../../clusterTools/timeCluster/timeCluster COP_t03.png COP_t03_colored.png COP_03.txt 0
popd

pushd _tmp/ld/KW
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > KW_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > KW_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > KW_03.txt
../../../clusterTools/timeCluster/timeCluster KW_t01.png KW_t01_colored.png KW_01.txt 0
../../../clusterTools/timeCluster/timeCluster KW_t02.png KW_t02_colored.png KW_02.txt 0
../../../clusterTools/timeCluster/timeCluster KW_t03.png KW_t03_colored.png KW_03.txt 0
popd

pushd _tmp/ld/Loads
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 1 3 > Loads_01.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 2 3 > Loads_02.txt
../../../clusterTools/extractClusterSegments/extractClusterSegments.pl 3 3 > Loads_03.txt
../../../clusterTools/timeCluster/timeCluster Loads_t01.png Loads_t01_colored.png Loads_01.txt 0
../../../clusterTools/timeCluster/timeCluster Loads_t02.png Loads_t02_colored.png Loads_02.txt 0
../../../clusterTools/timeCluster/timeCluster Loads_t03.png Loads_t03_colored.png Loads_03.txt 0
popd

# Finally, copy the resulting colored images to the original directories
# and delete the temp directory
cp _tmp/ld/CH_WTD/*colored.png Analysis/gnu/ld/plot
cp _tmp/ld/COP/*colored.png Analysis/gnu/ld/plot
cp _tmp/ld/KW/*colored.png Analysis/gnu/ld/plot
cp _tmp/ld/Loads/*colored.png Analysis/gnu/ld/plot

cp _tmp/hd/CH_WTD/*colored.png Analysis/gnu/hd/plot
cp _tmp/hd/COP/*colored.png Analysis/gnu/hd/plot
cp _tmp/hd/KW/*colored.png Analysis/gnu/hd/plot
cp _tmp/hd/Loads/*colored.png Analysis/gnu/hd/plot

rm -rf _tmp
