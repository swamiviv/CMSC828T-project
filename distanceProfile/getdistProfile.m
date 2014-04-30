clear all
clc
dirlevel1 = dir('0*');
for j = 1:length(dirlevel1)
    listing = dir(strcat(dirlevel1(j).name,'\','2014*'));
    dist = [];
    figure(j);
        for i = 1:length(listing)
            dist(i).data = plotDist(strcat(dirlevel1(j).name,'\',listing(i).name));
            
            i
            subplot(3,4,i);
            plot(dist(i).data);
            xlim([1 200])

        end
        j
    title(dirlevel1(j).name);
end
