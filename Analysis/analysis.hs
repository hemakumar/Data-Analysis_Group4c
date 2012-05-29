{- run as a script:
runghc analysis.hs
-}
-------------------------------------------------------------------------------
{- make an executable:
ghc --make analysis
./analysis
-}
-------------------------------------------------------------------------------
import System.IO
import Control.Monad
import qualified Data.Vector                                               as V
-------------------------------------------------------------------------------
import Work.Cluster
import Work.Plot
import Work.Table
import Work.Parse
-------------------------------------------------------------------------------
main = do
  tmu
  forM_ [tables,power,chillers,plotify_all] $ \f -> mapM_ f [True,False]
  mapM_ chiller_clustering [True,False]
-------------------------------------------------------------------------------
tables isLD = do
  let racks = ["A1","A3","A4","B1","B2","B3","B4"]
      trials = ["t01","t02","t03"]
  latex_node_metric (0,999) vec_delta node_avg "DeltaAvg" isLD racks trials "/PowerUnit/" "PowerUnit" "PowerKWH"
  latex_node_metric (72,150) vec_max node_max "MaxMax" isLD racks trials "/CPUTemp/" "CPU" "Temp"
  latex_node_metric (72,150) vec_min node_min "MinMin" isLD racks trials "/CPUTemp/" "CPU" "Temp"
  latex_node_metric (72,150) vec_avg node_avg "AvgAvg" isLD racks trials "/CPUTemp/" "CPU" "Temp"
  latex_node_form_metric (0,40) vec_avg node_avg "AvgAvg" isLD racks trials "/AirTemp/" "NodeAir" (-) "ExchangeTemp" "InTemp" "Delta"
-------------------------------------------------------------------------------
power isLD = do
  let racks = ["A1","A3","A4","B1","B2","B3","B4"]
      trials = ["t01","t02","t03"]
  let dir = "/PowerUnit/"
  gnu_metric isLD dir "PowerKWH" 10
  let threshold = if isLD then 130 else 250
  (x,y) <- get_ranges isLD extract "PowerKWH" threshold
  batched_gnu isLD "PowerKWH" ([2]++[4..9]) racks trials "POWER-UNIT KWH" x y [0,8,16]
-------------------------------------------------------------------------------
tmu = do
  let dir = "/ThermalManagementUnit/"
  gnu_metric True dir "ManifoldPress" 10
  gnu_form_metric True dir (-) "WaterOutletTemp" "WaterInletTemp" "TMU_WTD" 10
  (x,y) <- get_ranges True extract "ManifoldPress" 21
  let racks = ["A1","B1","B2","B3","B4"]
      trials = ["t01","t02","t03"]
  batched_gnu True "ManifoldPress" ([2..6]) racks trials "TMU MANIFOLD PRESSURE" x y [0,5,10]
  (x,y) <- get_ranges True extract "TMU_WTD" 0.5
  batched_gnu True "TMU_WTD" ([2..6]) racks trials "TMU WATER-TEMP DELTA" x y [0,5,10]
-------------------------------------------------------------------------------
chillers isLD = do
  let chillers = if isLD then ["C1","C2","C4"] else ["C1","C4"]
      trials = ["t01","t02","t03"] 
      dex = if isLD then [2,3,5] else [2,5]
  gnu_metric isLD "/ChillerMeasurement/" "KW" 30
  gnu_metric isLD "/ChillerMeasurement/" "Loads" 30
  gnu_form_metric isLD "/ChillerMeasurement/" (/) "Loads" "KW" "COP" 30
  gnu_form_metric isLD "/ChillerMeasurement/" (-) "LCWT" "ECWT" "C_WTD" 30
  gnu_form_metric isLD "/ChillerMeasurement/" (-) "ECHWT" "LCHWT" "CH_WTD" 30
  (x,y) <- get_ranges isLD extract "KW" 0
  batched_gnu isLD "KW" dex chillers trials "KW" x y [0,5,10]
  (x,y) <- get_ranges isLD extract "Loads" 0
  batched_gnu isLD "Loads" dex chillers trials "Loads" x y [0,5,10]
  (x,y) <- get_ranges isLD extract_NaN "COP" 0.1
  batched_gnu isLD "COP" dex chillers trials "COP" x y [0,5,10]
  (x,y) <- get_ranges isLD extract "C_WTD" 3
  batched_gnu isLD "C_WTD" dex chillers trials "CONDENSER WATER-TEMP DELTA" x y [0,5,10]
  (x,y) <- get_ranges isLD extract "CH_WTD" 3
  batched_gnu isLD "CH_WTD" dex chillers trials "CHILLER WATER-TEMP DELTA" x y [0,5,10]
-------------------------------------------------------------------------------
chiller_clustering isLD = do
  let trials = ["t01","t02","t03"]
      modes = [WriteMode,AppendMode,AppendMode]
      tss = if isLD then [[(0+k,3)] | k<-[0,3,6]]
            else [[(0+k,2)] | k<-[0,2,4]]
      dir = if isLD then "/cluster/ld/CH_WTD" 
            else "/cluster/hd/CH_WTD" 
  forM_ (zip3 trials modes tss) $ \(trial,mode,ts) ->
    elkify isLD True (extract_thresh 0) "CH_WTD" trial mode ts
  elki_cli dir em 3
  let dir = if isLD then "/cluster/ld/Loads" 
            else "/cluster/hd/Loads"
  forM_ (zip3 trials modes tss) $ \(trial,mode,ts) ->
    elkify isLD True (extract_thresh 0) "Loads" trial mode ts
  elki_cli dir em 3
  let dir = if isLD then "/cluster/ld/KW" 
            else "/cluster/hd/KW"
  forM_ (zip3 trials modes tss) $ \(trial,mode,ts) ->
    elkify isLD True (extract_thresh 0) "KW" trial mode ts
  elki_cli dir em 3
  let dir = if isLD then "/cluster/ld/COP" 
            else "/cluster/hd/COP"
  forM_ (zip3 trials modes tss) $ \(trial,mode,ts) ->
    elkify isLD True extract_NaN "COP" trial mode ts
  elki_cli dir em 3
