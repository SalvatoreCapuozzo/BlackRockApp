# -*- coding: utf-8 -*-
"""
Created on Tue May 26 20:50:09 2020

@author: UC
"""


import pandas as pd
import numpy as np
import matplotlib.pylab as plt
#%matplotlib inline

def getCoords(df_Selected,city):
    df_Selected = df_Selected[df_Selected.City == city]
    coords = [df_Selected.head(1).Latitude, df_Selected.head(1).Longitude]
    return coords

def timeSeriesAnalysis(df_Selected,city,index,printPlot,lastData,pred_num):
    df_Selected = df_Selected[df_Selected.City == city]
    #coords = [df_Selected.head(1).Latitude, df_Selected.head(1).Longitude]
    df_Selected = df_Selected.drop('Country',axis=1)
    df_Selected.index = pd.to_datetime(df_Selected.dt)
    df_Selected = df_Selected.drop('dt', axis=1)
    df_Selected = df_Selected.loc['1970-01-01':]
    df_Selected = df_Selected.sort_index()
    df_Selected.AverageTemperature.fillna(method='pad', inplace=True)
    df_Selected['Ticks'] = range(0,len(df_Selected.index.values))
    
    from statsmodels.tsa.stattools import adfuller
    def stationarity_check(ts):
        
        # Determing rolling statistics
        roll_mean = ts.rolling(12).mean()
        #roll_mean = pd.rolling_mean(ts, window=12)
        # Plot rolling statistics:
        if printPlot:
            plt.figure(index)
            plt.plot(ts, color='green',label='Original')
            plt.plot(roll_mean, color='blue', label='Rolling Mean')
            plt.legend(loc='best')
            plt.title('Rolling Mean')
            plt.show(block=False)
        
        # Perform Augmented Dickey-Fuller test:
        print('Augmented Dickey-Fuller test:')
        df_test = adfuller(ts)
        print("type of df_test: ",type(df_test))
        print("df_test: ",df_test)
        df_output = pd.Series(df_test[0:4], index=['Test Statistic','p-value','#Lags Used','Number of Observations Used'])
        print("df_output: \n",df_output)
        for key,value in df_test[4].items():
            df_output['Critical Value (%s)'%key] = value
        print(df_output)
        
    stationarity_check(df_Selected.AverageTemperature)
    df_Selected['Roll_Mean'] = df_Selected.AverageTemperature.rolling(12).mean()
    df_Selected = df_Selected.iloc[11:]
    
    from statsmodels.graphics.tsaplots import plot_pacf,plot_acf
    from statsmodels.tsa.arima_model import ARMA
    import itertools
    p = q = range(0, 4)
    pq = itertools.product(p, q)
    for param in pq:
        try:
            mod = ARMA(df_Selected.AverageTemperature,order=param)
            results = mod.fit()
            print('ARMA{} - AIC:{}'.format(param, results.aic))
        except:
            continue
    
    model = ARMA(df_Selected.AverageTemperature, order=(2,3))  
    results_MA = model.fit() 
    if printPlot:
        plt.plot(df_Selected.AverageTemperature)
        plt.plot(results_MA.fittedvalues, color='red')
        plt.title('Fitting data ' + city + ' _ MSE: %.2f'% (((results_MA.fittedvalues-df_Selected.AverageTemperature)**2).mean()))
        plt.show()
    
    predictions = results_MA.predict('12/01/1970', lastData)
    #predictions = results_MA.predict('06/01/2021', '06/01/2023')
    print(predictions.tail(pred_num))
    return predictions.tail(pred_num)



df = pd.read_csv('GlobalLandTemperaturesByCity.CSV', delimiter=',')
df_Selected = df.drop('AverageTemperatureUncertainty', axis=1)
df_State = df_Selected[df_Selected.Country == "Italy"]
df_cities = df_State.City.unique()
print("Cities: "+str(len(df_cities)))
print(df_cities)
i = 0
lastData = '12/01/2021'
city = "Milan"
coords = getCoords(df_Selected,city)
val = timeSeriesAnalysis(df_Selected,city,i,False,lastData,12)
print(city+": "+str(coords))

# for city in df_cities:
#     val = timeSeriesAnalysis(df_Selected,city,i,False,lastData,1)
#     print(city + ": "+str(val[0]) + " " + str(val[1]))
#     i += 1

# df_Selected.index = pd.to_datetime(df_Selected.dt)
# df_Selected = df_Selected.drop('dt', axis=1)
# df_Selected = df_Selected.loc['1990-01-01':]  
# df_Selected.to_csv('90toNow.csv', index=True)
