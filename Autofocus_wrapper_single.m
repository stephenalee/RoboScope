function Autofocus_wrapper_single(smart_search)
%This is just a quick and dirty wrapper for the autofocus function to
%implement multiple calls

% smart_search is a Boolean determining whether or not to force a GoodFit
% in both searches by expanding the search until a GoodFit is achieved

%% Control Panel

%units in um
search_range_1st=5;
numsteps_1st=45;

zpsf=0.3;

numframes=3;

plot_results=true;

which_fitfun=222;

%% Figure setup

%the figure showing the two searches


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
   
    set(gcf,'Position',[21   512   560   420]);   
end


end

