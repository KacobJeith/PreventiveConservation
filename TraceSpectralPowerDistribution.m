function TraceSpectralPowerDistribution(instrument,output)
    [FileName,PathName] = uigetfile('*.*','Select Images...','image.jpg','MultiSelect','on');
    
    heading = {'Wavelength (nm)'};
    for i=1:length(FileName)
        [~,name,~] = fileparts(FileName{i});
        heading{i+1} = name;
    end
    
    
    alldata = [];
    switch instrument 
        
        case 'sekonic'
            
            step = 400/1699;
            plotX = [380+step:step:780]';
            alldata(:,1) = plotX;

            for i=1:length(FileName)
                
                imagepath = strcat(PathName,FileName{i});
                trace = processSekonic(imagepath);
                alldata(:,i+1) = trace;
            end
        
        case 'oceanoptics'
        
            step = 420/765;
            plotX = [380+step:step:800]';
            alldata(:,1) = plotX;

            for i=1:length(FileName)
                imagepath = strcat(PathName,FileName{i});
                trace = processOceanoptics(imagepath);
                alldata(:,i+1) = trace;
            end

        case 'asensetek'
            step = 400/258;
            plotX = [380:step:780]';
            alldata(:,1) = plotX;

            for i=1:length(FileName)
                imagepath = strcat(PathName,FileName{i});
                trace = processAsensetek(imagepath);
                alldata(:,i+1) = trace';
            end
    end
    
    alldata = num2cell(alldata);
    finalexport = [heading; alldata];
    size(finalexport)
    strcat(PathName,output)
    xlswrite(strcat(PathName,output),finalexport);
end

function trace = processSekonic(imagepath)
    
    % 380 to 780 nm
    % 1699 datapoints
    
    image = imread(imagepath);
    graphCrop = imcrop(image,[181 58 1698 1147]);
    
    distribution = rgb2gray(graphCrop) < 250 & rgb2gray(graphCrop) > 5;
    trace = zeros(1,size(distribution,2));
    for i=1:size(distribution,2)
        thiscol = distribution(:,i);
        nonzero = find(thiscol,1);
        if isempty(nonzero)
            trace(i) = NaN;
        else
            trace(i) = 1 - nonzero/size(distribution,1);
        end
    end
end

function trace = processOceanoptics(imagepath)
    
    % 380 to 800nm
    % 765 datapoints
    
    image = imread(imagepath);
    graphCrop = imcrop(image,[223 252 764 411]);
    pixelmaskPurple = graphCrop(:,:,1) == 255 & graphCrop(:,:,2) == 0 & graphCrop(:,:,3) == 255;
    pixelmaskGreen = graphCrop(:,:,1) == 21 & graphCrop(:,:,2) == 142 & graphCrop(:,:,3) == 21;
    pixelmask = pixelmaskPurple | pixelmaskGreen;
    
    for i=1:size(pixelmask,2)
        thiscol = pixelmask(:,i);
        nonzero = find(thiscol,1);
        if isempty(nonzero)
            trace(i) = 0;
        else
            trace(i) = 1 - nonzero/size(pixelmask,1);
        end
    end
    
    trace = imadjust(trace,[min(trace);max(trace)],[0,1]);
end

function trace = processAsensetek(imagepath)
    
    % 380 to 780 nm
    % 258 datapoints
    
    image = imread(imagepath);
    graphCrop = imcrop(image,[32 32 258 232]);
    r = graphCrop(:,:,1);
    g = graphCrop(:,:,2);
    b = graphCrop(:,:,3);
    
    mask = zeros([size(graphCrop,1),size(graphCrop,2)]);
    
    for i=1:(numel(graphCrop)/3)
        if r(i) ~= g(i) && r(i) ~= b(i)
            mask(i) = 1;
        end
        
    end
    
    mask = imopen(imclose(mask,ones(2)),ones(4));
    
    trace = zeros(1,size(graphCrop,2));
    for i=1:size(mask,2)
        thiscol = mask(:,i);
        nonzero = find(thiscol,1);
        if isempty(nonzero)
            trace(i) = NaN;
        else
            trace(i) = 1 - nonzero/size(mask,1);
        end
    end
    
end


function traceModified = g