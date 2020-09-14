function [ready, control_timeseries, error_timeseries] = sample_MRFT(MRFT_mode, sample_time, u, error, target_timestep, N_samples)
%SAMPLE_MRFT Summary of this function goes here
%   Detailed explanation goes here
persistent Control_timeseries;
persistent Error_timeseries;
persistent N_processed_points;

if isempty(Control_timeseries)
    Control_timeseries = zeros(1, N_samples);
end
if isempty(Error_timeseries)
    Error_timeseries = zeros(1, N_samples);
end
if isempty(N_processed_points)
    N_processed_points = 0;
end


if (MRFT_mode)
    N_local_samples = round(sample_time / target_timestep);
    Control_timeseries(1:end-N_local_samples) = Control_timeseries(N_local_samples+1:end);
    Control_timeseries(end-N_local_samples+1:end) = u;
    error_local_timeseries = linspace(Error_timeseries(end), error, N_local_samples+1);
    Error_timeseries(1:end-N_local_samples) = Error_timeseries(N_local_samples+1:end);
    Error_timeseries(end-N_local_samples+1:end) = error_local_timeseries(2:end);
    if (N_processed_points < N_samples)
        N_processed_points = N_processed_points + N_local_samples;
    end
end

control_timeseries = Control_timeseries;
error_timeseries = Error_timeseries;
if (N_processed_points >= N_samples)
    ready = true;
else
    ready = false;
end

end

