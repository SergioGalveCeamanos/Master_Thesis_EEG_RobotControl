function [labels] = script_event(file)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
I_txt=fileread(file);
n=size(I_txt);
i=0;
labels = [];
pos = 1;

while i<(n(2)-1)
    i=i+1;
    ch=I_txt(i);
    o=i;
    if ch=='T'
        i=i+1;
        lab = I_txt(i);
        while (i<(n(2)-1)) && (ch~=':')
            i=i+1;
            ch = I_txt(i);
        end
        i = i+2;
        num = str2double(I_txt(i:(i+2)));
        i = i+2;
        npos = pos + num*160-1;
        mark = zeros(1,num*160)+str2num(lab);
        labels(pos:npos)=mark;
    end
end

labels=labels(160:end-160);
end

