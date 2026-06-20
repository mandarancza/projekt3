function opts = defaultRenderOptions()
%DEFAULTRENDEROPTIONS Parametry obrazu, kamery i oswietlenia.

opts.width = 640;
opts.height = 480;
opts.pixelSize = 0.1;
opts.center = [0, 0];

% Kolor tla obrazu. Swiatlo otoczenia dla trojkatow jest zdefiniowane nizej.
opts.backgroundRGB = uint8([8, 8, 10]);

opts.ambientRGB = [100, 100, 100];
opts.maxLightRGB = [1000, 1000, 1000];
opts.attenuation = 0.001;

opts.observer = [10, 5, 40];
opts.phongM = 15;
opts.phongSpecularRGB = [1, 1, 1];
opts.phongSpecularScale = 1.4;

% Przy skali 0.1x0.1 i bardzo mocnym swietle punktowym sam ambient bywa
% wizualnie zbyt jasny, dlatego zacienione miejsca sa dodatkowo gaszone.
opts.shadowAmbientScale = 0.25;

% Zadanie nie definiuje jednostronnosci materialu. Dla czytelnych wynikow
% traktujemy trojkaty jako powierzchnie dwustronne.
opts.twoSidedLighting = true;

opts.shadowEpsilon = 1.0e-5;
opts.barycentricTolerance = 1.0e-10;
end
