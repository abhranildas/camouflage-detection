function x_fil=filter(x,fil)
    x_f=fft(x); %FFT
    x_f_fil=x_f.*fil;
    x_fil=ifft(x_f_fil); %IFFT
end