# We will set a custom trajectory class to write, read and visualize

import numpy as np
import matplotlib.pyplot as plt

class Trajectory:

    def __init__(self, points=np.array([1, 2, 3, 4]), time=0.2, loc='/home/student/Desktop/Tr.npy'):
        self.p = points
        self.tau = time
        self.o_dir = loc
        self.m_dir = loc
    # We can load and write files in .npy format
    def load_tr(self):
        self.p = np.load(self.o_dir)

    def save_tr(self):
        np.save(self.m_dir,self.p)

    # We can modify the main elements of the class
    def set_o_dir(self,name):
        self.o_dir=name

    def set_m_dir(self, name):
        self.m_dir=name

    def set_points(self,points):
        self.p = points

    # We use the plot to show this exact set of points ... under a time Tau
    def get_plot(self,type='b-'):
        timex = np.linspace(0.0, self.p.size*self.tau, self.p.size)
        plt.plot(timex, self.p, type)
        plt.xlabel('time')
        plt.ylabel('distance')
        plt.show()


