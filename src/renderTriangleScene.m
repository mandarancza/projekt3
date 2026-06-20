function image = renderTriangleScene(scene, lightPos, modelName, opts)
%RENDERTRIANGLESCENE Renderuje scene przez rzut rownolegly na plaszczyzne OXY.

modelName = lower(char(modelName));
if ~strcmp(modelName, 'lambert') && ~strcmp(modelName, 'phong')
    error("Nieznany model oswietlenia: %s", modelName);
end

[xCenters, yCenters] = pixelCenters(opts);
zBuffer = -inf(opts.height, opts.width);

rgb = zeros(opts.height, opts.width, 3);
for channel = 1:3
    rgb(:, :, channel) = double(opts.backgroundRGB(channel));
end

for triIdx = 1:numel(scene.triangles)
    triangle = scene.triangles(triIdx);
    vertices = triangle.vertices;

    minX = min(vertices(:, 1));
    maxX = max(vertices(:, 1));
    minY = min(vertices(:, 2));
    maxY = max(vertices(:, 2));

    cols = find(xCenters >= minX - opts.pixelSize & xCenters <= maxX + opts.pixelSize);
    rows = find(yCenters >= minY - opts.pixelSize & yCenters <= maxY + opts.pixelSize);
    if isempty(cols) || isempty(rows)
        continue;
    end

    [gridX, gridY] = meshgrid(xCenters(cols), yCenters(rows));
    [w1, w2, w3] = barycentric2d(gridX, gridY, vertices);

    inside = w1 >= -opts.barycentricTolerance & ...
        w2 >= -opts.barycentricTolerance & ...
        w3 >= -opts.barycentricTolerance;

    zCandidate = w1 .* vertices(1, 3) + ...
        w2 .* vertices(2, 3) + ...
        w3 .* vertices(3, 3);

    localZ = zBuffer(rows, cols);
    visible = inside & zCandidate > localZ;
    if ~any(visible(:))
        continue;
    end

    pointCount = nnz(visible);
    points = zeros(pointCount, 3);
    points(:, 1) = gridX(visible);
    points(:, 2) = gridY(visible);
    points(:, 3) = zCandidate(visible);

    colors = shadePoints(points, scene, triIdx, lightPos, modelName, opts);

    localZ(visible) = zCandidate(visible);
    zBuffer(rows, cols) = localZ;

    for channel = 1:3
        localRGB = rgb(rows, cols, channel);
        localRGB(visible) = colors(:, channel);
        rgb(rows, cols, channel) = localRGB;
    end
end

image = uint8(max(0, min(255, round(rgb))));
end

function [xCenters, yCenters] = pixelCenters(opts)
xCenters = ((1:opts.width) - (opts.width + 1) / 2) * opts.pixelSize + opts.center(1);
yCenters = ((opts.height + 1) / 2 - (1:opts.height)) * opts.pixelSize + opts.center(2);
end

function [w1, w2, w3] = barycentric2d(x, y, vertices)
x1 = vertices(1, 1);
y1 = vertices(1, 2);
x2 = vertices(2, 1);
y2 = vertices(2, 2);
x3 = vertices(3, 1);
y3 = vertices(3, 2);

denominator = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3);
w1 = ((y2 - y3) .* (x - x3) + (x3 - x2) .* (y - y3)) ./ denominator;
w2 = ((y3 - y1) .* (x - x3) + (x1 - x3) .* (y - y3)) ./ denominator;
w3 = 1 - w1 - w2;
end

function colors = shadePoints(points, scene, triIdx, lightPos, modelName, opts)
triangle = scene.triangles(triIdx);
pointCount = size(points, 1);

toLight = bsxfun(@minus, lightPos, points);
distance = sqrt(sum(toLight.^2, 2));
lightDir = bsxfun(@rdivide, toLight, distance);

normal = repmat(triangle.normal, pointCount, 1);
ndotlRaw = sum(normal .* lightDir, 2);
if opts.twoSidedLighting
    flipMask = ndotlRaw < 0;
    normal(flipMask, :) = -normal(flipMask, :);
    ndotl = abs(ndotlRaw);
else
    ndotl = max(ndotlRaw, 0);
end

shadowMask = pointsInShadow(points, scene, triIdx, lightPos, opts.shadowEpsilon);
ndotl(shadowMask) = 0;

denominator = 1 + opts.attenuation * distance.^2;
lightRGB = bsxfun(@rdivide, opts.maxLightRGB, denominator);

base = repmat(triangle.baseColor, pointCount, 1);
ambient = repmat(opts.ambientRGB, pointCount, 1);
diffuse = lightRGB .* repmat(ndotl, 1, 3);
colors = base .* (ambient + diffuse);

if strcmp(modelName, 'phong')
    toObserver = bsxfun(@minus, opts.observer, points);
    observerDistance = sqrt(sum(toObserver.^2, 2));
    viewDir = bsxfun(@rdivide, toObserver, observerDistance);

    reflectDir = 2 * repmat(ndotl, 1, 3) .* normal - lightDir;
    specular = max(sum(reflectDir .* viewDir, 2), 0) .^ opts.phongM;
    specular(shadowMask | ndotl <= 0) = 0;

    colors = colors + base .* lightRGB .* repmat(specular, 1, 3);
end
end

function shadowMask = pointsInShadow(points, scene, sourceTriIdx, lightPos, epsilon)
shadowMask = false(size(points, 1), 1);

for triIdx = 1:numel(scene.triangles)
    if triIdx == sourceTriIdx
        continue;
    end

    hitMask = segmentIntersectsTriangle(points, lightPos, scene.triangles(triIdx).vertices, epsilon);
    shadowMask = shadowMask | hitMask;
end
end

function hitMask = segmentIntersectsTriangle(points, lightPos, vertices, epsilon)
pointCount = size(points, 1);
direction = bsxfun(@minus, lightPos, points);

edge1 = vertices(2, :) - vertices(1, :);
edge2 = vertices(3, :) - vertices(1, :);

edge1Rows = repmat(edge1, pointCount, 1);
edge2Rows = repmat(edge2, pointCount, 1);

h = crossRows(direction, edge2Rows);
a = sum(edge1Rows .* h, 2);
valid = abs(a) > epsilon;

f = zeros(pointCount, 1);
f(valid) = 1 ./ a(valid);

s = bsxfun(@minus, points, vertices(1, :));
u = f .* sum(s .* h, 2);

q = crossRows(s, edge1Rows);
v = f .* sum(direction .* q, 2);
t = f .* sum(edge2Rows .* q, 2);

hitMask = valid & ...
    u >= -epsilon & ...
    v >= -epsilon & ...
    (u + v) <= 1 + epsilon & ...
    t > epsilon & ...
    t < 1 - epsilon;
end

function c = crossRows(a, b)
c = [ ...
    a(:, 2) .* b(:, 3) - a(:, 3) .* b(:, 2), ...
    a(:, 3) .* b(:, 1) - a(:, 1) .* b(:, 3), ...
    a(:, 1) .* b(:, 2) - a(:, 2) .* b(:, 1)];
end
