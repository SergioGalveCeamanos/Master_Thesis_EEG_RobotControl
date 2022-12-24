function [lab] = video_label(t,freq,w_size,id)
	intro = 12; %seconds
    t = (t-1)*w_size/freq-intro;
    lab=-1;
    if t>0
        r = rem(t,10);
        if r<3
            lab = 0;
        elseif r>5 && r<8
            round = floor(t/10)+1;
            if id == 1
                % L / R / R / L / R / L / L / L / R / R / L / R
                if round==1 || round==4 || round==6 || round==7 || round==8 || round==11
                    lab = 3;
                elseif round==2 || round==3 || round==5 || round==9 || round==10 || round==12
                    lab = 4;
                end
            elseif id == 2
            end
        end
    end
end

