% -------------------- PARAMETROS --------------------
Rb = 1e3;              % Tasa de bits [bits/s]
Fs = 16e3;             % Frecuencia de muestreo [Hz]
sps = Fs / Rb;         % Muestras por simbolo (entero)
span = 6;              % Duracion del pulso en simbolos
rolloffs = [0 0.25 0.75 1];  % Lista de rolloffs a evaluar

% -------------------- GENERACION DE DATOS --------------------
data = randi([0 1], 10000, 1);      % 10000 bits aleatorios
symbols = 2*data - 1;              % BPSK: 0 -> -1, 1 -> 1

% -------------------- FIGURA --------------------
figure; hold on; grid on;
colors = ['b', 'r', 'g', 'm'];     % Colores para cada rolloff
legendEntries = cell(1, length(rolloffs));

for i = 1:length(rolloffs)
    rolloff = rolloffs(i);

    % -------------------- FILTRO --------------------
    rrcFilter = rcosdesign(rolloff, span, sps, 'normal');

    % -------------------- UPSAMPLING Y FILTRADO --------------------
    upsampled = upsample(symbols, sps);                     % Interpolacion
    txSignal = conv(upsampled, rrcFilter, 'full');          % Filtrado

    % Recorte de transitorios del filtro
    txSignal = txSignal(span*sps+1 : end-span*sps);

    % -------------------- DIAGRAMA DE OJO --------------------
    M = 2 * sps;                                     % 2 simbolos por traza
    numTraces = floor(length(txSignal) / M);         % Numero de trazas
    eyeMatrix = reshape(txSignal(1:M*numTraces), M, []);

    plot(eyeMatrix, colors(i));                      % Graficar diagrama de ojo
    legendEntries{i} = ['Roll-off = ', num2str(rolloff)];
end

xlabel('Muestras');
ylabel('Amplitud');
title('Diagrama de ojo para diferentes factores de roll-off');
legend(legendEntries);