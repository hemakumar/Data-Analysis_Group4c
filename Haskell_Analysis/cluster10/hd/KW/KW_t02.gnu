reset
set terminal pngcairo size 1152,720 enhanced font 'Verdana,9'
set output 'cluster/hd/KW/KW_t02.png'
set tics nomirror
set style line 1 lc rgb '#4477AA' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't02'
set xlabel 'SEC'
set ylabel 'KW'
low = 153.99
high = 244.0
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
k7(x) = (x==7?high:low)
k8(x) = (x==8?high:low)
k9(x) = (x==9?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/hd/KW/t02.dat' u 1:(k0($2)) t 'K1' w boxes lc rgb '#3D52A1',\
'' u 1:(k1($2)) t 'K2' w boxes lc rgb '#3A89C9',\
'' u 1:(k2($2)) t 'K3' w boxes lc rgb '#77B7E5',\
'' u 1:(k3($2)) t 'K4' w boxes lc rgb '#B4DDF7',\
'' u 1:(k4($2)) t 'K5' w boxes lc rgb '#E6F5FE',\
'' u 1:(k5($2)) t 'K6' w boxes lc rgb '#FFE3AA',\
'' u 1:(k6($2)) t 'K7' w boxes lc rgb '#F9BD7E',\
'' u 1:(k7($2)) t 'K8' w boxes lc rgb '#ED875E',\
'' u 1:(k8($2)) t 'K9' w boxes lc rgb '#D24D3E',\
'' u 1:(k9($2)) t 'K10' w boxes lc rgb '#AE1C3E',\
'gnu/hd/plot/KW.dat' u 1:($7) t 'C1' w lp ls 1,\
'' u 1:($10) t 'C4' w lp ls 2