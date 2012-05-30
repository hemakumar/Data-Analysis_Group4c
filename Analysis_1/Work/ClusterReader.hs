module Work.ClusterReader (Metric(..),Cluster(..),reader) where
-------------------------------------------------------------------------------
import Text.ParserCombinators.Parsec                               hiding (try)
import qualified Text.ParserCombinators.Parsec.Char                        as C
import qualified Text.ParserCombinators.Parsec.Token                       as T
import Text.ParserCombinators.Parsec.Language                        (emptyDef)
import System.Directory
import System.IO
import Control.Monad
-------------------------------------------------------------------------------
import Work.Cluster                                                  
import Work.VecParse
-------------------------------------------------------------------------------
lexer :: T.TokenParser ()
lexer = T.makeTokenParser emptyDef
-------------------------------------------------------------------------------
whiteSpace = T.whiteSpace lexer
nat = T.natural lexer
-------------------------------------------------------------------------------
data Cluster = Cluster {isLD   :: Bool
                       ,metric :: String
                       ,alg    :: [String]
                       } deriving (Show)
-------------------------------------------------------------------------------
p_wl = do 
  C.string "hd"
  return False
  <|> do 
  C.string "ld"
  return True
  <?> "workload: hd, ld"
-------------------------------------------------------------------------------
p_alg = do
  C.string "em"
  C.space
  k <- nat
  return $ em $ fromIntegral k
  <|> do
  C.string "k-means"
  C.space
  k <- nat
  return $ kmeans $ fromIntegral k
  <?> "clustering algorithm: em, k-means"
-------------------------------------------------------------------------------
p_metric = do 
  s <- C.string "Loads" <|> C.string "KW"  
  return s
  <|> do
  c <- C.char 'C'
  s <- C.string "H_WTD" <|> C.string "_WTD" <|> C.string "OP"
  return $ c:s
  <?> "chiller metric: Loads, KW, CH_WTD, C_WTD, COP"
-------------------------------------------------------------------------------
p_form = do
  wl <- p_wl
  C.space
  metric <- p_metric
  C.space
  alg <- p_alg
  return $ Cluster wl metric alg
-------------------------------------------------------------------------------
p_top = do 
  whiteSpace
  f <- p_form 
  eof
  return f
-------------------------------------------------------------------------------
reader str = case (parse p_top "" str) of
              Left err -> error $ show err
              Right x  -> x
-------------------------------------------------------------------------------
class Metric a where
  workflow :: a -> IO ()
-------------------------------------------------------------------------------
instance Metric Cluster where   
  workflow (Cluster isLD metric alg) = do
    let trials = ["t01","t02","t03"]
        modes = [WriteMode,AppendMode,AppendMode]
        tss = if isLD then [[(0+k,3)] | k<-[0,3,6]]
              else [[(0+k,2)] | k<-[0,2,4]]
        dir = if isLD then "/cluster/ld/"++metric 
              else "/cluster/hd/"++metric
    forM_ (zip3 trials modes tss) $ \(trial,mode,ts) -> do
      if metric=="COP" then elkify isLD True extract_NaN "COP" trial mode ts
      else elkify isLD True (extract_thresh 0) metric trial mode ts
    elki_cli dir alg
    return ()
