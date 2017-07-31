function im = imblur(im, envelope)
    
    im = lib.fftconv2(im, envelope);

end