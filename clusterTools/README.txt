To use these tools with the test data, do the following:

#-------------------------------------------------------------------
# Build the timeCluster tool (requires libpng)
cd timeCluster
make clean

# Go to the testData directory and run the tools
cd testData
../extractClusterSegments/extractClusterSegments.pl 1 4 > out.txt
../timeCluster/timeCluster trial1.png trial1_colored.png out.txt 0
../timeCluster/timeCluster trial2.png trial2_colored.png out.txt 0
../timeCluster/timeCluster trial3.png trial3_colored.png out.txt 0
#-------------------------------------------------------------------

To use your own data, place the cluster files and image files into a
single directory.  Change into that directory, and invoke the two tools
as shown above.  

The 2 command line arguments for extractClusterSegments.pl are:
   <trial number> and <number of clusters>
   
The 4 command line arguments for timeCluster are:
   <input image>  <output image>  <data file>  <is low density?>
   
   
