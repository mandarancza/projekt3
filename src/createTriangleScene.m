function scene = createTriangleScene()
%CREATETRIANGLESCENE Definicja trojkatow z tresci zadania.

triangles(1) = makeTriangle( ...
    'A', ...
    [-22, 0, 58; 11, 19, 58; 0, 0, 26], ...
    [1, 0.5, 0.25]);

triangles(2) = makeTriangle( ...
    'B', ...
    [-22, 0, 58; 11, -19, 58; 0, 0, 26], ...
    [0.25, 1, 0.5]);

triangles(3) = makeTriangle( ...
    'C', ...
    [3, 19, 48; 3, -19, 48; -8, 0, 16], ...
    [0.25, 0.5, 1]);

scene.triangles = triangles;
end

function triangle = makeTriangle(name, vertices, baseColor)
triangle.name = name;
triangle.vertices = vertices;
triangle.baseColor = baseColor;

edge1 = vertices(2, :) - vertices(1, :);
edge2 = vertices(3, :) - vertices(1, :);
normal = cross(edge1, edge2);
triangle.normal = normal / norm(normal);
end
