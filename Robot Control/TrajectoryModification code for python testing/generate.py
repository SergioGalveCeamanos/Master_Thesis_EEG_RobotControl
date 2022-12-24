# given a certain function we will store it as a set of points in a Trajectory object

from mpl_toolkits import mplot3d

import numpy as np
import matplotlib.pyplot as plt

class Sigmoid:
    # defining m and n is tricky since it leads to problems when sorting out the logarithms
    def __init__(self,p1,p2,m=1.0,n=0.0):  #p1=[time ,  distance/angle]
        self.p1 = p1
        self.p2 = p2
        self.m = m
        self.n = n
        self.k, self.t0 = 1, 1  # k also invert the s shape by being negative
        self.adjust()
        self.points = np.array([1, 2, 3, 4])

    def adjust(self):  # we obtain k and t0, that define the function shape acording s
        log1 = np.log(self.m / (self.p1[1] - self.n) - 1)
        log2 = np.log(self.m / (self.p2[1] - self.n) - 1)
        self.k = (log1-log2)/(self.p2[0]-self.p1[0])
        self.t0 = np.log(self.m/(self.p1[1]-self.n)-1)/self.k + self.p1[0]

    def get_points(self,n):  # we obtain n points between p1 and p2, both included
        set = []
        set.append(self.p1[1])
        tau = (self.p2[0]-self.p1[0])/(n-1)
        for i in range(1,(n-1)):
            t = self.p1[0]+tau*i
            set.append((self.n + self.m/(1+np.exp(-self.k*(t-self.t0)))))
        set.append(self.p2[1])
        self.points = np.array(set)
        return self.points

    def get_plot(self,tau,type='b-'):
        timex = np.linspace(0.0, self.points.size*tau, self.points.size)
        plt.plot(timex, self.points, type)
        plt.xlabel('time')
        plt.ylabel('distance')
        plt.show()

    def save_points(self, name):
        np.save(name, self.points)


class SecOrder:
    def __init__(self,p1,p2,conv=True):
        self.p1 = p1
        self.p2 = p2
        self.convex = conv
        if conv:
            self.a = -0.25
        else:
            self.a = 0.25
        self.b = 1.0
        self.c = 1.0
        self.adjust()
        self.points = np.array([1, 2, 3, 4])


    def adjust(self):  # we obtain k and t0, that define the function shape according
        self.b = ((self.p2[1]-self.p1[1])-(self.a*(self.p2[0]**2 - self.p1[0]**2)))/(self.p2[0] - self.p1[0])
        self.c = self.p1[1]-self.a*self.p1[0]**2.0-self.b*self.p1[0]

    def get_points(self, n):  # we obtain n points between p1 and p2, both included... we only send dimension
        set = []
        set.append(self.p1[1])
        tau = (self.p2[0]-self.p1[0])/(n-1)
        for i in range(1,(n-1)):
            t = self.p1[0]+tau*i
            set.append((self.a*t**2+self.b*t+self.c))
        set.append(self.p2[1])
        self.points = np.array(set)
        return self.points

    def get_plot(self,tau,type='b-'):
        timex = np.linspace(0.0, self.points.size*tau, self.points.size)
        plt.plot(timex, self.points, type)
        plt.xlabel('time')
        plt.ylabel('distance')
        plt.show()

    def save_points(self, name):
        np.save(name, self.points)

class FirstOrder:
    def __init__(self,p1,p2):
        self.p1 = p1
        self.p2 = p2
        self.m = 1.0
        self.n = 1.0
        self.adjust()
        self.points = np.array([1, 2, 3, 4])


    def adjust(self):  # we obtain k and t0, that define the function shape according
        self.m = (self.p1[1]-self.p2[1])/(self.p1[0]-self.p2[0])
        self.n = self.p1[1]-self.m*self.p1[0]

    def get_points(self, n):  # we obtain n points between p1 and p2, both included... we only send dimension
        set = []
        set.append(self.p1[1])
        tau = (self.p2[0]-self.p1[0])/(n-1)
        for i in range(1,(n-1)):
            t = self.p1[0]+tau*i
            set.append((self.m*t+self.n))
        set.append(self.p2[1])
        self.points = np.array(set)
        return self.points

    def get_plot(self,tau,type='b-'):
        timex = np.linspace(0.0, self.points.size*tau, self.points.size)
        plt.plot(timex, self.points, type)
        plt.xlabel('time')
        plt.ylabel('distance')
        plt.show()

    def save_points(self, name):
        np.save(name, self.points)

if __name__ == "__main__":
    #we must define n dimensions in k different parts
    dir = '/home/student/baxter_ws/Trajectories/Test2/part'

    # p1so = [0, 0.0]
    # p2so = [1, 1.5]
    # convex = True
    # lift = SecOrder(p1so, p2so, convex)
    # name1 = dir + '1_1.npy'
    #
    # p1sg = p2so
    # p2sg = [4, 3.5]
    # m = 3.5
    # n = 0.4
    # approach = Sigmoid(p1sg, p2sg, m, n)
    # name2 = dir + '2_1.npy'
    #
    # lift.get_points(100)
    # approach.get_points(100)
    #
    # lift.get_plot(0.1)
    # approach.get_plot(0.1)
    #
    # lift.save_points(name1)
    # approach.save_points(name2)

    # We will include now the points for a demo suitable for baxter
    # http://sdk.rethinkrobotics.com/wiki/Workspace_Guidelines

    # PART 1 --> Time = 1 sec
    p1x1 = [0.0,0.656982770038]
    p1y1 = [0.0,-0.852598021641]
    p1z1 = [0.0,0.0388609422173]
    p1r1 = [0.0,2.711]
    p1p1 = [0.0,0.394]
    p1ya1 = [0.0,-2.269]

    p1x2 = [1.0,0.85]
    p1y2 = [1.0,-0.852598021641]
    p1z2 = [1.0,0.0388609422173]
    p1r2 = [1.0,2.711]
    p1p2 = [1.0,0.394]
    p1ya2 = [1.0,-2.269]

    p1x = SecOrder(p1x1, p1x2, True)
    p1y = FirstOrder(p1y1, p1y2)
    p1z = FirstOrder(p1z1, p1z2)
    p1r = FirstOrder(p1r1,p1r2)
    p1p = FirstOrder(p1p1,p1p2)
    p1ya = FirstOrder(p1ya1,p1ya2)

    x1 = p1x.get_points(50)
    p1x.save_points((dir+'1_1.npy'))
    y1 = p1y.get_points(50)
    p1y.save_points((dir+'1_2.npy'))
    z1 = p1z.get_points(50)
    p1z.save_points((dir+'1_3.npy'))
    p1r.get_points(50)
    p1r.save_points((dir+'1_4.npy'))
    p1p.get_points(50)
    p1p.save_points((dir+'1_5.npy'))
    p1ya.get_points(50)
    p1ya.save_points((dir+'1_6.npy'))

    # PART 2 --> Time = 1 sec

    p2x2 = [2.0,1.25]
    p2y2 = [2.0,1.0]
    p2z2 = [2.0,1.0]
    p2r2 = [2.0,np.pi/18]
    p2p2 = [2.0,-np.pi/8]
    p2ya2 = [2.0,-np.pi/6]

    p2x = SecOrder(p1x2,p2x2, False)
    p2y = SecOrder(p1y2,p2y2, False)
    p2z = SecOrder(p1z2,p2z2, False)
    p2r = FirstOrder(p1r2,p2r2)
    p2p = FirstOrder(p1p2,p2p2)
    p2ya = FirstOrder(p1ya2,p2ya2)

    x2 = p2x.get_points(50)
    p2x.save_points((dir+'2_1.npy'))
    y2 = p2y.get_points(50)
    p2y.save_points((dir+'2_2.npy'))
    z2 = p2z.get_points(50)
    p2z.save_points((dir+'2_3.npy'))
    p2r.get_points(50)
    p2r.save_points((dir+'2_4.npy'))
    p2p.get_points(50)
    p2p.save_points((dir+'2_5.npy'))
    p2ya.get_points(50)
    p2ya.save_points((dir+'2_6.npy'))

    # 3D visualization
    fig = plt.figure()
    ax = plt.axes(projection='3d')
    ax.plot3D(x1, y1, z1, 'green')
    ax.plot3D(x2, y2, z2, 'red')
    plt.show()