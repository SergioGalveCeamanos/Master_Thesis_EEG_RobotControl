function [fener] = fenergy(piece)
%we will obtain for each column the fourier transformation and we will
%compute as a feature the energy acumulated in each frequency (1 Hz wide)
wide = 1;
fener = fft(piece);

end

