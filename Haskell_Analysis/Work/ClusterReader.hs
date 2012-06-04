{- Michael Novak
 - mnovak@cecs.pdx.edu
 - 5-31-2012
 -}
-------------------------------------------------------------------------------
module Work.ClusterReader (Chiller(..),reader) where
-------------------------------------------------------------------------------
import Text.ParserCombinators.Parsec                               hiding (try)
import qualified Text.ParserCombinators.Parsec.Char                        as C
import qualified Text.ParserCombinators.Parsec.Token                       as T
import Text.ParserCombinators.Parsec.Language                        (emptyDef)
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
data Chiller = Chiller {notHD   :: Bool
                       ,metric :: String
                       ,alg    :: [String]
                       ,k      :: Int
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
  let k' = fromIntegral k
  return (k',em k')
  <|> do
  C.string "k-means"
  C.space
  k <- nat
  let k' = fromIntegral k
  return (k',kmeans k')
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
  (k,alg) <- p_alg
  return $ Chiller wl metric alg k
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
