%% check images from texture list

bg_size=256;
lum=0.5;
cont=0.15;
target_radius=64;

for i_tex=1:length(texture_list)
    i_tex
    texture=texture_list(i_tex);
    stim=lib.stimulus('texture',texture,'ml_b',0.5,'cont_b',0.15,'ml_t',0.5,'cont_t',0.15,'target_radius',target_radius);
    figure;
    imshow(stim,[]);
    title(sprintf('%s %.2f, %.2f',texture.img,1-errs_subj(i_tex),1-errs_model(i_tex)),'Interpreter','none')
end