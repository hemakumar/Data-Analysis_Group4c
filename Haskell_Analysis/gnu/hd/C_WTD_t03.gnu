reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'gnu/hd/plot/C_WTD_t03.png'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't03'
set xlabel 'SEC'
set ylabel 'CONDENSER WATER-TEMP DELTA'
set xrange [0:3150]
set yrange [4.599999999999994:9.299999999999997]
set xtics 180
plot 'gnu/hd/plot/C_WTD.dat' u 1:($12) t 'C1' w lp ls 1,\
'' u 1:($15) t 'C4' w lp ls 2
