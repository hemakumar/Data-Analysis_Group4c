reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/PowerKWH/PowerKWH_t03.png'
set tics nomirror
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#44AA99' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 6 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set style line 7 lc rgb '#AA4499' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't03'
set xlabel 'SEC'
set ylabel 'POWER-UNIT KWH'
low = 284.33
high = 559.66
set xrange [0:3160]
set yrange [low:high]
set xtics 180
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
k3(x) = (x==3?high:low)
k4(x) = (x==4?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/PowerKWH/t03.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#008BCE',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#B4DDF7',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#FFFAD2',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#F9BD7E',\
'' u 1:(k4($2)) t 'K5' w boxes lc rgb '#D03232',\
'gnu/hd/plot/PowerKWH.dat' u 1:($18) t 'A1' w lp ls 1,\
'' u 1:($20) t 'A3' w lp ls 2,\
'' u 1:($21) t 'A4' w lp ls 3,\
'' u 1:($22) t 'B1' w lp ls 4,\
'' u 1:($23) t 'B2' w lp ls 5,\
'' u 1:($24) t 'B3' w lp ls 6,\
'' u 1:($25) t 'B4' w lp ls 7
