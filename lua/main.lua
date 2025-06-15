ball = {}
ball.x = 333
ball.y = 260
ball.height = 20
ball.width = 20
ball.x_vel = 250
ball.y_vel = 100
count = 0
best_count = 0
current = 0
power_up_spawn = 0
power_up_interval = 15


function love.load()
	game_state = "start"
	
	left = {}
	left.x = 0
	left.y = 0
	left.width = 25
	left.height = 85
	ball.start_speed = 250
	
	right = {}
	right.x = 775
	right.y = 0
	right.width = 25
	right.height = 85

	powerup = {}
	powerup.right = "none"
	powerup.left = "none"
	powerup.right_timer = 0
	powerup.left_timer = 0
	powerup.duration = 12
	powerup.ball_effect_player = "none"
	powerups = {}
	-- all future power ups
	--power_types = {"bigger", "smaller", "fast_ball", "curve_ball", "invisible", "fast_movement", "glue", "double_ball", "boomerang", "big_ball"}
	power_types = {"bigger", "smaller", "big_ball"}

	plyr1_score = 0
	plyr2_score = 0

	plyr1_wins = false
	plyr2_wins = false

	overtime = false

end

function spawn_power_up()
	local powerup_item = {}
	powerup_item.x = love.math.random(100, 700)
	powerup_item.y = love.math.random(50, 550) 
	powerup_item.width = 45
	powerup_item.height = 45
	powerup_item.type = power_types[love.math.random(1, #power_types)]
	powerup_item.lifetime = 12 
	
	table.insert(powerups, powerup_item)
end

function gain_power_up()
	for i = #powerups, 1, -1 do
		local p = powerups[i]
		if ball.x < p.x + p.width and ball.x + ball.width > p.x and ball.y < p.y + p.height and ball.y + ball.height > p.y then		
			if ball.x_vel > 0 then
				apply_power_up("left", p.type)
			else
				apply_power_up("right", p.type)
			end
			table.remove(powerups, i)
		end
	end
end

function apply_power_up(player, type)
	-- if player == "right" then
	-- 	powerup.right = type
	-- 	powerup.right_timer = powerup.duration
	-- else
	-- 	powerup.left = type
	-- 	powerup.left_timer = powerup.duration
	-- end

	if type == "bigger" then
		if player == "left" then
			left.height = left.height * 1.5
			powerup.left_timer = powerup.duration
        	powerup.left = "Mega Paddle"
		else
			right.height = right.height * 1.5
			powerup.right_timer = powerup.duration
        	powerup.right = "Mega Paddle"
		end
	elseif type == "smaller" then
		if player == "left" then
			right.height = right.height * 0.6
			powerup.left_timer = powerup.duration
        	powerup.left = "Shrunk"
		else
			left.height = left.height * 0.6
			powerup.right_timer = powerup.duration
        	powerup.right = "Shrunk"
		end
	elseif type == "big_ball" then
		ball.height = 80
		ball.width = 80
		powerup.ball_effect_player = player
		if player == "left" then
			powerup.left_timer = powerup.duration
			powerup.left = "Super Ball"
    	else
			powerup.right_timer = powerup.duration
			powerup.right = "Super Ball"
    	end
	end
end

-- power up ideas
	-- elseif type == "fast_ball" then -- maybe make for only collisions
	-- 	ball.x_vel = ball.x_vel * 2
	-- 	ball.y_vel = ball.y_vel * 2
	-- elseif type == "glue" then
	-- elseif type == "curve_ball" then
	-- elseif type == "invisible" then
	-- elseif type == "fast_movement" then
	-- elseif type == "double_ball" then
	-- elseif type == "boomerang" then


function ability_update(dt)
	if powerup.right_timer > 0 then
		powerup.right_timer = powerup.right_timer - dt
		if powerup.right_timer <= 0 then
			if powerup.right == "Mega Paddle" then
				right.height = 85
			elseif powerup.right == "Shrunk" then
				left.height = 85 
			end
			if powerup.ball_effect_player == "right" then
				ball.height = 20
				ball.width = 20
				powerup.ball_effect_player = "none"
			end
			powerup.right = "none"
		end
	end

	if powerup.left_timer > 0 then
		powerup.left_timer = powerup.left_timer - dt
		if powerup.left_timer <= 0 then
			if powerup.left == "Mega Paddle" then
				left.height = 85  
			elseif powerup.left == "Shrunk" then
				right.height = 85 
			end
			if powerup.ball_effect_player == "left" then
				ball.height = 20
				ball.width = 20
				powerup.ball_effect_player = "none"
			end
			powerup.left = "none"
		end
	end

	for i = #powerups, 1, -1 do
		powerups[i].lifetime = powerups[i].lifetime - dt
		if powerups[i].lifetime <= 0 then
			table.remove(powerups, i)
		end
	end

	power_up_spawn = power_up_spawn + dt
	if power_up_spawn >= power_up_interval then
		spawn_power_up()
		power_up_spawn = 0
	end
end


function love.update(dt)
	ability_update(dt)
	gain_power_up()		
	ball.x = ball.x + ball.x_vel * dt
	ball.y = ball.y + ball.y_vel * dt
	
	if ball.x > 780 then
		plyr1_score = plyr1_score + 1
		ball:reset()
	elseif ball.x < 0 then
		plyr2_score = plyr2_score + 1
		ball:reset()
	end
	
	if love.keyboard.isDown("down") then
		right.y = right.y + 350 * dt
	end
	if love.keyboard.isDown("up") then
		right.y = right.y - 350 * dt
	end
	if love.keyboard.isDown("s") then
		left.y = left.y + 350 * dt
	end
	if love.keyboard.isDown("w") then
		left.y = left.y - 350 * dt
	end
	
	if plyr1_wins or plyr2_wins then
		if love.keyboard.isDown("y") then
			plyr1_score = 0
			plyr2_score = 0
			plyr1_wins = false
			plyr2_wins = false
			overtime = false
			ball.x_vel = 250
			ball.y_vel = 100
			powerup.right = "none"
			powerup.left = "none"
			powerup.right_timer = 0
			powerup.left_timer = 0
			right.height = 85
			right.width = 25
			left.height = 85
			left.width = 25
			ball.height = 20
			ball.width = 20
			powerups = {}
		end
	end
	
	if right.y < 0 then
		right.y = 0
	end
	if right.y > 600 - right.height then
		right.y = 600 - right.height
	end
	if left.y < 0 then
		left.y = 0
	end
	if left.y > 600 - left.height then
		left.y = 600 - left.height
	end
	
	if ball.x > right.x - ball.width and ball.y <= right.y + right.height and ball.y >= right.y - ball.height then
		local hit_pos = (ball.y + ball.height/2 - right.y) / right.height
		hit_pos = math.max(0, math.min(1, hit_pos)) 
		local max_angle = math.pi / 3
		local angle = (hit_pos - 0.5) * 2 * max_angle		
		local speed = math.sqrt(ball.x_vel^2 + ball.y_vel^2) + 20
		ball.x_vel = -math.abs(math.cos(angle) * speed) 
		ball.y_vel = math.sin(angle) * speed		
		ball.x = ball.x - 10
		count = count + 1
	end
	
	if ball.x < left.x + left.width + 2.5 and ball.y <= left.y + left.height and ball.y >= left.y - ball.height then
		local hit_pos = (ball.y + ball.height/2 - left.y) / left.height
		hit_pos = math.max(0, math.min(1, hit_pos)) 
		local max_angle = math.pi / 3 
		local angle = (hit_pos - 0.5) * 2 * max_angle		
		local speed = math.sqrt(ball.x_vel^2 + ball.y_vel^2) + 20 
		ball.x_vel = math.abs(math.cos(angle) * speed) 
		ball.y_vel = math.sin(angle) * speed		
		ball.x = ball.x + 10
		count = count + 1
	end
	
	if ball.y <= 0 then
		ball.y_vel = math.abs(ball.y_vel) + love.math.random(-0.1, 0.1)
		ball.y = 1
	end
	if ball.y + ball.height >= 600 then
		ball.y_vel = -math.abs(ball.y_vel) + love.math.random(-0.1, 0.1)
		ball.y = 600 - ball.height
	end
	
	if count > best_count then
		best_count = count
	end
	
	if plyr1_score >= 5 and plyr2_score >= 4 or plyr2_score >= 5 and plyr1_score >= 4 then
		overtime = true
	end
	if plyr1_score >= 5 and plyr1_score > plyr2_score + 1 then
		plyr1_wins = true
		ball.x_vel = 0
		ball.y_vel = 0
	end
	if plyr2_score >= 5 and plyr2_score > plyr1_score + 1 then
		plyr2_wins = true
		ball.x_vel = 0
		ball.y_vel = 0
	end
end

function get_power_up_colour(type)
	if type == "bigger" then
		return {0, 1, 0} 
	elseif type == "smaller" then
		return {1, 0, 0}
	else
		return {1, 1, 1} 
	end
end

function reset_powerups()
	left.height = 85
	right.height = 85
	ball.height = 20
	ball.width = 20
	powerup.right = "none"
	powerup.left = "none"
	powerup.right_timer = 0
	powerup.left_timer = 0
	powerup.ball_effect_player = "none"
	powerups = {}
end

function ball:reset()
	if best_count > current then
		current = best_count
	end

	best_count = 0
	count = 0
	ball.x = 333
	ball.y = 260
	ball.height = 20
	ball.width = 20	
	reset_powerups()

	if plyr1_score > plyr2_score then
		ball.x_vel = 250
		ball.y_vel = 100
	else
		ball.x_vel = -250
		ball.y_vel = 100
	end
end

function love.draw()
	love.graphics.rectangle("line", left.x, left.y, left.width, left.height)
	love.graphics.rectangle("line", right.x, right.y, right.width, right.height)
	love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
	love.graphics.print(plyr1_score .. " - " .. plyr2_score, 385, 10)

	for _, p in ipairs(powerups) do
		love.graphics.setColor(get_power_up_colour(p.type))
		love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
		love.graphics.setColor(1, 1, 1)
	end
	if plyr1_score > plyr2_score then
		love.graphics.print("KING", 30, 10)
	elseif plyr2_score > plyr1_score then
		love.graphics.print("KING", 740, 10)
	end
	love.graphics.print("Power Up: " .. powerup.right, 500, 10)
	love.graphics.print("Power Up: " .. powerup.left, 215, 10)

	if best_count > current then
		love.graphics.print("Best Rally: " .. best_count, 370, 25)
	end

	if overtime then
		love.graphics.print("OVERTIME!", 372, 40)
	end

	if plyr1_wins then
		love.graphics.print("PLAYER 1 WINS!", 345, 205)
		love.graphics.print("Play Again? [y]", 345, 225)
	elseif plyr2_wins then
		love.graphics.print("PLAYER 2 WINS!", 345, 205)
		love.graphics.print("Play Again? [y]", 345, 225)
	end
end

