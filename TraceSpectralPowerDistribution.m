function TraceSpectralPowerDistribution(instrument,output)
    [FileName,PathName] = uigetfile('*.jpg','Select Images...','image.jpg','MultiSelect','on');
    
    alldata = [];
    if instrument == 'sekonic'
        
        step = 400/1699;
        plotX = [380+step:step:780]';
        alldata(:,1) = plotX;
        for i=1:length(FileName)
            imagepath = strcat(PathName,FileName{i});
            trace = processSekonic(imagepath);
            alldata(:,i+1) = trace;
        end
    end
    strcat(PathName,output)
    xlswrite(strcat(PathName,output),alldata);
end

function trace = processSekonic(imagepath)
    
    image = imread(imagepath);
    graphCrop = imcrop(image,[181 58 1698 1147]);
    
    distribution = rgb2gray(graphCrop) < 250 & rgb2gray(graphCrop) > 5;
    trace = zeros(1,size(distribution,2));
    for i=1:size(distribution,2)
        thiscol = distribution(:,i);
        nonzero = find(thiscol,1);
        if isempty(nonzero)
            trace(i) = 0;
        else
            trace(i) = 1 - nonzero/size(distribution,1);
        end
    end
end