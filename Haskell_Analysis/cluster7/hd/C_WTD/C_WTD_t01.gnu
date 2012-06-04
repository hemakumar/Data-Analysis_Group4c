reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/C_WTD/C_WTD_t01.png'
set tics nomirror
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
set xlabel 'SEC'
set ylabel 'CONDENSER WATER-TEMP DELTA'
low = 4.599999999999994
high = 9.299999999999997
set xrange [0:3150]
set yrange [low:high]
set xtics 180
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
k3(x) = (x==3?high:low)
k4(x) = (x==4?high:low)
k5(x) = (x==5?high:low)
k6(x) = (x==6?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/C_WTD/t01.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#3A89C9',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#99C7EC',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#E6F5FE',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#FFFAD2',\
'' u 1:(k4($2)) t 'K5' w boxes lc rgb '#FFE3AA',\
'' u 1:(k5($2)) t 'K6' w boxes lc rgb '#F5A275',\
'' u 1:(k6($2)) t 'K7' w boxes lc rgb '#D24D3E',\
'gnu/hd/plot/C_WTD.dat' u 1:($2) t 'C1' w lp ls 1,\
'' u 1:($5) t 'C4' w lp ls 2
