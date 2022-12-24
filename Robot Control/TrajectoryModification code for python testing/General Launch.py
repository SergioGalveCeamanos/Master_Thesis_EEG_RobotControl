# we will test how each method works  under the same circumstances

from DMP_mod import principal_DMP
from Force_mod import principal_force
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def rand_eeg(length):
    list=np.random.randn(length)*1.5-0.4
    eeg=[]
    eeg.append(list[0])
    for i in range(1,length):
        eeg.append(list[i]+eeg[i-1])

    return eeg


if __name__ == "__main__":
    inp_eeg = rand_eeg(100)
    path1, time_eeg1, time_milestones1, input1, n1, count1, path0 = principal_DMP(eeg=inp_eeg)
    path2, time_eeg2, time_milestones2, input2, n2, count2 =principal_force(eeg=inp_eeg)

    plt.figure(3)
    plt.subplot(211)
    plt.plot(time_eeg2, input2[:n2], 'bv', time_eeg2, input2[:n2], 'k',label="EEG accumulated value")
    plt.title('EEG processed signal')

    plt.subplot(212)
    plt.plot(time_milestones2, path2, 'g--', time_milestones1,path0[:(count1+1)],'k-',label="Trajectories") #time_milestones1, path1,  'r--',

    red_patch = mpatches.Patch(color='red', label='DMP Modification')
    green_patch = mpatches.Patch(color='green', label='Virtual Force Modification')
    black_patch = mpatches.Patch(color='black', label='Original Trajectory')
    plt.legend(handles=[green_patch,black_patch]) #red_patch,
    plt.title('Trajectories')

    plt.show()