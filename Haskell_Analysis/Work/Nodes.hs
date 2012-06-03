{- Michael Novak
 - mnovak@cecs.pdx.edu
 - 5-31-2012
 -}
-------------------------------------------------------------------------------
module Work.Nodes where
-------------------------------------------------------------------------------
import System.Directory
import System.IO
import Data.List  
import Control.Monad
import qualified Data.Vector                                               as V
-------------------------------------------------------------------------------
import Work.VecParse
-------------------------------------------------------------------------------
node_metric -- | The metric is averaged over every node, and everything pertaining to the metric in each node.
  :: (Double, Double)                                 -- ^ (min,max) thresholds
  -> (V.Vector Double -> Double)         -- ^ vector function to map over nodes
  -> Bool                                                           -- ^ is LD?
  -> String                                                           -- ^ rack
  -> String                                                          -- ^ trial
  -> String                               -- ^ /subdirectory containing metric/
  -> String                              -- ^ rack component (trial_thing_rack)
  -> String                                            -- ^ metric (metric.csv)
  -> IO (Int, [Double])                -- ^ (node count, [values at each node])
-------------------------------------------------------------------------------
node_metric (min,max) vec_f isLD rack trial dir thing metric = do
  let stem = if isLD then ld++pc++dir else hd++pc++dir
  ds <- getDirectoryContents stem
  let ds' = filter (isSuffixOf $ metric++".csv") ds
      files = filter (isInfixOf $ trial++"_"++thing++"_"++rack) ds'
  nodes <- forM files $ \file -> vecs $ stem++file
  let low = filter (V.all (>min)) nodes    -- eliminate faulty sensor readings
      high = filter (V.all (<max)) low   -- eliminate faulty sensor readings
      per_node = map vec_f high
  return (length per_node,per_node)
-------------------------------------------------------------------------------
node_form_metric -- | Two metrics are combined; the combined metric is averaged over every node, and everything pertaining to the metric in each node.
  :: (Double, Double)                                 -- ^ (min,max) thresholds
  -> (V.Vector Double -> Double)         -- ^ vector function to map over nodes
  -> Bool                                                           -- ^ is LD?
  -> String                                                           -- ^ rack
  -> String                                                          -- ^ trial
  -> String                              -- ^ /subdirectory containing metrics/
  -> String                              -- ^ rack component (trial_thing_rack)
  -> (Double -> Double -> Double)         -- ^ zipWith op: metric1 (op) metric2
  -> String                                          -- ^ metric1 (metric1.csv)
  -> String                                          -- ^ metric2 (metric2.csv)
  -> IO (Int, [Double])                -- ^ (node count, [values at each node])
-------------------------------------------------------------------------------
node_form_metric (min,max) vec_f isLD rack trial dir thing op metric1 metric2 = do
  let stem = if isLD then ld++pc++dir else hd++pc++dir
  ds <- getDirectoryContents stem
  let ds1 = filter (isSuffixOf $ metric1++".csv") ds
      ds2 = filter (isSuffixOf $ metric2++".csv") ds
      files1 = filter (isInfixOf $ trial++"_"++thing++"_"++rack) ds1
      files2 = filter (isInfixOf $ trial++"_"++thing++"_"++rack) ds2
  nodes1 <- forM files1 $ \file1 -> vecs $ stem++file1
  nodes2 <- forM files2 $ \file2 -> vecs $ stem++file2
  let low = filter (V.all (>min)) $ zipWith (V.zipWith op) nodes1 nodes2
      high = filter (V.all (<max)) low      -- eliminate faulty sensor readings
      per_node = map vec_f high
  return (length per_node,per_node)
