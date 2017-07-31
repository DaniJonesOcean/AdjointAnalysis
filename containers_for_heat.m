% use map containers to specify color axes for dJ 
valueSet = {[-2.0e-3 2.0e-3]};
myColorAxes = containers.Map(myAdjList,valueSet);

% use map containers to specify color axes for raw
valueSet = {[-2.0e-3 2.0e-3]};
myColorAxesRaw = containers.Map(myAdjList,valueSet);

% use map containers to specify color axes for dJ 
valueSet = {[-2.0e-3 2.0e-3]};
myColorAxesZlev = containers.Map(myAdjList,valueSet);

% use map container to specify color axes for dJ (vertical levels)
valueSet = {[-1.0e-3 1.0e-3]};
myColorAxesRawZlev = containers.Map(myAdjList,valueSet);

