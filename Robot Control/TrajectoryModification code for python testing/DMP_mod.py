# This code must load a set of trajectories and receive certain inputs (EEG) that modify it

# We use the original Trajectory, the dmp library and some standard python libs
    # Since this must work as a GP, the ROS functionalities will be added

from Trajectory import Trajectory
import numpy as np
import matplotlib.pyplot as plt
import pydmps
import pydmps.dmp_discrete
import copy

# Functions
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

def init_dmp(Tr,dim,parts,print=True):
    bfs = 1000
    D=[]
    NT=[]
    st=np.array([])
    # for each part
    for i in range(parts):
        for j in range(dim):
            if j==0:
                st=Tr[i][j].p
            else:
                st=np.vstack((st, Tr[i][j].p))

        dmp = pydmps.dmp_discrete.DMPs_discrete(n_dmps=dim, n_bfs=bfs)
        dmp.imitate_path(y_des=st, plot=False)
        NT.append(st)
        D.append(dmp)
        if print:
            vec,yd,ydd = dmp.rollout()
            times = np.linspace(0,len(vec),len(vec))
            plt.figure(i)
            plt.plot(times, vec, 'r<', times, vec, 'k')
            plt.title('without time steps')

    return D, NT

def rand_eeg(length):
    list=np.random.randn(length)
    eeg=[]
    eeg.append(list[0])
    for i in range(1,length):
        eeg.append(list[i]+eeg[i-1])

    return eeg

def modify(state,Dmps,input,parts,Mod_Tr,part_size,original,print=True):
    Dmps[state].goal = original[state].goal + input  # are we modifying the original ???
    Mod_Tr[state], yd, ydd = Dmps[state].rollout(part_size[state])
    if state < (parts-1):
        Dmps[state+1].y0 = original[state+1].y0 + input
        Mod_Tr[state+1], yd, ydd = Dmps[state+1].rollout(part_size[state+1])
    if print:
        vec, yd, ydd = Dmps[state].rollout()
        times = np.linspace(0, len(vec), len(vec))
        plt.figure(1)
        plt.plot(times, vec, 'g>', times, vec, 'k')
        plt.title('without TS -- Goal changed')
        plt.show()
    return Dmps, Mod_Tr

# Main
def principal_DMP(dir='/home/student/mico/Trajectories/part',parts=2,dim=1, eeg=[]):
    # execute only if run as a script

    # We set up the path where the trajectories are stored and how many parts there are

    length = 100
    reduction = 0.10  # over the normal distribution

    # Load and initialize
    Tr = load_Tr(parts,dir,dim)
    Dmps, Mod_Tr = init_dmp(Tr,dim,parts,False)
    original_tr = copy.deepcopy(Mod_Tr)
    original_dmp = copy.deepcopy(Dmps)
    if not eeg:
        input = [i*reduction for i in rand_eeg(length)]
    else:
        input = [i * reduction for i in eeg]

    # SIMULATED loop, assuming we spend 1 sec per new EEG update and points are 0.2 sec from each other
    i = 1
    part_size = []
    state = 0  # in which part are we
    if dim>1:
        path = Mod_Tr[state][:, 0]
        for i in range(parts):
            part_size.append(Mod_Tr[i].shape[1])
    else:
        path = Mod_Tr[state][0]
        for i in range(parts):
            part_size.append(Mod_Tr[i].shape[0])


    n = -1
    count = 0
    while (state < parts) and (n < length):
        n += 1
        Dmps, Mod_Tr = modify(state,Dmps,input[n],parts,Mod_Tr,part_size,original_dmp,False)
        for k in range(10):  # how to manage time in ROS ?
            if state<parts:
                if dim > 1:
                    path = np.hstack((path,Mod_Tr[state][:,i]))
                else:
                    path = np.hstack((path, Mod_Tr[state][i]))
                i += 1
                count += 1
                if i == part_size[state]:
                    i = 0
                    state += 1

    # Now we can plot the executed path, the original path and the inputs received
       # https: // matplotlib.org / users / pyplot_tutorial.html
    time_milestones = np.linspace(0,count*0.1,count+1)
    time_eeg = np.linspace(0,n,n)

    plt.figure(1)
    plt.subplot(211)
    plt.plot(time_eeg, input[:n], 'rv', time_eeg, input[:n], 'k')
    plt.title('')

    path0 = np.append(original_tr[0],original_tr[1])
    plt.subplot(212)
    plt.plot(time_milestones, path, 'r--',time_milestones,path0[:(count+1)],'k-')
    plt.title('')

    #plt.show()

    return path,time_eeg,time_milestones,input,n,count,path0