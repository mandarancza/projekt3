% Projekt MATLAB: oswietlenie i animacja trzech trojkatow 3D.
%
% Uruchom:
%   run_project
%
% Wyniki zostana zapisane w katalogu output/:
%   part1_lambert.png
%   part1_phong.png
%   part2_lambert.gif
%   part2_phong.gif

clear;
clc;

addpath(fullfile(pwd, 'src'));

outDir = fullfile(pwd, 'output');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

scene = createTriangleScene();
opts = defaultRenderOptions();

fixedLight = [-5, -5, -28];

fprintf("Generuje obraz: model Lamberta...\n");
imgLambert = renderTriangleScene(scene, fixedLight, 'lambert', opts);
imwrite(imgLambert, fullfile(outDir, 'part1_lambert.png'));

fprintf("Generuje obraz: model Phonga...\n");
imgPhong = renderTriangleScene(scene, fixedLight, 'phong', opts);
imwrite(imgPhong, fullfile(outDir, 'part1_phong.png'));

frameCount = 220; % nie mniej niz 200 klatek, zgodnie z trescia zadania
delayTime = 1 / 30;
lambertGif = fullfile(outDir, 'part2_lambert.gif');
phongGif = fullfile(outDir, 'part2_phong.gif');

fprintf("Generuje animacje Lamberta (%d klatek)...\n", frameCount);
for k = 0:(frameCount - 1)
    lightPos = movingLightPosition(k);
    frame = renderTriangleScene(scene, lightPos, 'lambert', opts);
    writeGifFrame(frame, lambertGif, k == 0, delayTime);
    fprintf("  Lambert: klatka %3d/%3d\n", k + 1, frameCount);
end

fprintf("Generuje animacje Phonga (%d klatek)...\n", frameCount);
for k = 0:(frameCount - 1)
    lightPos = movingLightPosition(k);
    frame = renderTriangleScene(scene, lightPos, 'phong', opts);
    writeGifFrame(frame, phongGif, k == 0, delayTime);
    fprintf("  Phong:   klatka %3d/%3d\n", k + 1, frameCount);
end

fprintf("Gotowe. Pliki zapisano w: %s\n", outDir);
