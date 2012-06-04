reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/CH_WTD/CH_WTD_t01.png'
set tics nomirror
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
set xlabel 'SEC'
set ylabel 'CHILLER WATER-TEMP DELTA'
low = 6.399999999999999
high = 10.600000000000001
set xrange [0:3150]
set yrange [low:high]
set xtics 180
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
k3(x) = (x==3?high:low)
k4(x) = (x==4?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/CH_WTD/t01.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#008BCE',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#B4DDF7',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#FFFAD2',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#F9BD7E',\
'' u 1:(k4($2)) t 'K5' w boxes lc rgb '#D03232',\
'gnu/hd/plot/CH_WTD.dat' u 1:($2) t 'C1' w lp ls 1,\
'' u 1:($5) t 'C4' w lp ls 2
