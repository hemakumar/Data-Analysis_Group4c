reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'cluster/ld/TMU_WTD/TMU_WTD_t02.png'
set tics nomirror
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't02'
set xlabel 'SEC'
set ylabel 'TMU WATER-TEMP DELTA'
low = 0.8100000000000023
high = 8.060000000000002
set xrange [0:530]
set yrange [low:high]
set xtics 60
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
k3(x) = (x==3?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/ld/TMU_WTD/t02.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#008BCE',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#B4DDF7',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#F9BD7E',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#D03232',\
'gnu/ld/plot/TMU_WTD.dat' u 1:($7) t 'A1' w lp ls 1,\
'' u 1:($8) t 'B1' w lp ls 2,\
'' u 1:($9) t 'B2' w lp ls 3,\
'' u 1:($10) t 'B3' w lp ls 4,\
'' u 1:($11) t 'B4' w lp ls 5
