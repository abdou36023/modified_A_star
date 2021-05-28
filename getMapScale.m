function [ mapScale ] = getMapScale( latLong1,latLong2,pixXY1, pixXY2 )
R = 6371e3;
theta1 = latLong1(1)*pi/180;
theta2 = latLong2(1)*pi/180;
deltaTheta = (latLong2(1)-latLong1(1))*pi/180;
delta = (latLong2(2)-latLong1(2))*pi/180;
a = sin(deltaTheta/2)^2+cos(theta1)*cos(theta2)*sin(delta/2)^2;
c = 2 * atan2(sqrt(a),sqrt(1-a));
disR = R*c;
disP = sqrt((pixXY1(1)-pixXY2(1))^2+(pixXY1(2)-pixXY2(2))^2);
mapScale = disP/disR;
end

