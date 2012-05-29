module Work.Plot 
  (gnu_metric
  ,gnu_form_metric
  ,generate_gnu
  ,batched_gnu
  ,get_ranges
  ,plotify_all) where
-------------------------------------------------------------------------------
import System.Directory
import System.IO
import Data.List      
import Control.Monad
import qualified Data.Vector                                               as V
import qualified Data.ByteString.Char8                                     as B
import System.Process                                     
import Data.Function                                                       (on)
-------------------------------------------------------------------------------
import Work.Parse
import Work.Color
-------------------------------------------------------------------------------
gnu_metric
  :: Bool                                                           -- ^ is LD?
  -> String                               -- ^ /subdirectory containing metric/
  -> String         -- ^ name for metric value, must match original .csv suffix
  -> Int                                                    -- ^ time step size
  -> IO ()                     -- ^ create dat file for 'generate_gnu' function
-------------------------------------------------------------------------------
gnu_metric isLD dir val step = do
  let stem = if isLD then ld++pc++dir else hd++pc++dir
  ds <- getDirectoryContents stem
  let ds' = filter (isSuffixOf $ val++".csv") ds
  createDirectoryIfMissing True "gnu"
  if isLD then mapM_ (createDirectoryIfMissing True) ["gnu/ld","gnu/ld/plot"]
  else mapM_ (createDirectoryIfMissing True) ["gnu/hd","gnu/hd/plot"]
  out1 <- if isLD then openFile ("gnu/ld/plot/"++val++".dat") WriteMode
          else openFile ("gnu/hd/plot/"++val++".dat") WriteMode
  ps <- forM ds' $ \d -> points $ stem++d
  let f = \a b -> a`B.append`(B.pack " ")`B.append`b
      ps' = foldl1' (zipWith f) ps
      ts = map (B.pack . show) [0,step..]
      pts = zipWith f ts ps' 
  forM_ pts $ \pt -> do
    B.hPutStrLn out1 pt
  hClose out1
-------------------------------------------------------------------------------
gnu_form_metric 
  :: Bool                                                           -- ^ is LD?
  -> String                             -- ^ "/subdirectory containing metric/"
  -> (Double -> Double -> Double)         -- ^ zipWith op: metric_a op metric_b
  -> String                        -- ^ name for metric_a (.csv suffix proviso)
  -> String                        -- ^ name for metric_b (.csv suffix proviso)
  -> String                                       -- ^ name for combined metric
  -> Int                                                    -- ^ time step size
  -> IO ()                     -- ^ create dat file for 'generate_gnu' function
-------------------------------------------------------------------------------
gnu_form_metric isLD dir op val_a val_b name step = do
  let stem = if isLD then ld++pc++dir else hd++pc++dir
  ds <- getDirectoryContents stem
  let d_a = filter (isSuffixOf $ val_a++".csv") ds
      d_b = filter (isSuffixOf $ val_b++".csv") ds
  p_a <- forM d_a $ \d -> vecs $ stem++d
  p_b <- forM d_b $ \d -> vecs $ stem++d
  createDirectoryIfMissing True "gnu"
  if isLD then mapM_ (createDirectoryIfMissing True) ["gnu/ld","gnu/ld/plot"]
  else mapM_ (createDirectoryIfMissing True) ["gnu/hd","gnu/hd/plot"]
  outh <- if isLD then openFile ("gnu/ld/plot/"++name++".dat") WriteMode
          else openFile ("gnu/hd/plot/"++name++".dat") WriteMode
  let utils = zipWith (V.zipWith op) p_a p_b
      utils' = map (V.map (B.pack . show)) utils
      f = \a b -> a`B.append`(B.pack " ")`B.append`b
      ps = V.toList $ foldl1' (V.zipWith f) utils'
      ts = map (B.pack . show) [0,step..]
  forM_ (zip ts ps) $ \(t,p) -> do
    B.hPutStr outh $ t`B.append`B.pack " "
    B.hPutStrLn outh p
  hClose outh
-------------------------------------------------------------------------------
generate_gnu 
  :: Bool                                                           -- ^ is LD?
  -> String                                               -- ^ name of dat file
  -> [Int]                            -- ^ column indices to use as data points
  -> [String]                                                        -- ^ racks
  -> String                                                          -- ^ trial
  -> String                                -- ^ name for y-axis in gnuplot file
  -> (Int, Int)                                   -- ^ x-range for gnuplot file
  -> (Double, Double)                             -- ^ y-range for gnuplot file
  -> IO ()                                           -- ^ generate gnuplot file
-------------------------------------------------------------------------------
generate_gnu isLD name dexs racks trial label x_range y_range = do
  createDirectoryIfMissing True "gnu"
  if isLD then createDirectoryIfMissing True "gnu/ld"
  else createDirectoryIfMissing True "gnu/hd"
  outh <- if isLD then openFile ("gnu/ld/"++name++"_"++trial++".gnu") WriteMode
          else openFile ("gnu/hd/"++name++"_"++trial++".gnu") WriteMode
  hPutStrLn outh "reset"
  if isLD then
    hPutStrLn outh "set terminal pngcairo size 640,480 enhanced font \'Verdana,9\'"
  else 
    hPutStrLn outh "set terminal pngcairo size 1152,720 enhanced font \'Verdana,9\'"
  let box = if isLD then "\'gnu/ld/plot/"++name++"_"++trial++".png\'"
            else "\'gnu/hd/plot/"++name++"_"++trial++".png\'"
  hPutStrLn outh $ "set output "++box
  hPutStrLn outh "set style line 11 lc rgb \'#808080\' lt 1"
  hPutStrLn outh "set border 3 back ls 11"
  hPutStrLn outh "set tics nomirror"
  hPutStrLn outh "set style line 12 lc rgb \'#808080\' lt 0 lw 1"
  hPutStrLn outh "set grid back ls 12"
  let n = length racks
      cs = color n
  forM_ (zip [1..n] cs) $ \(i,c) ->
    hPutStrLn outh $ "set style line "++show i++" lc rgb \'"++c++"\' pt 0 ps 1 lt 1 lw 4"
  hPutStrLn outh $ "set key bottom rmargin title \'"++trial++"\'"
  hPutStrLn outh "set xlabel \'SEC\'"
  hPutStrLn outh $ "set ylabel \'"++label++"\'"
  hPutStrLn outh $ "set xrange ["++(show $ fst x_range)++":"++(show $ snd x_range)++"]"
  hPutStrLn outh $ "set yrange ["++(show $ fst y_range)++":"++(show $ snd y_range)++"]"
  if isLD then hPutStrLn outh "set xtics 60"
  else hPutStrLn outh "set xtics 180"
  let dps = zip3 dexs racks [1..length racks]
      (i_1,t_1,c_1) = head dps
      lk = init $ tail dps
      (i_n,t_n,c_n) = last dps
      box = if isLD then "plot \'gnu/ld/plot/"++name++".dat\'"
            else "plot \'gnu/hd/plot/"++name++".dat\'"
  hPutStr outh box
  hPutStrLn outh $ " u 1:($"++show i_1++") t \'"++t_1++"\' w lp ls "++show c_1++",\\"
  forM_ lk $ \(i_k,t_k,c_k) ->
    hPutStrLn outh $ "\'\' u 1:($"++show i_k++") t \'"++t_k++"\' w lp ls "++show c_k++",\\"
  hPutStrLn outh $ "\'\' u 1:($"++show i_n++") t \'"++t_n++"\' w lp ls "++show c_n
  hClose outh
-------------------------------------------------------------------------------
batched_gnu
  :: Bool                                                           -- ^ is LD?
  -> String                                               -- ^ name of dat file
  -> [Int]                            -- ^ column indices to use as data points
  -> [String]                                                        -- ^ racks
  -> [String]                                                       -- ^ trials
  -> String                                -- ^ name for y-axis in gnuplot file
  -> (Int,Int)                                    -- ^ x-range for gnuplot file
  -> (Double,Double)                              -- ^ y-range for gnuplot file
  -> [Int]                                      -- ^ column step for each trial
  -> IO ()                           -- ^ generate gnuplot files for each trial
-------------------------------------------------------------------------------
batched_gnu isLD name dexs racks trials label x_range y_range fs =
  forM_ (zip fs trials) $ \(f,t) ->
    generate_gnu isLD name (map (+f) dexs) racks t label x_range y_range
-------------------------------------------------------------------------------
get_ranges
  :: Bool                                                           -- ^ is LD?
  -> (String -> IO [(Int, V.Vector Double)])        -- ^ load data into vectors
  -> String                                               -- ^ name of dat file
  -> Double                               -- ^ threshold to filter from vectors
  -> IO ((Int, Int), (Double, Double))
-------------------------------------------------------------------------------
get_ranges isLD f name thresh = do
   hat <- if isLD then f $ "gnu/ld/plot/"++name++".dat"
          else f $ "gnu/hd/plot/"++name++".dat"
   let x_min = fst $ minimumBy (compare`on`fst) hat
       x_max = fst $ maximumBy (compare`on`fst) hat     
       f_min = V.minimum . V.filter (>thresh) . snd
       f_max = V.maximum . snd
       y_min = f_min $ minimumBy (compare`on`f_min) hat     
       y_max = f_max $ maximumBy (compare`on`f_max) hat     
   return ((x_min,x_max),(y_min,y_max))
-------------------------------------------------------------------------------
plotify_all
  :: Bool                                                           -- ^ is LD?
  -> IO ()      -- ^ execute gnuplot on all the gnu files and produce png files
-------------------------------------------------------------------------------
plotify_all isLD = do
  let dir = if isLD then "gnu/ld/" else "gnu/hd/"
  ds <- getDirectoryContents dir
  let ds' = filter (isSuffixOf ".gnu") ds
  forM_ ds' $ \d -> rawSystem "gnuplot" [dir++d]
