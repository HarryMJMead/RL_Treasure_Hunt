axes('Units', 'normalized', 'Position', [0 0 1 1])
background = imread('resources/desert_island_background.jpg');
image([-500, 1500], [-200, 1200], background);

hold on
grid off
axis equal
axis off

[grid_10_10, grid_10_10_map, grid_10_10_alpha] = imread('resources/grid_10_10.png');
image([-10, 1010], [-10, 1010], grid_10_10, 'AlphaData', grid_10_10_alpha)

no_clue_types = 4;
no_true_clue_types = 1;
no_clues_per_type = 3;s
no_attempts = 15;

% Load images
[anchor, anchor_map, anchor_alpha] = imread('resources/anchor.png'); % ID: 1
[barrel, barrel_map, barrel_alpha] = imread('resources/barrel.png'); % ID: 2
[bush, bush_map, bush_alpha] = imread('resources/bush.png'); % ID: 3
[palm_tree, palm_tree_map, palm_tree_alpha] = imread('resources/palm_tree.png'); % ID: 4
[rock, rock_map, rock_alpha] = imread('resources/rock.png'); % ID: 5
[shovel, shovel_map, shovel_alpha] = imread('resources/shovel.png'); % ID: 6
[treasure_chest, treasure_chest_map, treasure_chest_alpha] = imread('resources/treasure.png');
[coin, coin_map, coin_alpha] = imread('resources/coin.png');

ID_list = [1, 2, 3, 4, 5, 6]; % list of IDs for all clue types

% create list of clues (subset of ID_list)
clue_list = ID_list;
for i=1:(numel(ID_list)-no_clue_types)
    idx = randi(numel(clue_list));
    clue_list(idx) = [];
end

% create list of true clues (subset of clue_list)
true_clue_list = clue_list;
for i=1:(numel(clue_list)-no_true_clue_types)
    idx = randi(numel(true_clue_list));
    true_clue_list(idx) = [];
end

available_clue_locations = zeros(10, 10);
available_clue_locations(2:9,2:9) = 1; % don't let clues spawn on edges

treasure = zeros(10, 10);

for ID=1:6
    if ismember(ID,clue_list)
        % randomly generate new clue location from available spots
        for i = 1:no_clues_per_type
            is_valid = 0;
            it = 0;
            it_max = 1000;
            while is_valid == 0 && it < it_max
                i_y = randi([2,9]);
                i_x = randi([2,9]);
                is_valid = available_clue_locations(i_y,i_x);
                it = it + 1;
            end
            % stop future clues from spawning adjacent to this one
            available_clue_locations(i_y-1,i_x-1) = 0;
            available_clue_locations(i_y,i_x-1) = 0;
            available_clue_locations(i_y-1,i_x) = 0;
            available_clue_locations(i_y-1,i_x+1) = 0;
            available_clue_locations(i_y,i_x) = 0;
            available_clue_locations(i_y+1,i_x-1) = 0;
            available_clue_locations(i_y+1,i_x) = 0;
            available_clue_locations(i_y,i_x+1) = 0;
            available_clue_locations(i_y+1,i_x+1) = 0;
            if ismember(ID,true_clue_list)
                % assign treasure around clue (TODO: replace with a function that can use a different pattern for each clue)
                treasure = add_treasure(treasure,ID,i_y,i_x);
            end
            % plot corresonding image for clue ID
            if ID == 1
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], anchor, 'AlphaData', anchor_alpha)
            elseif ID == 2
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], barrel, 'AlphaData', barrel_alpha)
            elseif ID == 3
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], bush, 'AlphaData', bush_alpha)
            elseif ID == 4
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], palm_tree, 'AlphaData', palm_tree_alpha)
            elseif ID == 5
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], rock, 'AlphaData', rock_alpha)
            elseif ID == 6
                image([(i_x - 1 )*100, (i_x)*100], [(i_y - 1)*100, (i_y)*100], shovel, 'AlphaData', shovel_alpha)
            end
        end
    end
end

treasure;

score = 0;

% score_text = annotation('textbox');
% score_text.Position = [0, 0, 0., 0.1];
% score_text.String = "Score: " + score;
% score_text.FontSize = 1;
% score_text.FontUnits = "normalized";
% score_text.FontWeight = "bold";
% score_text.Color = 'k';
% score_text.BackgroundColor = 'white';
% score_text.FaceAlpha = 1;
% score_text.FitBoxToText = 'on';

score_text = text(825, -110, 'text');
score_text.String = "Score: " + score;
score_text.FontSize = 15;
score_text.FontUnits = "normalized";
score_text.FontName = "Papyrus";
score_text.FontWeight = "bold";
score_text.Color = 'k';
score_text.BackgroundColor = 'white';
score_text.EdgeColor = 'k';
score_text.LineWidth = 1;

turns_remaining_text = text(-175, -110, 'text');
turns_remaining_text.String = "Turns Remaining: " + no_attempts;
turns_remaining_text.FontSize = 15;
turns_remaining_text.FontUnits = "normalized";
turns_remaining_text.FontName = "Papyrus";
turns_remaining_text.FontWeight = "bold";
turns_remaining_text.Color = 'k';
turns_remaining_text.BackgroundColor = 'white';
turns_remaining_text.EdgeColor = 'k';
turns_remaining_text.LineWidth = 1;

for i = 1:no_attempts
    turn_done = 0;
    it = 0;
    it_max = 1000;
    % note: only allows an unsearched tile to be selected with each attempt
    while turn_done == 0 && it < it_max
        [xco, yco] = ginput(1);
    
        grid_loc_x = floor(xco / 100);
        grid_loc_y = floor(yco / 100);
        
        grid_square_x = grid_loc_x * 100;
        grid_square_y = grid_loc_y * 100;
        
        square_xs = [grid_square_x, grid_square_x + 100, grid_square_x + 100, grid_square_x];
        square_ys = [grid_square_y, grid_square_y, grid_square_y + 100, grid_square_y + 100];
    
        if treasure(grid_loc_y + 1, grid_loc_x + 1) >= 1
            score = score + treasure(grid_loc_y + 1, grid_loc_x + 1);
            fill(square_xs,square_ys,'yellow','FaceAlpha',0.3)
            image([(grid_loc_x)*100, (grid_loc_x+1)*100], [(grid_loc_y)*100, (grid_loc_y+1)*100], coin, 'AlphaData', coin_alpha*0.5)
            treasure(grid_loc_y + 1, grid_loc_x + 1) = -1;
            sprintf('Current Score: %d', score)
            score_text.String = "Score: " + score;
            turn_done = 1;
        elseif treasure(grid_loc_y + 1, grid_loc_x + 1) == 0
            fill(square_xs,square_ys,'black','FaceAlpha',0.3)
            treasure(grid_loc_y + 1, grid_loc_x + 1) = -1;
            sprintf('Current Score: %d', score)
            turn_done = 1;
        end
    end
    turns_remaining = no_attempts-i;
    turns_remaining_text.String = "Turns Remaining: " + turns_remaining;
    if turns_remaining <= 5
        turns_remaining_text.Color = 'r';
    end
end