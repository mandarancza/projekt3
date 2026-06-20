function lightPos = movingLightPosition(k)
%MOVINGLIGHTPOSITION Pozycja zrodla swiatla dla klatki animacji.

t = 0.0315 * k;
lightPos = [-5 * cos(t), -5 + 5 * sin(t), -28];
end
