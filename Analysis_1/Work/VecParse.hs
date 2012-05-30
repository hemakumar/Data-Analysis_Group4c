{-# LANGUAGE BangPatterns #-}
-------------------------------------------------------------------------------
module Work.VecParse 
  (points
  ,vecs
  ,vecify
  ,ld
  ,hd
  ,pc
  ,extract
  ,extract_thresh
  ,extract_NaN
  ,extract_norm
  ,vec_delta
  ,vec_avg
  ,vec_max
  ,vec_min
  ) where
-------------------------------------------------------------------------------
import System.Directory
import System.IO
import qualified Data.ByteString.Char8                                     as B
import Text.CSV.ByteString
import Data.ByteString.Lex.Double                                  (readDouble)
import qualified Data.Vector                                               as V
import Data.Maybe
import Data.List
-------------------------------------------------------------------------------
ld,hd,pc -- | * these paths must be changed to match your computer
  :: FilePath
-------------------------------------------------------------------------------
ld = "LD_A1_56p_2ppn_28n_IO-BASIC_even_RAWDATA"
hd = "HD_A1_224p_8ppn_28n_RAWDATA"
pc = "/POWER-COOLING_perMetricPerTrial"
-------------------------------------------------------------------------------
points
  :: FilePath                                                 -- ^ path to data
  -> IO [B.ByteString]             -- ^ convert file into a list of bytestrings
-------------------------------------------------------------------------------
points dat = do
  str <- B.readFile dat
  let str'  = fromMaybe [] (parseCSV str)
      vs = map last str'
  return vs
-------------------------------------------------------------------------------
vecs
  :: FilePath                                                 -- ^ path to data
  -> IO (V.Vector Double)                     -- ^ convert a file into a vector
-------------------------------------------------------------------------------
vecs dat = do
  str <- points dat
  let f = vecify . B.unwords
  return $ f str
-------------------------------------------------------------------------------
vecify 
  :: B.ByteString
  -> V.Vector Double         -- ^ parse a bytestring, by doubles, into a vector
-------------------------------------------------------------------------------
vecify = V.unfoldr step
  where
  step !s = case readDouble s of
              Nothing      -> Nothing
              Just (!k,!t) -> case B.uncons t of
                                Nothing -> Just (k,t)
                                other   -> Just (k,B.tail t)
-------------------------------------------------------------------------------
extract 
  :: FilePath
  -> IO [(Int, V.Vector Double)]                -- ^ [(time, vector of values)]
-------------------------------------------------------------------------------
extract dat = do
  str <- B.readFile dat
  let f = catMaybes . map B.readInt . B.lines
      vals = map (\(c,s) -> (c,vecify $ B.tail s)) $ f str
  return vals
-------------------------------------------------------------------------------
extract_thresh 
  :: Double                               -- ^ threshold to filter from vectors
  -> FilePath
  -> IO [(Int, V.Vector Double)]
-------------------------------------------------------------------------------
extract_thresh thr dat = do
  str <- B.readFile dat
  let f = catMaybes . map B.readInt . B.lines
      g = V.filter (>thr) . vecify . B.tail
      vals = map (\(c,s) -> (c,g s)) $ f str
  return vals
-------------------------------------------------------------------------------
extract_NaN 
  :: FilePath
  -> IO [(Int, V.Vector Double)]       -- ^ NaN values are removed from vectors
-------------------------------------------------------------------------------
extract_NaN dat = do
  str <- B.readFile dat
  let f = catMaybes . map B.readInt . B.lines
      e = not . isInfixOf "NaN"
      g = vecify . B.pack . unwords . filter e . words . B.unpack . B.tail
      vals = map (\(c,s) -> (c,g s)) $ f str
  return vals
-------------------------------------------------------------------------------
extract_norm
  :: FilePath
  -> IO [(Int, V.Vector Double)]              -- ^ vector values are normalized
-------------------------------------------------------------------------------
extract_norm dat = do
  cvs <- extract dat
  return $ normalize cvs
-------------------------------------------------------------------------------
vec_delta 
  :: V.Vector Double
  -> Double
-------------------------------------------------------------------------------
vec_delta v = V.maximum v-V.minimum v
-------------------------------------------------------------------------------
vec_avg,vec_max,vec_min
  :: V.Vector Double
  -> Double
-------------------------------------------------------------------------------
vec_avg v = V.sum v/(fromIntegral $ V.length v)
vec_max v = V.maximum v
vec_min v = V.minimum v
-------------------------------------------------------------------------------
normalize dat = zip cs norms
  where
  (cs,as) = unzip dat
  denom   = V.zipWith (-) (maxima as) (minima as)
  norms   = map (\a -> V.zipWith (/) (V.zipWith (-) a $ minima as) denom) as
-------------------------------------------------------------------------------
minima = V.fromList . map minimum . transpose . map V.toList
maxima = V.fromList . map maximum . transpose . map V.toList

