% %Read Bee audio
clear all
%Get audio data location
[FileName,PathName] = uigetfile({'*.wma';'*.wav';'*.flac'},'Open audio file');

%Read audio data & make time vector
[audio,Fs] = audioread(fullfile(PathName,FileName));
time=linspace(0,numel(audio)/2/Fs,numel(audio)/2);
channel = 2;

%Ask user to select data range of the audio signal
hf = figure;
plot(time,audio(:,channel))
title('Select data range (mouse click)')
xlabel('Time (s)')
ylabel('Mic. voltage (V)')
axis tight
[x,~] = ginput(2); %Two points
close(hf)

%Select data range (array index)
t1=round(x(1)*Fs,0);
t2=round(x(2)*Fs,0);

%Ask user to define peak features
%Minimal peak height / noise threshold
hf = figure;
plot(time(t1:t2),audio(t1:t2,channel))
title('Select minimum peak height ("noise" threshold)')
xlabel('Time (s)')
ylabel('Mic. voltage (V)')
axis tight
[~,MinPeakHeight] = ginput(1);
close(hf)
%Minimal peak distance
hf = figure;
time_scaler = 0.1; %zoom in on a sample time frame of the sample
plot(time(t1:round(t2*time_scaler,0)),audio(t1:round(t2*time_scaler,0),channel))
hold on 
plot(time(t1:round(t2*time_scaler,0)),ones(1,numel(t1:round(t2*time_scaler,0)))*MinPeakHeight,'r')
title('Select minimum peak spacing')
xlabel('Time (s)')
ylabel('Mic. voltage (V)')
axis tight
[peak_space,~] = ginput(2);
close(hf)
MinPeakDistance = round(abs(peak_space(2)-peak_space(1))*Fs,0);

%Find peaks & plot
[pks,locs] = findpeaks(audio(t1:t2,channel),'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
hf = figure;
plot(time(t1:t2),audio(t1:t2,channel))
hold on 
plot(time(locs+t1),pks,'or')
title('Detected peaks')
xlabel('Time (s)')
ylabel('Mic. voltage (V)')
axis tight
uiwait(hf)

%Determine noise
[abs_h,gfreq]= BeeFFT(audio(t1:t2,2),Fs,40);
plot(gfreq,abs_h)
xlabel('Frequency (Hz)')
ylabel('Intensity')
title('Frequency spectrum, select frequency range')
axis tight
[f_range,~] = ginput(2);

%Get FFT per peak use Mimimal peak distance as window
Fmax = zeros(1,numel(pks));
for ipeak = 1:numel(pks)
    [spec{ipeak}.abs_h,spec{ipeak}.gfreq]= BeeFFT(audio((locs(ipeak)+t1-round(MinPeakDistance/2,0)):(locs(ipeak)+t1+round(MinPeakDistance/2,0)),2),Fs,40);
    f1 = find(spec{ipeak}.gfreq>round(f_range(1),0),1);
    f2 = find(spec{ipeak}.gfreq>round(f_range(2),0),1);
    [~,idf]=max(spec{ipeak}.abs_h(f1:f2)); 
    Fmax(ipeak)=spec{ipeak}.gfreq(f1+idf);
end

Fmax_time = (t1+locs)/Fs;
plot(Fmax_time,Fmax)
title(['Dominant frequency vs time. Recording: ',Filename])
xlabel('Time (s)')
ylabel('Frequency (Hz)')
axis tight   

%Save data
[Path,Filename,~]=fileparts(fullfile(PathName,FileName));
uisave({'t1','t2','spec','Fmax','Fmax_time','f1','f2','channel','MinPeakDistance','MinPeakHeight'},[Path,filesep,Filename,'.mat'])

     