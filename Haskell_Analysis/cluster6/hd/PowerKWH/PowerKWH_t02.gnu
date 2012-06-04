reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/PowerKWH/PowerKWH_t02.png'
set tics nomirror
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
k5(x) = (x==5?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/PowerKWH/t02.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#3A89C9',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#99C7EC',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#E6F5FE',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#FFE3AA',\
'' u 1:(k4($2)) t 'K5' w boxes lc rgb '#F5A275',\
'' u 1:(k5($2)) t 'K6' w boxes lc rgb '#D24D3E',\
'gnu/hd/plot/PowerKWH.dat' u 1:($10) t 'A1' w lp ls 1,\
'' u 1:($12) t 'A3' w lp ls 2,\
'' u 1:($13) t 'A4' w lp ls 3,\
'' u 1:($14) t 'B1' w lp ls 4,\
'' u 1:($15) t 'B2' w lp ls 5,\
'' u 1:($16) t 'B3' w lp ls 6,\
'' u 1:($17) t 'B4' w lp ls 7
