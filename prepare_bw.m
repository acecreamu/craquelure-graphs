%% Binarization

name = 'imgs/sq-bouts1.jpg';
img = im2double(imread(name));
if size(img,1)>size(img,2); img = imrotate(img,90); end

r = 2; % depends on size of cracks (normally 2, 3, 5, 10)
minArea = 200;   % the smaller the better, removes small elements (noise)

bw = [];
for j = 1:size(img,3)
im=img(:,:,j);
%im = im2double(locallapfilt(uint8(im*255), 0.4, 0.9));
%im = adapthisteq(im,'clipLimit',0.01, 'Distribution','exponential');
im_hat = imbothat(im,strel('disk',r));
%figure; imshow(im_hat)

T = adaptthresh(im_hat,1e-10);
im = imbinarize(im_hat, T); 
im = bwareaopen(im, minArea);

% simple binarization
% im = imbinarize(im_hat);
% im = imclose(im,strel('disk',4));
% im = bwareaopen(im, minArea);
bw(:,:,j) = im;
end

%im = im-min(im(:))./max(max(im-min(im(:))));
bw = max(bw,[],3);
figure;imshow(bw)


%% Skeletonization

save = 0;
rClose = 4; % the smaller the better, connects mistakenly splitted cracks

skel1 = bwmorph(bw,'skel',Inf);
% closing connects disjoint links, uncomment for visualization
% figure; imshow(skel1)
skel2 = imclose(bw,strel('disk',rClose));
figure; imshow(skel2)
skel2 = bwmorph(skel2,'skel',Inf);
% figure; imshow(skel2)
if save
    nameNew = sprintf('%s_r%d_minArea%d_closeR%d.tif', ...
        name(1:end-4), r, minArea, rClose);
    imwrite(skel2,nameNew)
end

