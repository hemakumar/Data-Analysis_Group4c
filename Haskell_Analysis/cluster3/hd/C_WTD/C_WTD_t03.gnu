reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/C_WTD/C_WTD_t03.png'
set tics nomirror
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't03'
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
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/C_WTD/t03.dat' u 1:(k0($2)) t 'K_1' w boxes lc rgb '#99C7EC',\
'' u 1:(k1($2)) t 'K_2' w boxes lc rgb '#FFFAD2',\
'' u 1:(k2($2)) t 'K_3' w boxes lc rgb '#F5A275',\
'gnu/hd/plot/C_WTD.dat' u 1:($12) t 'C1' w lp ls 1,\
'' u 1:($15) t 'C4' w lp ls 2
