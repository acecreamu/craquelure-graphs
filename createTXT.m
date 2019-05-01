list = dir('imgs2/*.tif');

n = 10;
a = 800;


rng('default')

labels = [repmat(0, 8*n, 1) 
    repmat(1, 9*n, 1)
    repmat(2, 6*n, 1)
    repmat(3, 5*n, 1)
    repmat(4, 8*n, 1)];

fileID = fopen('CRACKS.txt','w');
fprintf(fileID, '%d\n',length(list)*n);

for i = 1:length(list) 
    skel = imread([list(i).folder '\' list(i).name]);
    
    for j = 1:n
        
        colLim = size(skel,2) - a;
        rowLim = size(skel,1) - a;
        c = ceil(rand * colLim);
        r = ceil(rand * rowLim);
        patch = skel(r:r+a-1, c:c+a-1, :);
        
        if round(rand)
            patch = flip(patch, 1);
        end
        
        if round(rand)
            patch = flip(patch, 2);
        end
        
        [~,links, nodes] = extractStats(patch);
        
        
        
        
        fprintf(fileID, '%d %d\n',length(nodes), labels((i-1)*n+j));
        
        for k = 1:length(nodes)
        fprintf(fileID,'0 ');
        fprintf(fileID,'%d ', length(nodes(k).conn), nodes(k).conn-1);
        fprintf(fileID,'\n');
        end
        
    end   
end
fclose(fileID);
