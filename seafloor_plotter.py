# -*- coding: utf-8 -*-
"""
Created on Thu Jan 13 07:17:55 2022

@author: Natalya Evans

Purpose: plot the seafloor characteristics off Oregon
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

bathy = sio.loadmat('OC2107A_ETOP01.mat')
bathyx=bathy['coast_x']
bathyy=bathy['coast_y']
bathyz=bathy['coastal_relief_3sec']
bathyx2=np.tile(bathyx,[len(bathyy),1])
bathyy2=np.tile(bathyy,[1,7200])

sf = pd.read_csv('US9_EXT_OR.csv')


#%% Process data to plot
sf = sf[['Latitude','Longitude','WaterDepth', 'Gravel', 'Sand','Mud','Clay','Grainsze']].copy()
# cut out of range values
sf = sf[sf.Mud >= 0]
sf = sf[sf.WaterDepth < 500]
sf = sf[sf.Longitude < -123.5]
sf = sf[sf.Latitude < 47]
sf = sf[sf.Latitude > 42]

indexes = sf[(sf['Latitude']>=46.) & (sf['Longitude']<-124.8)].index
sf.drop(indexes,inplace=True)

#%% Plot the map with the OC2107A data for Fe(II)

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
s=plt.scatter(sf['Longitude'],sf['Latitude'],c=sf['Mud'])

cbar = plt.colorbar()
cbar.ax.set_ylabel('Mud content (%)',fontsize=11,)

plt.xlabel('Longitude/°E', labelpad=20, fontsize=11)
# plt.ylabel('Latitude/°N', labelpad=35, fontsize=11)
plt.savefig('seafloor_mud_map.tif', dpi=900, format=None)

