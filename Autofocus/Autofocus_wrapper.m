function Autofocus_wrapper(smart_search)
%This is just a quick and dirty wrapper for the autofocus function to
%implement multiple calls

% smart_search is a Boolean determining whether or not to force a GoodFit
% in both searches by expanding the search until a GoodFit is achieved

%% Control Panel

%units in um
search_range_1st=5;
numsteps_1st=30;

search_range_2nd=1.75;
numsteps_2nd=20;

zpsf=0.3;

numframes=3;

plot_results=true;

which_fitfun=222;

%% Figure setup

%the figure showing the two searches
close(figure(98))
figure(98)
set(gcf,'Position',[21   512   560   420])
s1=subplot(2,1,1);
s2=subplot(2,1,2);

%% first search

goodfit=false;
while ~goodfit    
    [goodfit,focus_z]=AutofocusM(search_range_1st,numsteps_1st,zpsf,numframes,plot_results,which_fitfun);    
    
    %if not doing a smart search, then bypass any potential looping
    if ~smart_search
        goodfit=true;
    end
    
    if ~goodfit
        warning('First Autofocus failed to achieve a GoodFit, trying again with a bigger search')
        %increase the search range and the number of steps
        search_range_1st=search_range_1st*1.2;
        numsteps_1st=numsteps_1st*1.2;
    end
    
    %figure shenanigans
    %Autofocus plots in figure(99)
    figure(99)%opening figure(99)
    ax1=gca;% get handle to axes of figure
    fig1=get(ax1,'children');%get all the children of the plot
    copyobj(fig1,s1);%copy the plot
    %formating
    xlabel(s1,'z position (\mum)')
    ylabel(s1,'Score')
    title(s1,['Fit max at z =',num2str(focus_z),'    GoodFit = ',num2str(goodfit)])
    set(s1,'box','on')
    axis(s1,'tight')
end

%% second search

goodfit=false;
while ~goodfit
    [goodfit,focus_z]=AutofocusM(search_range_2nd,numsteps_2nd,zpsf,numframes,plot_results,which_fitfun);
    
    %if not doing a smart search, then bypass any potential looping
    if ~smart_search
        goodfit=true;
    end
    
    if ~goodfit
        warning('Second Autofocus failed to achieve a GoodFit, trying again with a bigger search')
        %increase the search range and the number of steps
        search_range_2nd=search_range_2nd*1.2;
        numsteps_2nd=numsteps_2nd*1.2;
    end
    
    %figure shenanigans
    %Autofocus plots in figure(99)
    figure(99)%opening figure(99)
    ax2=gca;% get handle to axes of figure
    fig2=get(ax2,'children');%get all the children of the plot
    copyobj(fig2,s2);%copy the plot
    close(figure(99))%close figure(99)
    %formating
    xlabel(s2,'z position (\mum)')
    ylabel(s2,'Score')
    title(s2,['Fit max at z =',num2str(focus_z),'    GoodFit = ',num2str(goodfit)])
    set(s2,'box','on')
    axis(s2,'tight')
end

end

