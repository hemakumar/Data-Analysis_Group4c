reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'gnu/ld/plot/PowerKWH_t02.png'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#44AA99' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 6 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set style line 7 lc rgb '#AA4499' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't02'
set xlabel 'SEC'
set ylabel 'POWER-UNIT KWH'
low = 150.23
high = 194.41
set xrange [0:530]
set yrange [low:high]
set xtics 60
plot 'gnu/ld/plot/PowerKWH.dat' u 1:($10) t 'A1' w lp ls 1,\
'' u 1:($12) t 'A3' w lp ls 2,\
'' u 1:($13) t 'A4' w lp ls 3,\
'' u 1:($14) t 'B1' w lp ls 4,\
'' u 1:($15) t 'B2' w lp ls 5,\
'' u 1:($16) t 'B3' w lp ls 6,\
'' u 1:($17) t 'B4' w lp ls 7
