

# Since this must work as a GP, the ROS functionalities will be added
from Trajectory import Trajectory
import numpy as np
import matplotlib.pyplot as plt
import copy

def load_Tr(parts,dir,dim):
    T=[]
    temp=[]
    for i in range(parts): # the index starts in 0
        for j in range(dim):
            temp.append(Trajectory(loc=(dir+str(i+1)+'_'+str(j+1)+'.npy')))
            temp[j].load_tr()

        T.append(temp) # T will be used like T[i][j]
        temp=[]      # we will store in a list a set of list... for each part we have N dimensions
    return T

def init_arr(Tr,dim,parts):

    NT=[]
    st=np.array([])
    # for each part
    for i in range(parts):
        for j in range(dim):
            if j==0:
                st=Tr[i][j].p
            else:
                st=np.vstack((st, Tr[i][j].p))

        NT.append(st)

    return NT

def rand_eeg(length):
    list=np.random.randn(length)
    eeg=[]
    eeg.append(list[0])
    for i in range(1,length):
        eeg.append(list[i]+eeg[i-1])

    return eeg

# Main
if __name__ == "__main__":
    # execute only if run as a script

    # We set up the path where the trajectories are stored and how many parts there are
    dir = '/home/student/mico/Trajectories/part'  # we might end up having different folders for each type of task
    parts = 2
    dim = 1
    length = 100
    reduction = 0.050  # over the normal distribution

    # Load and initialize
    Tr = load_Tr(parts,dir,dim)
    Mod_Tr = init_arr(Tr,dim,parts)
    original_tr = copy.deepcopy(Mod_Tr)
    input = [i*reduction for i in rand_eeg(length)]

    # SIMULATED loop, assuming we spend 1 sec per new EEG update and points are 0.2 sec from each other
    i = 1
    part_size = []
    state = 0  # in which part are we
    if dim>1:
        path = Mod_Tr[state][:, 0]
        pos = Mod_Tr[state][:, 0]
        orig = original_tr[state][:, 0]
        for i in range(parts):
            part_size.append(Mod_Tr[i].shape[1])
    else:
        path = Mod_Tr[state][0]
        pos = Mod_Tr[state][0]
        orig = original_tr[state][0]
        for i in range(parts):
            part_size.append(Mod_Tr[i].shape[0])


    i = 1
    n = -1
    count = 0
    type_force = 'Lorentz'
    rep = np.array([-0.2])
    while (state < parts) and (n < length):
        n += 1
        for k in range(5):  # how to manage time in ROS ?
            if state<parts:
                if dim > 1:
                    pos = Mod_Tr[state][:,i]
                    orig = original_tr[state][:,i]
                    path = np.hstack((path, modify(dim,input[n],rep,pos,orig,False,type_force)))

                else:
                    pos = Mod_Tr[state][i]
                    orig = original_tr[state][i]
                    path = np.hstack((path, modify(dim,input[n],rep,pos,orig,False,type_force)))
                i += 1
                count += 1
                if i == part_size[state]:
                    i = 0
                    state += 1


    # Now we can plot the executed path, the original path and the inputs received
       # https: // matplotlib.org / users / pyplot_tutorial.html
    time_milestones = np.linspace(0,count*0.2,count+1)
    time_eeg = np.linspace(0,n,n)

    plt.figure(1)
    plt.subplot(211)
    plt.plot(time_eeg, input[:n], 'bv', time_eeg, input[:n], 'k')
    plt.title('')

    path0 = np.append(original_tr[0],original_tr[1])
    plt.subplot(212)
    plt.plot(time_milestones, path, 'r--',time_milestones,path0[:(count+1)],'k-')
    plt.title('')

    plt.show()

    stop = 1