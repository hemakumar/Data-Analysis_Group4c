{- Michael Novak
 - mnovak@cecs.pdx.edu
 - 5-31-2012
 -}
-------------------------------------------------------------------------------
{- make an executable:
 - ghc --make analysis
 - ./analysis <[em|k-means]> <k>
 -}
-------------------------------------------------------------------------------
import System.Process                                     
import System.IO
import System.Directory
import Control.Monad
import qualified Data.Vector                                               as V
import Data.List
import Data.Function
import Data.Map                                                           (Map)
import qualified Data.Map                                                  as M
import Data.Maybe
import System                                                         (getArgs)
-------------------------------------------------------------------------------
import Work.VecParse
import Work.Table
import Work.Plot
import Work.ClusterReader
import Work.Cluster
-------------------------------------------------------------------------------
main = do
  args <- getArgs
  when (length args/=2) $ fail "Expecting: <clustering algorithm> <k>"
  let alg_in  = head args
      k_in = (read $ last args)::Int
  when (k_in<3) $ fail "k must be greater than 2"
  when (k_in>11) $ fail "k > 11 is not yet implemented -- colors become indistinguishable beyond 11"
  ask <- doesDirectoryExist "table"
  unless ask $ mapM_ tables [True,False]
  ask <- doesDirectoryExist "gnu"
  when ask $ putStrLn "Overwriting gnu & cluster directories ..."
  tmu k_in
  forM_ [power,chillers] $ \f -> mapM_ f $ zip [True,False] [k_in,k_in]
  let automagic = map reader 
                  [wl++" "++m++" "++alg_in++" "++show k_in 
                  | wl <- ["ld","hd"], m <- ["C_WTD","CH_WTD","COP","KW","Loads"]]
  forM_ [make_things,organize_things,render_things] $ \f -> mapM_ f automagic
-------------------------------------------------------------------------------
class Workflow a where
  make_things :: a -> IO ()
  organize_things :: a -> IO ()
  render_things :: a -> IO ()
-------------------------------------------------------------------------------
instance Workflow Chiller where   
-------------------------------------------------------------------------------
  make_things (Chiller isLD metric alg k) = do
    let trials = ["t01","t02","t03"]
        modes = [WriteMode,AppendMode,AppendMode]
        tss = if isLD then [[(0+i,3)] | i<-[0,3,6]]
              else [[(0+i,2)] | i<-[0,2,4]]
        dir = if isLD then "/cluster/ld/"++metric 
              else "/cluster/hd/"++metric
    forM_ (zip3 trials modes tss) $ \(trial,mode,ts) -> do
      if metric=="COP" then elkify isLD True extract_NaN "COP" trial mode ts
      else elkify isLD True (extract_thresh 0) metric trial mode ts
    elki_cli dir alg
    return ()
-------------------------------------------------------------------------------
  organize_things (Chiller isLD metric alg k) = do
    let dir = if isLD then "cluster/ld/"++metric 
              else "cluster/hd/"++metric
        ck = [(i,dir++"/cluster_"++show i++".txt") | i <- [0..pred k]]
        thing = M.empty
    ms <- forM ck $ \(k',txt) -> do
      clu <- readFile txt
      let f = map (read . last . words) . filter (notElem '#') . lines
          tus = (f clu)::[(Int, Int)]
      return [((trial,sec),k') | (trial,sec) <- tus]
    let ms' = concat ms
        hat = foldr (\((trial,sec),k') -> M.insert (trial,sec) (sec,k')) M.empty ms'
    forM_ ([1..3]::[Int]) $ \trial -> do
      let l' = M.elems $ M.filterWithKey (\(t,_) _ -> t==trial) hat
      outh <- openFile (dir++"/t0"++show trial++".dat") WriteMode
      mapM_ (\(sec,kk) -> hPutStrLn outh $ show sec++" "++show kk) l'
      hClose outh
-------------------------------------------------------------------------------
  render_things f = do
    let dir = if (notHD f) then "cluster/ld/"++metric f
              else "cluster/hd/"++metric f
    ds <- getDirectoryContents dir
    let ds' = filter (isPrefixOf $ metric f) ds
        ds'' = filter (isSuffixOf ".gnu") ds'
    forM_ ds'' $ \d -> rawSystem "gnuplot" [dir++"/"++d]
-------------------------------------------------------------------------------
instance Workflow Batch where
  make_things (Batch isLD name dexs racks trials label x_range y_range fs cluster_k) =
    forM_ (zip fs trials) $ \(f,t) ->
      generate_gnu isLD name (map (+f) dexs) racks t label x_range y_range
-------------------------------------------------------------------------------
  organize_things (Batch isLD name dexs racks trials label x_range y_range fs cluster_k) =
    forM_ (zip fs trials) $ \(f,t) -> do
      generate_cluster isLD name (map (+f) dexs) racks t label x_range y_range cluster_k
-------------------------------------------------------------------------------
  render_things b = do
    let dir = if (isLD b) then "gnu/ld/" else "gnu/hd/"
    ds <- getDirectoryContents dir
    let ds' = filter (isPrefixOf $ name b) ds
        ds'' = filter (isSuffixOf ".gnu") ds'
    forM_ ds'' $ \d -> rawSystem "gnuplot" [dir++d]
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
power (ask,k') = do
  let racks = ["A1","A3","A4","B1","B2","B3","B4"]
      trials = ["t01","t02","t03"]
  let dir = "/PowerUnit/"
  gnu_metric ask dir "PowerKWH" 10
  let threshold = if ask then 130 else 250
  (x,y) <- get_ranges ask extract "PowerKWH" threshold
  let batch = Batch ask "PowerKWH" ([2]++[4..9]) racks trials "POWER-UNIT KWH" x y [0,8,16] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
-------------------------------------------------------------------------------
tmu k' = do
  let dir = "/ThermalManagementUnit/"
  gnu_metric True dir "ManifoldPress" 10
  gnu_form_metric True dir (-) "WaterOutletTemp" "WaterInletTemp" "TMU_WTD" 10
  (x,y) <- get_ranges True extract "ManifoldPress" 21
  let racks = ["A1","B1","B2","B3","B4"]
      trials = ["t01","t02","t03"]
      batch = Batch True "ManifoldPress" ([2..6]) racks trials "TMU MANIFOLD PRESSURE" 
              x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
  (x,y) <- get_ranges True extract "TMU_WTD" 0.5
  let batch = Batch True "TMU_WTD" ([2..6]) racks trials "TMU WATER-TEMP DELTA"
              x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
-------------------------------------------------------------------------------
chillers (ask,k') = do
  let chillers = if ask then ["C1","C2","C4"] else ["C1","C4"]
      trials = ["t01","t02","t03"] 
      dex = if ask then [2,3,5] else [2,5]
  gnu_metric ask "/ChillerMeasurement/" "KW" 30
  gnu_metric ask "/ChillerMeasurement/" "Loads" 30
  gnu_form_metric ask "/ChillerMeasurement/" (/) "Loads" "KW" "COP" 30
  gnu_form_metric ask "/ChillerMeasurement/" (-) "LCWT" "ECWT" "C_WTD" 30
  gnu_form_metric ask "/ChillerMeasurement/" (-) "ECHWT" "LCHWT" "CH_WTD" 30
  (x,y) <- get_ranges ask extract "KW" 0
  let batch = Batch ask "KW" dex chillers trials "KW" x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
  (x,y) <- get_ranges ask extract "Loads" 0
  let batch = Batch ask "Loads" dex chillers trials "Loads" x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
  (x,y) <- get_ranges ask extract_NaN "COP" 0.1
  let batch = Batch ask "COP" dex chillers trials "COP" x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
  (x,y) <- get_ranges ask extract "C_WTD" 3
  let batch = Batch ask "C_WTD" dex chillers trials "CONDENSER WATER-TEMP DELTA"
              x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
  (x,y) <- get_ranges ask extract "CH_WTD" 3
  let batch = Batch ask "CH_WTD" dex chillers trials "CHILLER WATER-TEMP DELTA"
              x y [0,5,10] k'
  forM_ [make_things,organize_things,render_things] $ \f -> f batch
{-
-------------------------------------------------------------------------------
-- | rudimentary user interface
-------------------------------------------------------------------------------
clustering = do
  putStrLn "<workload> <chiller metric> <clustering algorithm> <k>"
  putStrLn "example: hd KW em 3"
  hFlush stdout
  l <- getLine
  let form = reader l
  forM_ [make_things,organize_things,render_things] $ \f -> f form
  putStrLn "more: (yes/no)"
  hFlush stdout
  l <- getLine
  let ask = head l=='y'  
  when ask clustering
-------------------------------------------------------------------------------
    let stem = if isLD then "gnu/ld/plot/" else "gnu/hd/plot/" 
    ds <- getDirectoryContents stem
    let ds' = filter (isSuffixOf $ metric++".dat") ds
        place = if isLD then "cluster/ld/"++metric++"/"
                else "cluster/hd/"++metric++"/"
    forM_ ds' $ \d -> copyFile (stem++d) $ place++d
    let stem = if isLD then "gnu/ld/" else "gnu/hd/" 
    ds <- getDirectoryContents stem
    let ds' = filter (isInfixOf $ metric++"_") ds
        ds'' = filter (isSuffixOf ".gnu") ds'
    forM_ ds'' $ \d -> copyFile (stem++d) $ place++d
-}

