reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'cluster/ld/COP/COP_t03.png'
set tics nomirror
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't03'
set xlabel 'SEC'
set ylabel 'COP'
low = 0.30997857501025666
high = 0.40899795501022496
set xrange [0:510]
set yrange [low:high]
set xtics 60
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
k3(x) = (x==3?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/ld/COP/t03.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#008BCE',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#B4DDF7',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#F9BD7E',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#D03232',\
'gnu/ld/plot/COP.dat' u 1:($12) t 'C1' w lp ls 1,\
'' u 1:($13) t 'C2' w lp ls 2,\
'' u 1:($15) t 'C4' w lp ls 3
