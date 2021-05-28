function [ path ] = getPath( img ,startPoint , endPoint)
x = endPoint(2);
y = endPoint(1);
x1 = 0;
y1 = 0;
sz = size(img);
path = zeros(sz(1),sz(2),3);
path1 = double(img>0)/2;
while ~((x==startPoint(2)) && (y==startPoint(1)))
    min = img(x,y);
    for i = -1:1
        for j = -1:1
            if (i==0) && (j==0)
                continue
            end
            x2 = x+i;
            y2 = y+j;
            if (x2>sz(1)) || (y2>sz(2)) || (x2<1) || (y2<1)
                continue
            end
            if (img(x2,y2)~=0) && (min > img(x2,y2))
                x1 = x2;
                y1 = y2;
                min = img(x1,y1);
            end
        end
    end
    x = x1;
    y = y1;
    path1(x,y) = 1;
%     imshow(path1)
end
path(:,:,1) = ones(size(path1)).*path1;
path(:,:,2) = double(img>0)/2;
path(:,:,3) = double(img>0)/2;
figure(2)
imshow(path)
end

