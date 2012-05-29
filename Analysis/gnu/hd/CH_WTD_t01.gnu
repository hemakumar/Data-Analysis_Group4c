reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'gnu/hd/plot/CH_WTD_t01.png'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
set xlabel 'SEC'
set ylabel 'CHILLER WATER-TEMP DELTA'
set xrange [0:3150]
set yrange [6.399999999999999:10.600000000000001]
set xtics 180
plot 'gnu/hd/plot/CH_WTD.dat' u 1:($2) t 'C1' w lp ls 1,\
'' u 1:($5) t 'C4' w lp ls 2
