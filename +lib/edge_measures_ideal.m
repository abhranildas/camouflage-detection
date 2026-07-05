function [edge_power,edge_as,edge_ps,edge_phase_spec]=edge_measures_ideal(edge)
n_edge=length(edge);

edge_power=mean(edge.^2);

% edge amplitude and phase spectra:
edge_dft=fft(edge);
edge_dft=edge_dft(1:ceil((n_edge+1)/2)); % remove repeated part
edge_as=abs(edge_dft);
edge_ps=edge_as.^2/n_edge;
edge_ps(2:end-1)=2*edge_ps(2:end-1);
edge_phase_spec=angle(edge_dft);