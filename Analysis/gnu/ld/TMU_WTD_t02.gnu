reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'gnu/ld/plot/TMU_WTD_t02.png'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't02'
set xlabel 'SEC'
set ylabel 'TMU WATER-TEMP DELTA'
set xrange [0:530]
set yrange [0.8100000000000023:8.060000000000002]
set xtics 60
plot 'gnu/ld/plot/TMU_WTD.dat' u 1:($7) t 'A1' w lp ls 1,\
'' u 1:($8) t 'B1' w lp ls 2,\
'' u 1:($9) t 'B2' w lp ls 3,\
'' u 1:($10) t 'B3' w lp ls 4,\
'' u 1:($11) t 'B4' w lp ls 5
