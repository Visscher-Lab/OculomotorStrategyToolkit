
%% SACCADIC PRECISION
% Marcello A. Maniglia, 2017-2019/10/28
%this script is part of the OculomotorStrategyToolkit (Maniglia, Visscher 
%and Seitz, 2020) and it analyzes eyetracker data generated by the 
%'PRL_test.m' to extract saccadic re-referencing as graphs and percentages 
%of first absolute fixations after target presentation. Some changes can 
%be made to modify some of the output.
%This analysis addresses the consistency of PRLs across trials by 
%calculating the distribution of locations of the trial's first fixation 
%that lands outside the scotoma. This fixation could therefore be the first 
%fixation, the second, or the third, etc. and represents the first fixation 
%during which the target can be seen. The measure of saccadic precision is 
%then represented as the size of the BCEA fitted on these fixation 
%positions. The BCEA is calculated to encompass a given proportion (P) of 
%the overall number of fixations. Following previous studies (Chung, 2013a;
% Crossland et al., 2004; Kwon et al., 2013), we chose P=0.68. In plots of 
%the individual saccade landing locations, we further visually distinguish 
%?absolute? first fixations (i.e., first fixations outside the scotoma that 
%happen to be the first fixation in the trial) with a different color from 
%other fixations following initial fixations to the scotoma.

addpath([cd '/Functions']);
subN=baseName(8:17);

name=['Saccadic Precision' subN ]
subNum=['Sub ' baseName(8:10) ' Sess ' baseName(16:17) ' ' ];

firsttrial=1;
totaltrial=str2num(TrialNum(6:end));

%define the duration of the fixation in seconds (default: .133s)
durationtocallfixation=.133;
%duration of the fixation in frames (ifi = inter frame interval)
framestocallfixation=round(durationtocallfixation/ifi);


%screen info
Xcenter=wRect(3)/2;
Ycenter=wRect(4)/2;

xlimit=Xcenter/pix_deg;
ylimit=Ycenter/pix_deg_vert;
fixcounter = [];

sampleX=(-xlimit:1:xlimit);
sampleY=(-ylimit:1:ylimit);
heatmatrix= zeros(length(sampleX), length(sampleY));

%scotoma info
radius = scotomasize(1)/2; %radius of circular mask
[sx,sy]=meshgrid(-wRect(3)/2:wRect(3)/2,-wRect(4)/2:wRect(4)/2);
circlePixels=sx.^2 + sy.^2 <= radius.^2;
d=(circlePixels==1);
newfig=circlePixels;
circlePixels=newfig;




%find the first available eye position after stimulus presentation
firstframetarget=[];

           % initialize the count of the first fixations which fell outside
           % the scotoma ('green' fixations in the graph)
        greenDot=nan(totaltrial,1);
        
           % initialize the count of the valid trials, which are those with
           % at least one fixation outside the scotoma
        valid_trials=nan(totaltrial,1);

           
for i=firsttrial:totaltrial
    TrialNum = strcat('Trial',num2str(i));

    if exist('EyeSummary.(TrialNum).FixationIndices(end,2)')==0
                %fix missing ending frame of last fixation in FixationIndices
        EyeSummary.(TrialNum).FixationIndices(end,2)=length(EyeSummary.(TrialNum).EyeData);
     end;
    

    FramesAfterTargetPresentation=find(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.Stimulus);
if length(FramesAfterTargetPresentation) > 0
     firstframetarget=[firstframetarget FramesAfterTargetPresentation(1) ];
            skipp(i)=1;
           %target coordinates (with respect to the center)
   Heatmap.(TrialNum).TargetX=EyeSummary.(TrialNum).TargetX*pix_deg;
   Heatmap.(TrialNum).TargetY=EyeSummary.(TrialNum).TargetY*pix_deg;
        
tgt_x=Heatmap.(TrialNum).TargetX;        
tgt_y=Heatmap.(TrialNum).TargetY;
        
Heatmap.(TrialNum).TargetXRespectToCenter=Xcenter+Heatmap.(TrialNum).TargetX;
Heatmap.(TrialNum).TargetYRespectToCenter=Ycenter+Heatmap.(TrialNum).TargetY;
       
    
    fix=0;
    cntr=0;
    counterr=0;

     
     clear ww
             % fixations after target presentation
    ww=EyeSummary.(TrialNum).FixationIndices(EyeSummary.(TrialNum).FixationIndices(:,1)>FramesAfterTargetPresentation(1),:);
    
    ValidFixationsCounter{i}=ww;
    clear w
    clear w2

    w=[];
    w2=[];
    
    
        %fixations after enough time from target presentation that last
        %long enough (as much as specified above)
        if isempty(ww)==0
            for jid=1:length(ww(:,1))
    if ww(jid,2)-ww(jid,1)>=framestocallfixation  && ww(jid,1)>FramesAfterTargetPresentation(1)+10
            w=[w ww(jid,1)];
            w2=[w2 ww(jid,2)];
            end
            end
        end
    
        firstw=[];
        firstw2=[];
        
        % first fixation in the trial (that took place long enough after
        % target appearance)
                        if isempty(ww)==0
            for jiid=1:length(ww(:,1))
    if ww(jiid,2)-ww(jiid,1)>=framestocallfixation && ww(jiid,1)>FramesAfterTargetPresentation(1)+10
            firstw=ww(jiid,1);
            firstw2=ww(jiid,2);
   break
            end
            end
        end

       
    
      if exist('w')==1
                for ui=1:length(w)   

        EyeSummary.(TrialNum).FixationIndices(find(EyeSummary.(TrialNum).FixationIndices(:,1)==w(ui)),1);
        %Reaction time fix
        RT_tgt=EyeSummary.(TrialNum).EyeData(FramesAfterTargetPresentation(1),5);
        
        %eye position at the time of fixation
        target_x=EyeSummary.(TrialNum).EyeData(w(ui),1);
        target_y=EyeSummary.(TrialNum).EyeData(w(ui),2);
        %eye position respect to the center and the target location
        diffx=target_x-(wRect(3)/2+tgt_x);
        diffy=target_y-(wRect(4)/2+tgt_y);
        
        counterr=1;
        valid_trials(i)=1;

if round(wRect(3)/2+diffx)<=wRect(3) && round(wRect(4)/2+diffy)<=wRect(4) && round(wRect(3)/2+diffx)> 0 && round(wRect(4)/2+diffy)>0
%if eye position within the limit of the screen
            if circlePixels(round(wRect(4)/2+diffy),round(wRect(3)/2+diffx))==0 && w(ui)>FramesAfterTargetPresentation(1)
                %if eye position outside the scotoma and after target presentation
              cntr=1;
              RT_fix=EyeSummary.(TrialNum).EyeData(w(ui),5);

RT_first_saccade(i)=RT_fix-RT_tgt;
        Heatmap.(TrialNum).OneFixationX(cntr)=EyeSummary.(TrialNum).EyeData(w(ui),1);%/pix_deg;
      Heatmap.(TrialNum).OneFixationY(cntr)=EyeSummary.(TrialNum).EyeData(w(ui),2);%/pix_deg_vert; 
      
      
      beginningFix=w(ui);
            endFix=w2(ui);
    LengthFirstfixation(i)=endFix-beginningFix;

whichfix(i)=ui;
totalnumberfix(i)=length(w);

firstfr(i)=firstw;

if w(ui)==firstw
    %if the first useful fixation is also the first absolute fixation, it
    %will be plotted as a green dot
    greenDot(i)=1;
end
      break

            end
end
                end

      

        
    
  if isfield(Heatmap.(TrialNum),'OneFixationX')
    Heatmap.(TrialNum).OneFixationXClean=Heatmap.(TrialNum).OneFixationX(Heatmap.(TrialNum).OneFixationX~=0)
        Heatmap.(TrialNum).OneFixationYClean=Heatmap.(TrialNum).OneFixationY(Heatmap.(TrialNum).OneFixationY~=0)

        RT_first_saccadeout(i)=RT_first_saccade(i);

              offsetTarget.(TrialNum).FixationY=(Heatmap.(TrialNum).OneFixationYClean)-Heatmap.(TrialNum).TargetYRespectToCenter;
            offsetTarget.(TrialNum).FixationX=(Heatmap.(TrialNum).OneFixationXClean)-Heatmap.(TrialNum).TargetXRespectToCenter;
  
                            %to account for uneven length of x and y array (sometimes
                %it happens)
                if length(offsetTarget.(TrialNum).FixationY)~=length(offsetTarget.(TrialNum).FixationX)
                    
                    if length(offsetTarget.(TrialNum).FixationY)>length(offsetTarget.(TrialNum).FixationX)
                        offsetTarget.(TrialNum).FixationY=offsetTarget.(TrialNum).FixationY(1:length(offsetTarget.(TrialNum).FixationX))
                    elseif length(offsetTarget.(TrialNum).FixationY)<length(offsetTarget.(TrialNum).FixationX)
                        offsetTarget.(TrialNum).FixationX=offsetTarget.(TrialNum).FixationX(1:length(offsetTarget.(TrialNum).FixationY))
                        
                    end
                end
                
                
                
                coordinates.(TrialNum).trgt=[offsetTarget.(TrialNum).FixationX'  offsetTarget.(TrialNum).FixationY']
                coordinates.(TrialNum).FixAbs=[(Heatmap.(TrialNum).OneFixationX)' (Heatmap.(TrialNum).OneFixationY)']
                coordinates.(TrialNum).RelativeToCenter=coordinates.(TrialNum).trgt;
                
                
                
%             coordinates.(TrialNum).Poke=[offsetTarget.(TrialNum).FixationX'  offsetTarget.(TrialNum).FixationY'];
%            coordinates.(TrialNum).FixAbs=[(Heatmap.(TrialNum).OneFixationX)' (Heatmap.(TrialNum).OneFixationY)'];
%             
%           
%                        coordinates.(TrialNum).PokeRespectToCenter=coordinates.(TrialNum).Poke;


            degX=(coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg);
 degY=(coordinates.(TrialNum).RelativeToCenter(1,2)/pix_deg_vert);


fixcount=coordinates.(TrialNum).RelativeToCenter(1,:);

fixcounter=[fixcounter;fixcount];
    

clear fixcount

  end

 
 
%clear fixcount
      end
      
else
    skipp(i)=0;
end
end
  




figure

poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert]; 
              rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
               hold on
               poss2=poss2*1.2
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

                  
hold on
all_valid_trials=[];
for i=firsttrial:totaltrial
    TrialNum = strcat('Trial',num2str(i));
 if skipp(i)==1    
  if isfield(Heatmap.(TrialNum),'OneFixationX')
      if isnan(greenDot(i))
all_valid_trials=[all_valid_trials i]
scatter((coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(1,2))/pix_deg_vert, 30, [1 0 0], 'filled');
      elseif greenDot(i)==1
          all_valid_trials=[all_valid_trials i]
          scatter((coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(1,2))/pix_deg_vert, 30, [0 1 0], 'filled');
      end
  end
  hold on
 end
end
set (gca,'YDir','reverse')




xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);


if ~isempty(fixcounter)
    %if we have at least one fixation that satisfies the conditions, then
    %we can plot them
FixationsX=fixcounter(:,1)/pix_deg;
FixationsY=fixcounter(:,2)/pix_deg_vert;
AllFix=[FixationsX FixationsY];

end
  
hold on

% figure
% 
%            
% for i=firsttrial:totaltrial
%     TrialNum = strcat('Trial',num2str(i));
%      if valid_trials(i)==1
%   if isfield(Heatmap.(TrialNum),'OneFixationX')
%       if isnan(greenDot(i))
% scatter((coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(1,2))/pix_deg_vert, 30, [1 0 0], 'filled');
%       elseif greenDot(i)==1
%           scatter((coordinates.(TrialNum).RelativeToCenter(1,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(1,2))/pix_deg_vert, 30, [0 1 0], 'filled');
% 
%       end
%   end
%   hold on
%  end
% end

  trials_out=all_valid_trials';
  cnt=1:totaltrial;
  cnt2=ismember(valid_trials,cnt);
  %trials counted in saccadic precision (both green and red)
  all_trials=cnt(cnt2);
  pointers=~ismember(all_trials, all_valid_trials);
  %trials not counted in saccadic precision (never left scotoma)
  trials_inside=all_trials(pointers);
 
  
  usefultrials=(length(trials_out)/length(all_trials))*100;
 
  
  
%   
%   
%   
%   trialfuori=tuttitrailsvalidi';
%   shis=1:totaltrial;
%   shis2=ismember(validitatrial,shis)
%   tuttitrial=shis(shis2)
%   pointers=~ismember(tuttitrial, tuttitrailsvalidi);
%   trialdentro=tuttitrial(pointers);
%   


if ~isempty(fixcounter)
RT_saccadeNonzout=RT_first_saccadeout(RT_first_saccadeout~=0);
 averageRTout=mean(RT_saccadeNonzout);
 txt32=num2str(averageRTout);
 if length(txt32)>4
txt32=txt32(1:5);
 end
 
 FixationsX=fixcounter(:,1)/pix_deg;
FixationsY=fixcounter(:,2)/pix_deg_vert;
data=[FixationsX FixationsY];
end


           set (gca,'YDir','reverse')
       
         title_two=['Saccadic Precision ' name(end-8:end) ]
                  set(gca,'FontSize',26)
         title(title_two)

 ylabel('degrees of visual angle', 'fontsize', 26);
  xlabel('degrees of visual angle', 'fontsize', 26);
 
pbaspect([1.5 1 1]);

         xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);


if ~isempty(fixcounter)
 ellli=cov(FixationsX,FixationsY);
data=[FixationsX FixationsY];
try
    error_ellipse(ellli, mean(data), .68)

[eigenvec, eigenval ] = eig(ellli);
d=sqrt(eigenval);

BCEA_in_deg=pi*d(1)*d(4);
thetaM=rad2deg(acos(eigenvec(1,1)));
txt10=num2str(BCEA_in_deg);
if BCEA_in_deg>10
txt10=txt10(1:5);
else
txt10=txt10(1:4);
end



end
end

     print([name ' BCEA'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


if ~isempty(fixcounter)

text(-6,11, ['BCEA= ' txt10, ' deg^{' num2str(2) '}'], 'FontSize', 20)
text(-6,13, ['Saccade Latency= ' txt32, ' sec'], 'FontSize', 20)
end


     print([name ' BCEA_latency'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI


usefultrials=(length(trials_out)/length(all_trials))*100;
txt312=num2str(usefultrials);
text(-6,15, ['Useful trials= ' txt312, '%'], 'FontSize', 20)
     print([name ' BCEA_latency_useful'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
