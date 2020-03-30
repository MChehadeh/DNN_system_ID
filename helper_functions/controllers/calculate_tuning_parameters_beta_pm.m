function [ c1,c3,phase_co ] = calculate_tuning_parameters_beta_pm( beta,pm )
    total_phase=rad2deg(asin(beta));
    x=tan(deg2rad(total_phase-pm));
    c3=x/(-2*pi);
    c1=1/sqrt(1+4*pi*pi*c3*c3);
    phase_co=total_phase-180;
end