function [im,disImg,dis] = dijkstra( startPoint,endPoint,img,showSteps,useSpeed,resizeFactor )
mapImg = img(:,:,1);
dis = 0;
if useSpeed ==1
    obsticle = imresize(imgaussfilt(img(:,:,2),0.05),resizeFactor);
    obsticle = double(obsticle)/100;
end
minObjectSurface = 250;
recFiltr = uint8(mapImg>250);
imgBin = bwareaopen(recFiltr,minObjectSurface);
%imgBin = 1-bwareaopen(1-imgBin,minObjectSurface);
filtImg = uint8(imgBin)*255;%.*mapImg;
filtImg = imgaussfilt(filtImg,0.01);
img = imresize(filtImg,resizeFactor);
disImg = zeros(size(img));


sz = size(img);
im = zeros(sz);
img = double(img>0)-1;
img(startPoint(2),startPoint(1)) = 1e-6;
disImg(startPoint(2),startPoint(1)) = 1e-6;
open = [startPoint(2),startPoint(1),0,0];
disp(endPoint);
close = [];% x, y, distansFromStart, distansToEnd,startToEnd
flag = true;
iteration = 0;
while flag
    iteration = iteration +1;
    [r,c] = find(open==min(open(:,end)));
    for i = -1:1
        for j = -1:1
            if (i==0) && (j==0)
                continue
            end
            if size(open,2)==0
                flag = false;
            end
            x = open(r(1),1)+i;
            y = open(r(1),2)+j;
            if (x == endPoint(2)) &&(y == endPoint(1))
                flag = false;
            end
            if (x>0) &&(y>0) &&(x<sz(1)) && (y<sz(2)) && (img(x,y)==0)
                dfs = open(r(1),3)+sqrt(i^2+j^2);
                if useSpeed == 1
                    param = dfs/obsticle(x,y);
                else 
                    param = dfs;
                end
                open = [open;x,y,dfs,param];
                if (img(x,y)==0) || (img(x,y)>param)
                    img(x,y) = param;
                    disImg(x,y)=(dfs);
                    dis = dfs;
                    im(x,y) = 1;
                    if (mod(iteration,20)==0) && showSteps
                        figure(1)
                        imshow(im)
                    end
                end
            end
        end
    end
    close = [close;open(r(1),:)];
    open(r(1),:) = [];
end


end

