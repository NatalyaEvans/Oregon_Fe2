# -*- coding: utf-8 -*-
"""
Created on Thu Jan 13 07:17:55 2022

@author: Natalya Evans

Purpose: plot a map of stations
"""
#%% Initialize packages


#%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pandas as pd
import scipy.io as sio

#%% set up map boundaries and graphical properties

def format_string(lonlat): #to remove the +/= and degree marks on ticks when drawing parallels and meridians
    if(lonlat>180):
       return "{num}".format(num=lonlat-360)
    return "{num}".format(num=lonlat)

Nedge=47
Sedge=43
Wedge=-126
Eedge=-123.5

longlineE=Eedge
longlineW=Wedge
longlinespacing=1

latlineN=Nedge
latlineS=43.5
latlinespacing=1

markers=["o","^","s","d","P","p","x","o"]
#colors = plt.rcParams['axes.prop_cycle'].by_key()['color'] # extracts the default color cycle
#colors[3], colors[4]=colors[4], colors[3]

#%% load in data to plot

df = pd.read_csv ('Processed Fe2 data.csv')
bathy = sio.loadmat('OC2107A_ETOP01.mat')
bathyx=bathy['coast_x']
bathyy=bathy['coast_y']
bathyz=bathy['coastal_relief_3sec']
bathyx2=np.tile(bathyx,[len(bathyy),1])
bathyy2=np.tile(bathyy,[1,7200])


#%% Process data to plot
df2 = df[['Cruise','Station','Cast type', 'Longitude', 'Latitude','Depth/m','Bottom depth/m','Fe(II)/nM','O2/umolkg-1']].copy()


#%% Plot the map with the OC2107A data for Fe(II)

plotdf=df2[df2['Cruise']=='OC2107A']

fig = plt.figure(figsize=(8, 8))
plt.rcParams["font.family"] = "sans"
m = Basemap(projection='cyl', resolution='i',
            llcrnrlat=Sedge, urcrnrlat=Nedge,
            llcrnrlon=Wedge, urcrnrlon=Eedge, )
#m.shadedrelief(scale=0.2, alpha=0.5)
plt.contourf(bathyx2,bathyy2,bathyz,levels=np.linspace(-4000,50,50),cmap='ocean',vmin=-6000,vmax=0)
m.drawcoastlines()
m.drawparallels(np.arange(latlineS,latlineN,latlinespacing),labels=[1,0,0,0], fontsize=11, labelstyle= "+/-", fmt=format_string)
m.drawmeridians(np.arange(longlineW,longlineE,longlinespacing),labels=[1,1,0,1], fontsize=11, labelstyle= "+/-", fmt=format_string)
s=plt.scatter(plotdf['Longitude'],plotdf['Latitude'],s=50,edgecolors='m',facecolor='m')
for i in range(len(plotdf['Station'])):
    if plotdf['Station'][i]=='31' or plotdf['Station'][i]=='32' or plotdf['Station'][i]=='34':
        plt.annotate(plotdf['Station'][i], (plotdf['Longitude'][i], plotdf['Latitude'][i]),textcoords="offset points",xytext=(0,-17),ha='center')
    elif plotdf['Station'][i]=='30' or plotdf['Station'][i]=='27':
        plt.annotate(plotdf['Station'][i], (plotdf['Longitude'][i], plotdf['Latitude'][i]),textcoords="offset points",xytext=(-10,7))
    else:        
        plt.annotate(plotdf['Station'][i], (plotdf['Longitude'][i], plotdf['Latitude'][i]),textcoords="offset points",xytext=(0,7),ha='center')
#plt.scatter(-124.306,44.6371,s=50, edgecolors='r',facecolor='r',marker='d')
#plt.annotate('OOI',(-124.306,44.6371),textcoords="offset points",xytext=(0,-17),ha='center')
#plt.annotate(plotdf['Station'],(plotdf['Longitude'],plotdf['Latitude']))
plt.xlabel('Longitude/°E', labelpad=20, fontsize=11)
plt.ylabel('Latitude/°N', labelpad=35, fontsize=11)
plt.savefig('OC2107A_map.tif', dpi=900, format=None)

