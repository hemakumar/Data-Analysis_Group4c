{- Michael Novak
 - mnovak@cecs.pdx.edu
 - 5-31-2012
 -}
-------------------------------------------------------------------------------
import System.IO
import System.Directory
import Control.Monad
-------------------------------------------------------------------------------
main = do
  let clusters = [3..11]
  forM_ [ld,hd] $ \f -> mapM_ (f clusters) ["KW","Loads","COP","CH_WTD","C_WTD"]
-------------------------------------------------------------------------------
hd clusters metric = do
  createDirectoryIfMissing True "htlatex"
  out <- openFile ("htlatex/hd_"++metric++".tex") WriteMode
  forM_ clusters $ \cst -> do
    hPutStrLn out "\\begin{figure}[!h]"
    hPutStrLn out $ "\\centerline{\\bfseries\\large High-Density Workload : Trials 1--3}\\\\"
    forM_ [1..3] $ \t -> do
      hPutStrLn out $ "\\fbox{\\includegraphics[bb=0 0 1152 720, width=15in]{cluster"++show cst++"/hd/"++metric++"/"++metric++"_t0"++show t++".png}}"
    let alg = if cst==3 then "EM" else "K-Means"
    hPutStrLn out $ "\\caption{Chiller units C1 and C4; "++alg++" clustering across all three trials with $k="++show cst++"$.}"
    hPutStrLn out $ "\\end{figure}"
  hClose out
-------------------------------------------------------------------------------
ld clusters metric = do
  createDirectoryIfMissing True "htlatex"
  out <- openFile ("htlatex/ld_"++metric++".tex") WriteMode
  forM_ clusters $ \cst -> do
    hPutStrLn out "\\begin{figure}[!h]"
    hPutStrLn out $ "\\centerline{\\bfseries\\large Low-Density Workload : Trials 1--3}\\\\"
    forM_ [1..3] $ \t -> do
      hPutStrLn out $ "\\fbox{\\includegraphics[bb=0 0 640 480, width=5in]{cluster"++show cst++"/ld/"++metric++"/"++metric++"_t0"++show t++".png}}"
    let alg = if cst==3 then "EM" else "K-Means"
    hPutStrLn out $ "\\caption{Chiller units C1, C2, and C4; "++alg++" clustering across all three trials with $k="++show cst++"$.}"
    hPutStrLn out $ "\\end{figure}"
  hClose out
