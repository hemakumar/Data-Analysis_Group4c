{- Michael Novak
 - mnovak@cecs.pdx.edu
 - 5-31-2012
 -}
-------------------------------------------------------------------------------
module Work.Cluster (elki_cli,kmeans,em,elkify) where
-------------------------------------------------------------------------------
import System.Directory
import System.IO
import qualified Data.ByteString.Char8                                     as B
import Data.List                                                      (foldl1')
import System.Process                                     
import System.Exit
import Control.Monad
import qualified Data.Vector                                               as V
-------------------------------------------------------------------------------
import Work.VecParse
-------------------------------------------------------------------------------
elki :: FilePath
-------------------------------------------------------------------------------
elki = "elki.jar"
-------------------------------------------------------------------------------
elki_cli -- | * ELKI command line 
  :: FilePath                        -- ^ path to csv files created by 'elkify'
  -> [String]                                             -- ^ 'kmeans' or 'em' 
  -> IO ExitCode             -- ^ execute ELKI clustering; output files created
-------------------------------------------------------------------------------
elki_cli from alg = do
  here <- getCurrentDirectory
  rawSystem "java" $ cli++(dbc_in here)++alg++(out here)
  where 
  cli =  ["-cp",elki,"de.lmu.ifi.dbs.elki.application.KDDCLIApplication"]
  dbc_in here = ["-dbc.in",here++from++".csv"]
  out here = ["-out",here++from]
-------------------------------------------------------------------------------
kmeans,em
  :: Int                                                -- ^ number of clusters
  -> [String]                 -- ^ flags for running ELKI clustering algorithms
-------------------------------------------------------------------------------
kmeans k = ["-algorithm","clustering.KMeans","-kmeans.k",show k]
-------------------------------------------------------------------------------
em k = ["-algorithm","clustering.EM","-em.k",show k]
-------------------------------------------------------------------------------
elkify
  :: Bool                                                            -- ^ isLD?
  -> Bool                  -- ^ do you want seconds retained in cluster labels?
  -> (FilePath -> IO [(Int, V.Vector Double)])       -- ^ function from 'Parse'
  -> String                        -- ^ name of metric contained in gnuplot dat
  -> String                                                          -- ^ trial
  -> IOMode                       -- ^ start with 'WriteMode' then 'AppendMode'
  -> [(Int, Int)]                                          -- ^ slicing indices
  -> IO ()                                         -- ^ make csv files for ELKI
-------------------------------------------------------------------------------
elkify isLD sec f name trial mode ts = do
  let thing = if isLD then "gnu/ld/plot/"++name++".dat"
              else "gnu/hd/plot/"++name++".dat"
  hat <- f thing
  let (cs,vs) = unzip hat
      pts = map (slicer ts) vs
      t = (last trial):[]
      labels | sec = [B.pack $ "("++t++","++show c++")" | c <- cs]
             | otherwise = [B.pack trial | c <- cs]
  createDirectoryIfMissing True "cluster"
  if isLD then createDirectoryIfMissing True "cluster/ld"
  else createDirectoryIfMissing True "cluster/hd"
  let file = if isLD then "cluster/ld/"++name++".csv"
             else "cluster/hd/"++name++".csv"
  outh <- openFile file mode
  B.hPutStrLn outh $ B.pack $ replicate 79 '#' 
  B.hPutStrLn outh $ B.pack $ "## "++trial++name
  B.hPutStrLn outh $ B.pack $ replicate 79 '#' 
  forM_ (zip pts labels) $ \(pv,l) -> do
    V.forM_ pv $ \p -> B.hPutStr outh (B.pack $ show p++" ")
    B.hPutStrLn outh l
  hClose outh
-------------------------------------------------------------------------------
slicer ts v = V.concat [V.slice s n v | (s,n) <- ts]
-------------------------------------------------------------------------------
