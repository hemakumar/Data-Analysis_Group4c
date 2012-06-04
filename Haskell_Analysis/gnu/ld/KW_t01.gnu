reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'gnu/ld/plot/KW_t01.png'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
set xlabel 'SEC'
set ylabel 'KW'
low = 156.48
high = 220.16
set xrange [0:510]
set yrange [low:high]
set xtics 60
plot 'gnu/ld/plot/KW.dat' u 1:($2) t 'C1' w lp ls 1,\
'' u 1:($3) t 'C2' w lp ls 2,\
'' u 1:($5) t 'C4' w lp ls 3
