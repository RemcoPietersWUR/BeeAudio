function [abs_h,gfreq]= BeeFFT(audio,Fs, plotScaleFactor)

lengthOfData = length(audio);
nextPowerOfTwo = 2 ^ nextpow2(lengthOfData); % next closest power of 2 to the length

plotRange = nextPowerOfTwo / 2; % Plot is symmetric about n/2
plotRange = floor(plotRange / plotScaleFactor);
yDFT = fft(audio, nextPowerOfTwo);
h = yDFT(1:plotRange);
abs_h = abs(h);
freqRange = (0:nextPowerOfTwo-1) * (Fs / nextPowerOfTwo);  % Frequency range
gfreq = freqRange(1:plotRange);
end