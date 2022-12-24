%%% Signal Visualization
%% Global Variables
c3=9;
cz=11;
c4=13;
w_opt = 2;
w_size= 160*[0.30 0.15];
subjects = 20;
tests = 9;

notch = 50;
band = [3 80];
freq = 160;

file = 'C:\users\sergi\Desktop\TFM\EEG_testing\Database_samples\S0';
file2 = 'C:\users\sergi\Desktop\TFM\EEG_testing\Database_events\S0';
eeg = {};
eeg_label = {};

%% Reading the data
% we will store the data in time tables inside a cell for the same
% experiment, inside a cell with the other cell/experiments
[A,B,C,D] = butter(10,[3 78]/(freq*0.5));
band_f = designfilt('bandpassiir','FilterOrder',20, ...
    'HalfPowerFrequency1',3,'HalfPowerFrequency2',78, ...
    'SampleRate',freq);
sos = ss2sos(A,B,C,D);
Hd =  dfilt.statespace(A,B,C,D);
% fvt = fvtool(sos,band_f,'Fs',1500);
% legend(fvt,'butter','designfilt')

notch_f = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',freq);


for i=1:subjects
    for j=1:tests
        if i<10
            name=strcat(file,int2str(0),int2str(i),'R',int2str(0),int2str(j),'.edf');
            name2=strcat(file2,int2str(0),int2str(i),'R',int2str(0),int2str(j),'.edf.event.txt');
        else
            name=strcat(file,int2str(i),'R',int2str(0),int2str(j),'.edf');
            name2=strcat(file2,int2str(i),'R',int2str(0),int2str(j),'.edf.event.txt');
        end

        [hdr,data]=edfread(name);
        data= data([c3 cz c4],160:end-160)';
        filtered = filter(Hd,data);
        filtered_2 = filtfilt(notch_f,filtered);
        eeg{j}{i} = filtered_2;
        eeg_label{j}{i} = script_event(name2);
    end
end
% t = (0:length(data(:,1))-1)/freq;
% plot(t,data(:,1),t,filtered_2)
% ylabel('Voltage (uV)')
% xlabel('Time (s)')
% title('EEG for imaginary motion')
% legend('Unfiltered','Notch Filtered')
% grid

%% Splitting the data --> Feature extraction
% We want to group the data in small windss that we can relate to the
% phisiology of the mental responso inside the experiment
f1 = freq*(0:(w_size(1)/2))/w_size(1);
f2 = freq*(0:(w_size(2)/2))/w_size(2);
database_1 = {{{}}};
database_2 = {{{}}};
database_1t = {{{}}};
database_2t = {{{}}};
label_1 = {{{}}};
label_2 = {{{}}};
for j=1:tests
    for i=1:subjects
        n_1 = 1;
        n_2 = 1;
        block = eeg{j}{i};
        lab = eeg_label{j}{i};
        for n=1:floor(length(block(:,1))/w_size(1))
            piece=block(((n-1)*w_size(1)+1):((n)*w_size(1)+1),:);
            Y=fft(piece);
            P2 = abs(Y/w_size(1));
            P1 = P2(1:w_size(1)/2+1,:);
            P1(2:end-1,:) = 2*P1(2:end-1,:);
            database_1{j}{i}{n_1}=P1;
            database_1t{j}{i}{n_1}=piece;
%                 database_1{j}{i}{n_1}=normalize(P1,1);
%                 database_1t{j}{i}{n_1}=normalize(piece,1);
            if(isnan(lab))
                label_1{j}{i}{n_1}=0;
            else
                label_1{j}{i}{n_1}=mode(lab);
            end
            n_1 = n_1 + 1;
        end

        for n=1:floor(length(block(:,1))/w_size(2))
            piece=block(((n-1)*w_size(2)+1):((n)*w_size(2)+1),:);
            Y=fft(piece);
            P2 = abs(Y/w_size(2));
            P1 = P2(1:w_size(2)/2+1,:);
            P1(2:end-1,:) = 2*P1(2:end-1,:);
            database_2{j}{i}{n_2}=P1;
            database_2t{j}{i}{n_2}=piece;
            if(isnan(lab))
                label_2{j}{i}{n_2}=0;
            else
                label_2{j}{i}{n_2}=mode(lab);
            end
            n_2 = n_2 + 1;
        end
    end
end

% database structure: [Test Subject windss] 
save('C:\users\sergi\Desktop\TFM\EEG_testing\Databases_aug1.mat','database_1','database_1t','database_2','label_1','label_2')
% plot(f2,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
%% Visualization
vis = 0;
data = database_1;
%userss in rows -->
users = [5 10 15 20];
%windss in columns ^|
winds = [25 20 30 40];
experiments = [1];

if vis==0
    for i=1:length(experiments)
        f = figure
%         p = uipanel('Parent',f,'BorderType','none'); 
%         name = strcat('Experiment #',int2str(experiments(i)));
%         p.Title = name; 
%         p.TitlePosition = 'centertop'; 
%         p.FontSize = 12;
%         p.FontWeight = 'bold';
%         xlabel('f (Hz)')
%         ylabel('|P1(f)|')
        %1st users
        ax1 = subplot(4,4,1);
        plot(f1,data{experiments(i)}{users(1)}{winds(1)}) 
        title(strcat('Subject #',int2str(users(1)),' | winds #',int2str(winds(1))));
        ax2 = subplot(4,4,2);
        plot(f1,data{experiments(i)}{users(1)}{winds(2)}) 
        title(strcat('Subject #',int2str(users(1)),' | winds #',int2str(winds(2))));
        ax3 = subplot(4,4,3);
        plot(f1,data{experiments(i)}{users(1)}{winds(3)}) 
        title(strcat('Subject #',int2str(users(1)),' | winds #',int2str(winds(3))));
        ax4 = subplot(4,4,4);
        plot(f1,data{experiments(i)}{users(1)}{winds(4)}) 
        title(strcat('Subject #',int2str(users(1)),' | winds #',int2str(winds(4))));
        %2nd users
        ax5 = subplot(4,4,5);
        plot(f1,data{experiments(i)}{users(2)}{winds(1)}) 
        title(strcat('Subject #',int2str(users(2)),' | winds #',int2str(winds(1))));
        ax6 = subplot(4,4,6);
        plot(f1,data{experiments(i)}{users(2)}{winds(2)}) 
        title(strcat('Subject #',int2str(users(2)),' | winds #',int2str(winds(2))));
        ax7 = subplot(4,4,7);
        plot(f1,data{experiments(i)}{users(2)}{winds(3)}) 
        title(strcat('Subject #',int2str(users(2)),' | winds #',int2str(winds(3))));
        ax8 = subplot(4,4,8);
        plot(f1,data{experiments(i)}{users(2)}{winds(4)}) 
        title(strcat('Subject #',int2str(users(2)),' | winds #',int2str(winds(4))));
        %3rd users
        ax9 = subplot(4,4,9);
        plot(f1,data{experiments(i)}{users(3)}{winds(1)}) 
        title(strcat('Subject #',int2str(users(3)),' | winds #',int2str(winds(1))));
        ax10 = subplot(4,4,10);
        plot(f1,data{experiments(i)}{users(3)}{winds(2)}) 
        title(strcat('Subject #',int2str(users(3)),' | winds #',int2str(winds(2))));
        ax11 = subplot(4,4,11);
        plot(f1,data{experiments(i)}{users(3)}{winds(3)}) 
        title(strcat('Subject #',int2str(users(3)),' | winds #',int2str(winds(3))));
        ax12 = subplot(4,4,12);
        plot(f1,data{experiments(i)}{users(3)}{winds(4)}) 
        title(strcat('Subject #',int2str(users(3)),' | winds #',int2str(winds(4))));

        %4th users
        ax13 = subplot(4,4,13);
        plot(f1,data{experiments(i)}{users(4)}{winds(1)}) 
        title(strcat('Subject #',int2str(users(4)),' | winds #',int2str(winds(1))));
        ax14 = subplot(4,4,14);
        plot(f1,data{experiments(i)}{users(4)}{winds(2)}) 
        title(strcat('Subject #',int2str(users(4)),' | winds #',int2str(winds(2))));
        ax15 = subplot(4,4,15);
        plot(f1,data{experiments(i)}{users(4)}{winds(3)}) 
        title(strcat('Subject #',int2str(users(4)),' | winds #',int2str(winds(3))));
        ax16 = subplot(4,4,16);
        plot(f1,data{experiments(i)}{users(4)}{winds(4)}) 
        title(strcat('Subject #',int2str(users(4)),' | winds #',int2str(winds(4))));
    end
end
t=[]
for i = 1:49
    t(i)=i-1;
end

figure(2)
plot(f1,data{4}{users(1)}{winds(1)}) 
title(strcat('Subject #',int2str(users(1)),' | winds #',int2str(winds(1))));


