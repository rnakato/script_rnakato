import pandas as pd

def loadJuicerMatrix(filename):
    print(filename)
    data = pd.read_csv(filename, delimiter='\t', index_col=0)
    return data
