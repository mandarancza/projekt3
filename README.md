# Projekt MATLAB - trojkaty 3D, Lambert i Phong

Projekt generuje obrazy i animacje opisane w zadaniu:

- rzut rownolegly trzech trojkatow 3D na plaszczyzne OXY,
- rozdzielczosc `640x480`,
- rozmiar piksela `0.1 x 0.1`,
- modele oswietlenia Lamberta i Phonga,
- bufor Z dla widocznosci oraz test wzajemnego rzucania cieni,
- animacje z ruchomym zrodlem swiatla po okregu.

## Uruchomienie

W MATLAB-ie ustaw katalog projektu jako bieżący i uruchom:

```matlab
run_project
```

Skrypt zapisze wyniki w katalogu `output/`:

- `part1_lambert.png` - obraz statyczny, model Lamberta,
- `part1_phong.png` - obraz statyczny, model Phonga,
- `part2_lambert.gif` - animacja, model Lamberta,
- `part2_phong.gif` - animacja, model Phonga.

## Struktura

```text
run_project.m
src/
  createTriangleScene.m
  defaultRenderOptions.m
  movingLightPosition.m
  renderTriangleScene.m
  writeGifFrame.m
```

Najwazniejsze parametry obrazu, obserwatora i oswietlenia sa w pliku
`src/defaultRenderOptions.m`.

Parametry szczegolnie przydatne do regulacji wygladu:

- `shadowAmbientScale` - dodatkowe przyciemnienie obszarow w cieniu,
- `phongSpecularScale` - sila bialego odblysku zwierciadlanego w modelu Phonga,
- `phongM` - wykladnik polysku Phonga.
