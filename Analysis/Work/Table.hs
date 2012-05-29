module Work.Table where
-------------------------------------------------------------------------------
import System.Directory
import System.IO
import Data.List  
import Control.Monad
import qualified Data.Vector                                               as V
import Text.Printf
import Data.Char                                                      (toLower)
-------------------------------------------------------------------------------
import Work.Parse
import Work.Nodes
-------------------------------------------------------------------------------
latex_node_metric
  :: (Double, Double)                                 -- ^ (min,max) thresholds
  -> (V.Vector Double -> Double)         -- ^ vector function to map over nodes
  -> ((Int, [Double]) -> Double)   -- ^ reduce a list of node values for a rack  
  -> String                                           -- ^ function description
  -> Bool                                                           -- ^ is LD?
  -> [String]                                                        -- ^ racks
  -> [String]                                                       -- ^ trials
  -> String                               -- ^ /subdirectory containing metric/
  -> String                              -- ^ rack component (trial_thing_rack)
  -> String                                            -- ^ metric (metric.csv)
  -> IO ()                                     -- ^ create latex file for table
-------------------------------------------------------------------------------
latex_node_metric (min,max) vec_f f f_name isLD racks trials dir thing metric = do
  let wl = if isLD then "ld/" else "hd/"
      file = map toLower $ thing++"_"++metric
      n = length racks
      name = file++f_name
  createDirectoryIfMissing True "table"
  createDirectoryIfMissing True $ "table/"++wl
  outh <- openFile ("table/"++wl++name++".tex") WriteMode
  let cols = replicate n 'c'
  hPutStrLn outh $ "\\begin{tabular}{r|"++cols++"}\\cline{2-"++(show $ succ n)++"}"
  hPutStr outh $ "\\tt "++thing++" "++metric
  forM_ racks $ \r -> do
    hPutStr outh $ "&$\\bf "++r++"$"
  hPutStrLn outh "\\\\\\hline"
  forM_ trials $ \t -> do
    hats <- mapM (\r -> node_metric (min,max) vec_f isLD r t dir thing metric) racks
    hPutStr outh $ "\\bf "++t
    mapM_ (\v -> hPrintf outh "& %.2f" $ f v) hats
    hPutStrLn outh "\\\\"
  hPutStrLn outh "\\hline"
  hPutStr outh $ "\\tt Total "++thing
  let t = head trials
  hats <- mapM (\r -> node_metric (min,max) vec_f isLD r t dir thing metric) racks
  mapM_ (\v -> hPutStr outh $ "& "++(show $ fst v)) hats
  hPutStrLn outh "\\\\"
  hPutStrLn outh "\\end{tabular}"
  hClose outh
-------------------------------------------------------------------------------
latex_node_form_metric
  :: (Double, Double)                                 -- ^ (min,max) thresholds
  -> (V.Vector Double -> Double)         -- ^ vector function to map over nodes
  -> ((Int, [Double]) -> Double)   -- ^ reduce a list of node values for a rack  
  -> String                                           -- ^ function description
  -> Bool                                                           -- ^ is LD?
  -> [String]                                                        -- ^ racks
  -> [String]                                                       -- ^ trials
  -> String                              -- ^ /subdirectory containing metrics/
  -> String                              -- ^ rack component (trial_thing_rack)
  -> (Double -> Double -> Double)         -- ^ zipWith op: metric1 (op) metric2
  -> String                                          -- ^ metric1 (metric1.csv)
  -> String                                          -- ^ metric2 (metric2.csv)
  -> String                                    -- ^ combined metric description
  -> IO ()                                     -- ^ create latex file for table
-------------------------------------------------------------------------------
latex_node_form_metric (min,max) vec_f f f_name isLD racks trials dir thing 
                       op metric1 metric2 label = do
  let wl = if isLD then "ld/" else "hd/"
      file = map toLower $ thing++"_"++label
      n = length racks
      name = file++f_name
  createDirectoryIfMissing True "table"
  createDirectoryIfMissing True $ "table/"++wl
  outh <- openFile ("table/"++wl++name++".tex") WriteMode
  let cols = replicate n 'c'
  hPutStrLn outh $ "\\begin{tabular}{r|"++cols++"}\\cline{2-"++(show $ succ n)++"}"
  hPutStr outh $ "\\tt "++thing++" "++label
  forM_ racks $ \r -> do
    hPutStr outh $ "&$\\bf "++r++"$"
  hPutStrLn outh "\\\\\\hline"
  forM_ trials $ \t -> do
    hats <- mapM (\r -> node_form_metric (min,max) vec_f isLD r t dir thing op metric1 metric2) racks
    hPutStr outh $ "\\bf "++t
    mapM_ (\v -> hPrintf outh "& %.2f" $ f v) hats
    hPutStrLn outh "\\\\"
  hPutStrLn outh "\\hline"
  hPutStr outh $ "\\tt Total "++thing
  let t = head trials
  hats <- mapM (\r -> node_form_metric (min,max) vec_f isLD r t dir thing op metric1 metric2) racks
  mapM_ (\v -> hPutStr outh $ "& "++(show $ fst v)) hats
  hPutStrLn outh "\\\\"
  hPutStrLn outh "\\end{tabular}"
  hClose outh
-------------------------------------------------------------------------------
node_avg,node_max,node_min
  :: (Int, [Double])
  -> Double                        -- ^ reduce a list of node values for a rack
-------------------------------------------------------------------------------
node_avg (n,vs) = sum vs/(fromIntegral n)
node_max (n,vs) = maximum vs
node_min (n,vs) = minimum vs
