% to be run witin get_season_avg

for i=1:size(month,1);

A = squeeze(month(i,:));

    if (A(1)=='J' & A(2)=='a' & A(3)=='n')
	month_num(i) = 1;
        season_num(i) = 1
    elseif (A(1)=='F' & A(2)=='e' & A(3)=='b')
	month_num(i) = 2;
        season_num(i) = 1;
    elseif (A(1)=='M' & A(2)=='a' & A(3)=='r')
	month_num(i) = 3;
        season_num(i) = 2;
    elseif (A(1)=='A' & A(2)=='p' & A(3)=='r')
	month_num(i) = 4;
        season_num(i) = 2;
    elseif (A(1)=='M' & A(2)=='a' & A(3)=='y')
	month_num(i) = 5;
        season_num(i) = 2;
    elseif (A(1)=='J' & A(2)=='u' & A(3)=='n')
	month_num(i) = 6;
        season_num(i) = 3;
    elseif (A(1)=='J' & A(2)=='u' & A(3)=='l')
	month_num(i) = 7;
        season_num(i) = 3;
    elseif (A(1)=='A' & A(2)=='u' & A(3)=='g')
	month_num(i) = 8;
        season_num(i) = 3;
    elseif (A(1)=='S' & A(2)=='e' & A(3)=='p')
	month_num(i) = 9;
        season_num(i) = 4;
    elseif (A(1)=='O' & A(2)=='c' & A(3)=='t')
	month_num(i) = 10;
        season_num(i) = 4;
    elseif (A(1)=='N' & A(2)=='o' & A(3)=='v')
	month_num(i) = 11;
        season_num(i) = 4;
    elseif (A(1)=='D' & A(2)=='e' & A(3)=='c')
	month_num(i) = 12;
        season_num(i) = 1;
    else
        month_num(i) = NaN;
        season_num(i) = NaN;
    end
 
end
