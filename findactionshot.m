function [Fstart,Fend] = findactionshot(path_to_video)
%Usage examples
%findactionshot('003_card/2014_4_2_13_38_27')
%findactionshot('004_ball/2014_4_2_13_40_27')
%findactionshot('009_fistbump/2014_4_2_13_44_44')
%
% Returns start and end frame of the localized action

wsize = 50;
thres = 0.05;
 dist =  plotDist(path_to_video);
[val,idx] = sort(dist,'ascend');
 actionCenter = idx(min(find(val > 0)));
 %before the action
 percChange = abs(diff(dist(actionCenter-wsize:actionCenter)))./dist(actionCenter-wsize:actionCenter-1);
 idbefore = max(find(percChange > 2*thres));
 
 
 %after the action
 startFrame = actionCenter;
 endFrame = min(actionCenter + wsize,length(dist));
 percChange = diff(dist(startFrame:endFrame))./dist(startFrame:endFrame-1);
 idafter = min(find(percChange > thres));
 
 
 shotNum = (max(1,actionCenter - idbefore) : min(actionCenter + idafter + round(0.25*wsize),length(dist)));
 
 %shotNum = getshotNum(dist,actionCenter,wsize);
 %playAction(path_to_video,shotNum);
 Fstart = min(shotNum);
Fend = max(shotNum);

end
% function shotNum = getshotNum(dist,actionCenter,wsize);
% end
