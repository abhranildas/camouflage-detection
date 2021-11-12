energies_accuracies=struct;
i=1;
for type={'cos','mag','grad_by_lum','grad_by_norm','grad_by_sd','perp_ratio'}
    for kernel_sd=1:10
        [dPrime_av,dPrime_hf,dPrime_pc, opt_acc, opt_crit]=analysis.compute_dPrime_pCorrect([seed_energy.(['notarget_', char(type), '_', num2str(kernel_sd)])],[seed_energy.(['target_', char(type), '_', num2str(kernel_sd)])],500,1);
        %[~,opt_acc]=analysis.optimal_discrim([seed_energy.(['notarget_', char(type), '_', num2str(kernel_sd)])],[seed_energy.(['target_', char(type), '_', num2str(kernel_sd)])],500,1);
        %dPrime=analysis.compute_dPrime([seed_energy.(['notarget_', char(type), '_', num2str(kernel_sd)])],[seed_energy.(['target_', char(type), '_', num2str(kernel_sd)])]);
        energies_accuracies(i).type=[char(type), '_', num2str(kernel_sd)];
        energies_accuracies(i).opt_acc=opt_acc;
        energies_accuracies(i).dPrime_av=dPrime_av;
        energies_accuracies(i).dPrime_hf=dPrime_hf;
        energies_accuracies(i).dPrime_pc=dPrime_pc;
        i=i+1;
    end
end