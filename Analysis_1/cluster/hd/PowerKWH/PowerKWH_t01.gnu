reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/PowerKWH/PowerKWH_t01.png'
set tics nomirror
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#44AA99' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 6 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set style line 7 lc rgb '#AA4499' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
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
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/PowerKWH/t01.dat' u 1:(k0($2)) t 'K_1' w boxes lc rgb '#99C7EC',\
'' u 1:(k1($2)) t 'K_2' w boxes lc rgb '#FFFAD2',\
'' u 1:(k2($2)) t 'K_3' w boxes lc rgb '#F5A275',\
'gnu/hd/plot/PowerKWH.dat' u 1:($2) t 'A1' w lp ls 1,\
'' u 1:($4) t 'A3' w lp ls 2,\
'' u 1:($5) t 'A4' w lp ls 3,\
'' u 1:($6) t 'B1' w lp ls 4,\
'' u 1:($7) t 'B2' w lp ls 5,\
'' u 1:($8) t 'B3' w lp ls 6,\
'' u 1:($9) t 'B4' w lp ls 7
