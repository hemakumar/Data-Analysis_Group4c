import os,sys

os.system('java -cp ' + sys.argv[1] + ' de.lmu.ifi.dbs.elki.application.KDDCLIApplication -dbc.in ' + sys.argv[2] + ' -algorithm clustering.KMeans -kmeans.k ' + sys.argv[3] + ' -resulthandler de.lmu.ifi.dbs.elki.visualization.gui.ResultVisualizer')
