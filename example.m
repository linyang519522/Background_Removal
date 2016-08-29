I=tifreadin('example.tif');
pI=background_removal(I, ... % Original image (uint8 format)
                      5, ... % Window size (the size of the smallest object in the image)
                      0.2 ...% Percentile
                      );
figure;imshow3D(I);                
figure;imshow3D(pI);