reset
set terminal pngcairo size 640,480 enhanced font 'Verdana,9'
set output 'cluster/ld/ManifoldPress/ManifoldPress_t01.png'
set tics nomirror
set style line 1 lc rgb '#332288' pt 0 ps 1 lt 1 lw 4
set style line 2 lc rgb '#88CCEE' pt 0 ps 1 lt 1 lw 4
set style line 3 lc rgb '#117733' pt 0 ps 1 lt 1 lw 4
set style line 4 lc rgb '#DDCC77' pt 0 ps 1 lt 1 lw 4
set style line 5 lc rgb '#CC6677' pt 0 ps 1 lt 1 lw 4
set key bottom rmargin title 't01'
set xlabel 'SEC'
set ylabel 'TMU MANIFOLD PRESSURE'
low = 22.08
high = 26.1
set xrange [0:530]
set yrange [low:high]
set xtics 60
k0(x) = (x==0?high:low)
k1(x) = (x==1?high:low)
k2(x) = (x==2?high:low)
set style fill transparent solid 0.25
set boxwidth 1 relative
plot 'cluster/ld/ManifoldPress/t01.dat' u 1:(k0($2)) t 'K_1' w boxes lc rgb '#99C7EC',\
'' u 1:(k1($2)) t 'K_2' w boxes lc rgb '#FFFAD2',\
'' u 1:(k2($2)) t 'K_3' w boxes lc rgb '#F5A275',\
'gnu/ld/plot/ManifoldPress.dat' u 1:($2) t 'A1' w lp ls 1,\
'' u 1:($3) t 'B1' w lp ls 2,\
'' u 1:($4) t 'B2' w lp ls 3,\
'' u 1:($5) t 'B3' w lp ls 4,\
'' u 1:($6) t 'B4' w lp ls 5
