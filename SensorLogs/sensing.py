#!/usr/bin/env python3
__author__ = 'Pablo'
import socket
import signal
import sys
#from struct import *
import struct
import binascii
import math
import numpy as np
from scipy import stats
from pykalman import KalmanFilter


#PORT0 = 50003
PORT1 = 50003
#PORT2 = 50005


print('Server Running at ', socket.gethostbyname(socket.gethostname()))
#Data from sensor 0
#sock0 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#sock0.bind(('', PORT0))

#Data from sensor 1
sock1 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock1.bind(('', PORT1))

#Data from sensor 2
#sock2 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#sock2.bind(('', PORT2))

s=struct.Struct('15s 64f f 4H q')
while True:
    #print("waiting for UDP data packet...")

    #Receiving data from sockets
    #data0, address0 = sock0.recvfrom(296)
    data1, address1 = sock1.recvfrom(296)
    #data2, address2 = sock2.recvfrom(296)

    #Unpacking data from sockets
    #uData0=s.unpack(data0)
    uData1=s.unpack(data1)
    #uData2=s.unpack(data2)
    #print(uData1)
    #print(uData2)

    #Linearized 16x4 readings (A0,B0,C0,D0, A1,B1,C1,D1 ... )
    #dataArray0=np.asarray(uData0[1:65])
    dataArray1=np.asarray(uData1[1:65])
    #dataArray2=np.asarray(uData2[1:65])

    #Ambient Temperature
    #temp0=np.asarray(uData0[66])
    #temp1=np.asarray(uData1[66])
    #temp2=np.asarray(uData2[66])

    #Timestamp Data
    #time0=np.asarray(uData0[72])
    #time1=np.asarray(uData1[72])
    #time2=np.asarray(uData2[72])

    #Reconstructing the 16x4 Matrix (transposed)
    dataMat=np.reshape(dataArray1,(16,4))#,dataArray1,dataArray2],(48,4))
    #print(dataMat)

    #Statistics per column (row in this case as it is transposed)
    dataRow=dataMat.sum(axis=1)/4
    #print(dataRow)
    dataRowSq=dataRow**2
    dataAverage=dataMat.sum()/dataMat.size

    #Select a threshold as a percentace above the RMS value
    dataRms=np.sqrt(dataRowSq.sum()/dataRow.size)
    threshold=dataRms*1.07
    #print(threshold)

    #Binarizing the signal (0=no reading, 1=person detected)
    defaultVals=stats.threshold(dataRow,threshmin=threshold,newval=0)
    defaultVals=stats.threshold(defaultVals,threshmax=threshold,newval=1)

    #False positive filtering


    span=3.2
    np.set_printoptions(precision=4)
    print(defaultVals)
    values=np.dot([i for i,x in enumerate(defaultVals) if x == 1],span/15)
    if values.size:
        measurements=np.mean(values)
        #print(measurements-span/2)


        #kf = KalmanFilter(initial_state_mean=0, n_dim_obs=1)
        #kf = kf.em(measurements, n_iter=5)
        #(filtered_state_means, filtered_state_covariances) = kf.filter(measurements)
        #(smoothed_state_means, smoothed_state_covariances) = kf.smooth(measurements)

        #print(filtered_state_means.T)
