function writeGifFrame(rgbFrame, fileName, isFirstFrame, delayTime)
%WRITEGIFFRAME Dopisuje klatke RGB do animacji GIF.

[indexedFrame, colorMap] = rgb2ind(rgbFrame, 256);

if isFirstFrame
    imwrite(indexedFrame, colorMap, fileName, 'gif', ...
        'LoopCount', inf, 'DelayTime', delayTime);
else
    imwrite(indexedFrame, colorMap, fileName, 'gif', ...
        'WriteMode', 'append', 'DelayTime', delayTime);
end
end
