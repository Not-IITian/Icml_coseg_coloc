function feat = generateFeature(imPath, outPath, param)

   [feat.data, feat.x, feat.y] = param.funFeat(imPath);
    save(outPath, 'feat');

if param.box_form ==0
 feat = [];
end
end



