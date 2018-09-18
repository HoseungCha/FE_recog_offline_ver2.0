function h = holdplot(h,x,x_db,x_wp)

if nargin <5
    do_plot1 = 1;
    do_plot2 = 1;
    do_plot3 = 1;
    name = {'Original','Signal To Be Warpped','Warpped'};
if nargin <4, do_plot3 = 0; name(3) = [];end
if nargin <3, do_plot2 = 0; name(2) = [];end
if nargin <2, error('please input data');end
end

figure(h);
hold on;
if do_plot1
    plot(x,'k');
end

if do_plot2
    plot(x_db,'b');
end

if do_plot3
    plot(x_wp,'r');
end

hold off;
legend(name);
end