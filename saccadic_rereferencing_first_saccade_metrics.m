%% SACCADIC RE-REREFERENCING
% Marcello A. Maniglia, 2017-2019/10/28
%this script analyzes eyetracker data generated by the 'PRL_test.m' script
%and outputs saccadic re-referencing as graphs and percentages of first
%absolute fixations after target presentation and Latency of target
%acquisition.
%Saccadic Re-referencing reflects how often participants immediately see 
%the target. It is the proportion of trials where the end point of the first 
%saccade puts the target outside scotoma. The green dots represent first 
%fixations in each trial that successfully placed the target outside the 
%scotoma.
%Latency of Target Acquisition reflects how long it takes to observe the 
%target. It is the mean time until the target is visible outside scotoma.

%%


addpath([cd '/Functions']);
subNum=baseName(8:17);


name=['Saccadic Re-referencing and latency' subNum ]
subNum=['Sub ' baseName(8:11) ' Sess ' baseName(16:17) ' ' ];

firsttrial=1;
totaltrial=str2num(TrialNum(6:end));


%define the duration of the fixation in seconds (default: .133s)
durationtocallfixation=.133;
%duration of the fixation in frames (ifi = inter frame interval)
framestocallfixation=round(durationtocallfixation/ifi);
%screen info

Xcenter=wRect(3)/2;
Ycenter=wRect(4)/2;

fixcounter=[];
fixcounter_inside=[];


xlimit=Xcenter/pix_deg;
ylimit=Ycenter/pix_deg_vert;

%initialize heatmap
sampleX=(-xlimit:1:xlimit);
sampleY=(-ylimit:1:ylimit);
heatmatrix= zeros(length(sampleX), length(sampleY));


radius = scotomasize(1)/2; %radius of circular mask


[sx,sy]=meshgrid(-wRect(3)/2:wRect(3)/2,-wRect(4)/2:wRect(4)/2);
circlePixels=sx.^2 + sy.^2 <= radius.^2;

d=(circlePixels==1);
newfig=circlePixels;
circlePixels=newfig;

arrayInside=[];
figure


counterInside=nan(totaltrial,1);
counterOutside=nan(totaltrial,1);

%initialize graph
firstframetarget=[]
poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert];
rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
hold on
poss2=poss2*1.2;
poss = [-scotomadeg/2 -scotomadeg/2 scotomadeg scotomadeg];
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
text(0,-16.5, '15^{\circ} ', 'FontSize', 20)

for i=firsttrial:totaltrial
    TrialNum = strcat('Trial',num2str(i));
    
    if exist('EyeSummary.(TrialNum).FixationIndices(end,2)')==0
        EyeSummary.(TrialNum).FixationIndices(end,2)=length(EyeSummary.(TrialNum).EyeData);
    end;
    
    
    %find the first available eye position after stimulus presentation

    FramesAfterTargetPresentation=find(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.Stimulus)
    
    
    if length(FramesAfterTargetPresentation)>0 %at least one valid frame after target presentation
        
        skipp(i)=1;
        firstframetarget=[firstframetarget FramesAfterTargetPresentation(1) ];
        
        
        Heatmap.(TrialNum).TargetX=EyeSummary.(TrialNum).TargetX*pix_deg;
        Heatmap.(TrialNum).TargetY=EyeSummary.(TrialNum).TargetY*pix_deg;
        
        
        tgt_y=Heatmap.(TrialNum).TargetY;
        tgt_x=Heatmap.(TrialNum).TargetX;
        
        Heatmap.(TrialNum).TargetXRespectToCenter=Xcenter+Heatmap.(TrialNum).TargetX;
        Heatmap.(TrialNum).TargetYRespectToCenter=Ycenter+Heatmap.(TrialNum).TargetY;
                
        fix=0;
        cntr=0;
       % counterr=0;
        
        
        clear ww
        %collect fixation indexes from VA task
        ww=EyeSummary.(TrialNum).FixationIndices(EyeSummary.(TrialNum).FixationIndices(:,1)>FramesAfterTargetPresentation(1),:)
        
        countr{i}=ww;
        clear w
        
        
        %consider only fixation intervals long enough to be called a
        %fixation
        w=[];
        w2=[];
        if isempty(ww)==0
            % first and last frame of the valid fixations
            for jid=1:length(ww(:,1))
                if ww(jid,2)-ww(jid,1)>=framestocallfixation && ww(jid,1)>FramesAfterTargetPresentation(1)+10
                    w=ww(jid,1)
                    w2=ww(jid,2)
                    break
                end
            end
        end
        
        if isempty(w)==0
            
            FirstFrameFix(i)=w;
            LastFrameFix(i)=w2;
            LengthFirstfixation(i)=w2-w;
            EyeSummary.(TrialNum).FixationIndices(find(EyeSummary.(TrialNum).FixationIndices(:,1)==w),1);
            
                    %Reaction time fix
            RT_tgt=EyeSummary.(TrialNum).EyeData(FramesAfterTargetPresentation(1),5);
            RT_fix=EyeSummary.(TrialNum).EyeData(w,5);
            
            RT_first_saccade(i)=RT_fix-RT_tgt;          
            
            EyeX=EyeSummary.(TrialNum).EyeData(w,1);
            EyeY=EyeSummary.(TrialNum).EyeData(w,2);
            
            diffx=EyeX-(wRect(3)/2+tgt_x);
            diffy=EyeY-(wRect(4)/2+tgt_y);
            
      %      counterr=1;
            %if fixation within the boundaries of the screen
            if round(wRect(3)/2+diffx)<=wRect(3) && round(wRect(4)/2+diffy)<=wRect(4) && round(wRect(3)/2+diffx)> 0 && round(wRect(4)/2+diffy)>0
              %if fixation outside scotoma
                if circlePixels(round(wRect(4)/2+diffy),round(wRect(3)/2+diffx))==0
                    cntr=1;
                    Heatmap.(TrialNum).OneFixationX(cntr)=EyeSummary.(TrialNum).EyeData(w,1);%/pix_deg;
                    Heatmap.(TrialNum).OneFixationY(cntr)=EyeSummary.(TrialNum).EyeData(w,2);%/pix_deg_vert;
                    counterOutside(i)=2;
                    counterAll(i)=2;
                                  %if fixation inside scotoma
                elseif circlePixels(round(wRect(4)/2+diffy),round(wRect(3)/2+diffx))==1
                    insidecntr=1;
                    counterAll(i)=1;
                    counterInside(i)=1;
                    Heatmap.(TrialNum).OneFixationXinside(insidecntr)=EyeSummary.(TrialNum).EyeData(w,1);%/pix_deg;
                    Heatmap.(TrialNum).OneFixationYinside(insidecntr)=EyeSummary.(TrialNum).EyeData(w,2);%/pix_deg_vert;
                end
                
            end           
            
            if isfield(Heatmap.(TrialNum),'OneFixationX')
                Heatmap.(TrialNum).OneFixationXClean=Heatmap.(TrialNum).OneFixationX(Heatmap.(TrialNum).OneFixationX~=0);
                Heatmap.(TrialNum).OneFixationYClean=Heatmap.(TrialNum).OneFixationY(Heatmap.(TrialNum).OneFixationY~=0);
                
                RT_first_saccadeout(i)=RT_first_saccade(i);
                              
                
                offsetTarget.(TrialNum).FixationY=(Heatmap.(TrialNum).OneFixationYClean)-Heatmap.(TrialNum).TargetYRespectToCenter;
                offsetTarget.(TrialNum).FixationX=(Heatmap.(TrialNum).OneFixationXClean)-Heatmap.(TrialNum).TargetXRespectToCenter;
                
                if length(offsetTarget.(TrialNum).FixationY)~=length(offsetTarget.(TrialNum).FixationX)
                    
                    if length(offsetTarget.(TrialNum).FixationY)>length(offsetTarget.(TrialNum).FixationX)
                        offsetTarget.(TrialNum).FixationY=offsetTarget.(TrialNum).FixationY(1:length(offsetTarget.(TrialNum).FixationX));
                    elseif length(offsetTarget.(TrialNum).FixationY)<length(offsetTarget.(TrialNum).FixationX)
                        offsetTarget.(TrialNum).FixationX=offsetTarget.(TrialNum).FixationX(1:length(offsetTarget.(TrialNum).FixationY));
                    end
                end
                
                 coordinates.(TrialNum).RelativeToCenter=[offsetTarget.(TrialNum).FixationX'  offsetTarget.(TrialNum).FixationY'];
             %   coordinates.(TrialNum).FixAbs=[(Heatmap.(TrialNum).OneFixationX)' (Heatmap.(TrialNum).OneFixationY)']
                
                                
                scatter((coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(1,2))/pix_deg_vert, 30, [0 1 0], 'filled');
                hold on
                set (gca,'YDir','reverse')
                
                degX=(coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg);
                degY=(coordinates.(TrialNum).RelativeToCenter(1,2)/pix_deg_vert);
                
                for sss=2:length(sampleX)
                    for dd=2:length(sampleY)
                        
                        if degX<=sampleX(sss) && degX>=sampleX(sss-1) && degY<=sampleY(dd) && degY>=sampleY(dd-1)                           
                            heatmatrix(sss-1,dd-1)=heatmatrix(sss-1,dd-1)+1;
                        end
                    end                                                           
                end            
                
                fixcount=coordinates.(TrialNum).RelativeToCenter(1,:);
                
                fixcounter=[fixcounter;fixcount];
                
                
                
% fixcount=coordinates.(TrialNum).RelativeToCenter(1,:);
% 
% fixcounter=[fixcounter;fixcount];
%     clear fixcount
                clear fixcount
                hold on
                
              end
            
            if isfield(Heatmap.(TrialNum),'OneFixationXinside')
                Heatmap.(TrialNum).OneFixationXCleaninside=Heatmap.(TrialNum).OneFixationXinside(Heatmap.(TrialNum).OneFixationXinside~=0)
                Heatmap.(TrialNum).OneFixationYCleaninside=Heatmap.(TrialNum).OneFixationYinside(Heatmap.(TrialNum).OneFixationYinside~=0)
                
                RT_first_saccadein(i)=RT_first_saccade(i);

                offsetTarget.(TrialNum).FixationYinside=(Heatmap.(TrialNum).OneFixationYCleaninside)-Heatmap.(TrialNum).TargetYRespectToCenter;
                offsetTarget.(TrialNum).FixationXinside=(Heatmap.(TrialNum).OneFixationXCleaninside)-Heatmap.(TrialNum).TargetXRespectToCenter;

                coordinates.(TrialNum).RelativeToCenterinside=[offsetTarget.(TrialNum).FixationXinside'  offsetTarget.(TrialNum).FixationYinside'];
           %     coordinates.(TrialNum).FixAbsinside=[(Heatmap.(TrialNum).OneFixationXinside)' (Heatmap.(TrialNum).OneFixationYinside)']
                
                scatter((coordinates.(TrialNum).RelativeToCenterinside(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenterinside(1,2))/pix_deg_vert, 30, [1 0 0], 'filled');
                hold on
                set (gca,'YDir','reverse')               
                degXinside=(coordinates.(TrialNum).RelativeToCenterinside(1,1)/pix_deg);
                degYinside=(coordinates.(TrialNum).RelativeToCenterinside(1,2)/pix_deg_vert);                
                arrayInside=[arrayInside i];
                                
            end       
            if isfield(Heatmap.(TrialNum),'OneFixationXinside')
                ff2=coordinates.(TrialNum).RelativeToCenterinside(1,:); 
                fixcounter_inside=[fixcounter_inside;ff2]
                clear ff2
            end
            clear fixcount
            hold on
          end
    end
end



xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);

if isempty(fixcounter)==0
FixationsX=fixcounter(:,1)/pix_deg;
FixationsY=fixcounter(:,2)/pix_deg_vert;
AllFix=[FixationsX FixationsY]
end

FixationsXinside=fixcounter_inside(:,1)/pix_deg;
FixationsYinside=fixcounter_inside(:,2)/pix_deg_vert;
AllFixinside=[FixationsXinside FixationsYinside]


hold on

if isempty(fixcounter)==0
RT_saccadeNonzout=RT_first_saccadeout(RT_first_saccadeout~=0)
averageRTout=mean(RT_saccadeNonzout)
txt32=num2str(averageRTout);
if length(txt32)==3
    txt32=txt32(1:3);
elseif length(txt32)==2
    txt32=txt32(1:2);
elseif length(txt32)==4
    txt32=txt32(1:4);
else
    txt32=txt32(1:5);
end
end
RT_saccadeNonzin=RT_first_saccadein(RT_first_saccadein~=0);
averageRTin=mean(RT_saccadeNonzin);
txt22=num2str(averageRTin);

if length(txt22)>5
    txt22=txt22(1:5);
end



RT_saccadeNonz=RT_first_saccade(RT_first_saccade~=0);
averageRT=mean(RT_saccadeNonz);
txt12=num2str(averageRT);
txt12=txt12(1:5)


data=[];
if isempty(fixcounter)==0
FixationsX=fixcounter(:,1)/pix_deg;
FixationsY=fixcounter(:,2)/pix_deg_vert;
data=[FixationsX FixationsY];
end
data2=[FixationsXinside FixationsYinside];


percentage=size(data2,1)/(size(data2,1)+size(data,1))*100;


tuttefix=(size(data2,1)+size(data,1))
percentage=100-percentage;



txt11=num2str(percentage);
if length(txt11)==3
    txt11=txt11(1:3)
elseif length(txt11)==2
    txt11=txt11(1:2)
else
    txt11=txt11
end


set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')

set(gca,'FontSize',26)
title([subNum 'fixation distribution']);


ylabel('degrees of visual angle', 'fontsize', 28);
xlabel('degrees of visual angle', 'fontsize', 28);

%grid on
pbaspect([1.5 1 1]);

%  print([name '_fixationdistribution'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


hold on


xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);
data3=[ data;data2];
ellli=cov(data3(:,1),data3(:,2));



print([name '_fixationdistribution'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI

checkBCEA=0;
try
    error_ellipse(ellli, mean(data3), .68)   
    [eigenvec, eigenval ] = eig(ellli);
    d=sqrt(eigenval);
    areaEll=pi*d(1)*d(4)  ;  
    areaEllarcmin=3600*areaEll;
    caption=round(areaEllarcmin)/3600;
    thetaM=rad2deg(acos(eigenvec(1,1)));
    txt10=num2str(caption);
    if caption>10
        txt10=txt10(1:5);
    else
        txt10=txt10(1:4);
    end
    checkBCEA=1;
    
end
hold on


text(11,11, [ txt11, '% fixations'], 'FontSize', 20)
text(11,13, ['outside scotoma'], 'FontSize', 20)
text(11,15, ['RT in= ' txt22, ' s'], 'FontSize', 20)
if isempty(fixcounter)==0
    text(11,17, ['RT out= ' txt32, ' s'], 'FontSize', 20)
end
text(11,9, ['BCEA= ' txt10, ' deg^{' num2str(2) '}'], 'FontSize', 20)

print([name '_fixationdistributionBCEA'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


figure


rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
hold on
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


scatter(data3(:,1), data3(:,2), 30, [0 0 1], 'filled');

set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')

set(gca,'FontSize',26)
title([subNum 'landing BCEA']);


 if checkBCEA==1
    text(11,11, ['BCEA= ' txt10, ' deg^{' num2str(2) '}'], 'FontSize', 20)
     
 end

ylabel('degrees of visual angle', 'fontsize', 28);
xlabel('degrees of visual angle', 'fontsize', 28);

xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);
%grid on
pbaspect([1.5 1 1]);

print([name '_landingBCEA'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI




figure
rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
hold on
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
text(0.5,-6.5, '5^{\circ} ', 'FontSize', 20)
text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


hold on


dens=std(data3)/length(data3)^(1/10);
npern=512;
MAX=max(data3,[],1); MIN=min(data3,[],1); Range=MAX-MIN;
MAX_XY=MAX+Range/4; MIN_XY=MIN-Range/4;

[bandwidth,density,X,Y]=kde2d_mm(data3,npern,MAX_XY,MIN_XY,dens);

% plot the data and the density estimate
contour3(X,Y,density,50), hold on
%plot(data3(:,1),data3(:,2),'r.','MarkerSize',5)
view(2)
pbaspect([1.5 1 1]);
set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')


set(gca,'FontSize',26)
title([subNum 'landing kernel']);
hold on
ylabel('degrees of visual angle', 'fontsize', 28);
xlabel('degrees of visual angle', 'fontsize', 28);
hold on

%text(11,11, ['BCEA= ' txt10, ' deg^{' num2str(2) '}'], 'FontSize', 20)


xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);


print([name 'landing_kernel'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI



outside_array=[(1:totaltrial)' counterOutside];
inside_array=[(1:totaltrial)' counterInside];

trials_inside=inside_array(inside_array(:,2)==1);
trials_outside=outside_array(outside_array(:,2)==2);


 
  



%%
%outside only
figure

rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
hold on
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
text(0,-16.5, '15^{\circ} ', 'FontSize', 20)
if isempty(fixcounter)==0
scatter((fixcounter(:,1)/pix_deg),fixcounter(:,2)/pix_deg_vert, 30, [0 1 0], 'filled');
hold on
end
set (gca,'YDir','reverse')
ylabel('degrees of visual angle', 'fontsize', 28);
xlabel('degrees of visual angle', 'fontsize', 28);

xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);
set(gca,'FontSize',26)
title([subNum 'outside only']);

%grid on
pbaspect([1.5 1 1]);

print([name 'outsideonly'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


%inside only
figure


rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
hold on
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


scatter(fixcounter_inside(:,1)/pix_deg,fixcounter_inside(:,2)/pix_deg_vert, 30, [1 0 0], 'filled');
hold on
set (gca,'YDir','reverse')

ylabel('degrees of visual angle', 'fontsize', 28);
xlabel('degrees of visual angle', 'fontsize', 28);

xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);
%grid on
set(gca,'FontSize',26)
title([subNum 'inside only']);

pbaspect([1.5 1 1]);

print([name 'insideonly'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


matrixinside=[arrayInside' fixcounter_inside];
