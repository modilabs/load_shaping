# load up libraries
import LEGP as legp
import pandas as p
import numpy as np
import scipy.io as spio
import datetime as dt
import matplotlib.pyplot as plt

# load in mat weather data
mat = spio.loadmat('resourceSolTim1.mat')
data = mat['KisanganiNTS']

# create dates from weather data using 'list comprehension'
dates = [dt.datetime(w[0], w[1], w[2], w[3]-1) for w in data]

# extract resource data from weather data
resource = [w[4] for w in data]

# load up demand data
mat2 = spio.loadmat('synthDem.mat')
demand = mat2['lightDemandYearSyn']

# call function
(batchar, LEG, LEGP) = legp.SuppDemSum(dates, 13.45, resource, demand, 2000, 10000, 5000)

# create nice plottable object
batchar = p.Series(index=dates, data=batchar)
batchar.plot()
plt.show()



