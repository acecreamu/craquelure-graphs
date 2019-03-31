function [link_, node_] = YY2X(link, node, minLenYY)
node_ = node;
link_ = link;

for i = 1: length(link)
    if length(link(i).point) > minLenYY || ...
            length(node(link(i).n1).conn) ~= 3 || ...
            length(node(link(i).n2).conn) ~= 3
        continue
    end 
    
    % put a new X node in the middle between two Y
    newX = 0.5 * (node(link(i).n1).comx + node(link(i).n2).comx);
    newY = 0.5 * (node(link(i).n1).comy + node(link(i).n2).comy);
    
    node_(link(i).n1).comx = newX; node_(link(i).n1).comy = newY;
    node_(link(i).n2).comx = newX; node_(link(i).n2).comy = newY;
    
    % reassign connected nodes
    if length(unique(node(link(i).n1).conn))<length(node(link(i).n1).conn)
    continue
    end
    newConn = [node(link(i).n1).conn node(link(i).n2).conn];
    newConn(newConn == link(i).n1 | newConn == link(i).n2) = [];
    node_(link(i).n1).conn = newConn; 
    node_(link(i).n2).conn = newConn; 
    
    % reassign links
    newLinks = [node(link(i).n1).links node(link(i).n2).links];
    newLinks(newLinks == i) = [];
    node_(link(i).n1).links = newLinks; 
    node_(link(i).n2).links = newLinks;
    
    % reassign end point
    if (length(newConn)==1)
        node_(link(i).n1).ep = 1; 
        node_(link(i).n2).ep = 1;
    end
end