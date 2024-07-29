function [xunit,yunit] = circle(x, y, r)
    th = 0:pi/60:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
end