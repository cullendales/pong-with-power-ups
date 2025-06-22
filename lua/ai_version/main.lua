ball = {}
ball.x = 333
ball.y = 260
ball.height = 20
ball.width = 20
ball.x_vel = 200
ball.y_vel = 100
ball.invisible = false
ball.invisible_timer = 0
count = 0
best_count = 0
current = 0
power_up_spawn = 0
power_up_interval = 12
ai_difficulty = 0.8
ai_reaction = 0.1
ai_update = 0
ai_y = 0
game_state = "start"
text_flash_timer = 0
menu_timer = 0

function love.load()
	left = {}
	left.x = 0
	left.y = 0
	left.width = 25
	left.height = 85
	ball.start_speed = 200
	ball.previous_speed = 200
    ball.previous_y_vel = 100
	
	right = {}
	right.x = 775
	right.y = 0
	right.width = 25
	right.height = 85

	powerup = {}
	powerup.right = {} 
	powerup.left = {}  
	powerup.duration = 12
	powerup.ball_effects = {} 
	powerups = {}
	power_types = {"bigger", "smaller", "big_ball", "fast_ball", "invisible_ball"}

	plyr1_score = 0
	plyr2_score = 0

	plyr1_wins = false
	plyr2_wins = false

	ai_y = left.y + left.height / 2

	overtime = false
end

function update_menu(dt)
	menu_timer = menu_timer + dt
	text_flash_timer = text_flash_timer + dt
	
	if love.keyboard.isDown("space") or love.keyboard.isDown("return") then
		game_state = "play"
	end
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
	local effect = {
		type = type,
		timer = powerup.duration
	}
	
	if type == "bigger" then
		if player == "left" then
			left.height = left.height * 1.5
			table.insert(powerup.left, effect)
		else
			right.height = right.height * 1.5
			table.insert(powerup.right, effect)
		end
	elseif type == "smaller" then
		if player == "left" then
			right.height = right.height * 0.6
			table.insert(powerup.left, effect)
		else
			left.height = left.height * 0.6
			table.insert(powerup.right, effect)
		end
	elseif type == "big_ball" then
		ball.height = 80
		ball.width = 80
		if player == "left" then
			table.insert(powerup.left, effect)
		else
			table.insert(powerup.right, effect)
		end
		table.insert(powerup.ball_effects, effect)
	elseif type == "fast_ball" then
		if player == "left" then
			table.insert(powerup.left, effect)
		else
			table.insert(powerup.right, effect)
		end
	elseif type == "invisible_ball" then
		if player == "left" then
			table.insert(powerup.left, effect)
		else
			table.insert(powerup.right, effect)
		end
	end
end

function has_power_up(player, power_type)
	local powerup_table = (player == "left") and powerup.left or powerup.right
	for _, effect in ipairs(powerup_table) do
		if effect.type == power_type then
			return true
		end
	end
	return false
end

function remove_power_up_effect(effect, player)
	if effect.type == "bigger" then
		if player == "left" then
			left.height = left.height / 1.5
		else
			right.height = right.height / 1.5
		end
	elseif effect.type == "smaller" then
		if player == "left" then
			right.height = right.height / 0.6
		else
			left.height = left.height / 0.6
		end
	elseif effect.type == "big_ball" then
		if #powerup.ball_effects <= 1 then
			ball.height = 20
			ball.width = 20
		end
	end
end

function ability_update(dt)
	if ball.invisible then
		ball.invisible_timer = ball.invisible_timer - dt
		if ball.invisible_timer <= 0 then
			ball.invisible = false
		end
	end

	for i = #powerup.right, 1, -1 do
		local effect = powerup.right[i]
		if effect.type ~= "fast_ball" and effect.type ~= "invisible_ball" then
			effect.timer = effect.timer - dt
			
			if effect.timer <= 0 then
				remove_power_up_effect(effect, "right")
				table.remove(powerup.right, i)
			end
		end
	end
	
	for i = #powerup.left, 1, -1 do
		local effect = powerup.left[i]
		if effect.type ~= "fast_ball" and effect.type ~= "invisible_ball" then
			effect.timer = effect.timer - dt
			
			if effect.timer <= 0 then
				remove_power_up_effect(effect, "left")
				table.remove(powerup.left, i)
			end
		end
	end

	for i = #powerup.ball_effects, 1, -1 do
		local effect = powerup.ball_effects[i]
		if effect.timer <= 0 then
			table.remove(powerup.ball_effects, i)
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

function update_ai(dt)
	ai_update = ai_update + dt

	if ai_update >= ai_reaction then
		ai_update = 0

		local ball_center_y = ball.y + ball.height / 2
		local paddle_center_y = left.y + left.height / 2
		
		if ball.x_vel < 0 then
			local time_to_paddle = (left.x - ball.x) / ball.x_vel
			if time_to_paddle > 0 then
				local predicted_y = ball.y + ball.y_vel * time_to_paddle
				local error_range = (1 - ai_difficulty) * 100
				local error = love.math.random(-error_range, error_range)
				
				ai_y = predicted_y + ball.height / 2 - left.height / 2 + error
			end
		else
			ai_y = 300 - left.height / 2
		end
		ai_y = math.max(0, math.min(600 - left.height, ai_y))
	end
	local paddle_center = left.y + left.height / 2
	local target_center = ai_y + left.height / 2
	local move_speed = 350 * ai_difficulty
	
	if paddle_center < target_center - 10 then
		left.y = left.y + move_speed * dt
	elseif paddle_center > target_center + 10 then
		left.y = left.y - move_speed * dt
	end
end

function love.update(dt)
	if game_state == "start" then
		update_menu(dt)
	elseif game_state == "play" then
		ability_update(dt)
		gain_power_up()		
		update_ai(dt)
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

		if plyr1_wins or plyr2_wins then
			if love.keyboard.isDown("y") then
				plyr1_score = 0
				plyr2_score = 0
				plyr1_wins = false
				plyr2_wins = false
				overtime = false
				ball.x_vel = 250
				ball.y_vel = 100
				reset_powerups()
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

			local speed
			if ball.speed_boosted then
				speed = ball.previous_speed 
				ball.speed_boosted = false
			else
				speed = math.sqrt(ball.x_vel^2 + ball.y_vel^2) + 20
				ball.previous_speed = speed
				ball.previous_y_vel = math.sin(angle) * speed
			end

			if has_power_up("right", "fast_ball") then
				speed = speed * 1.5
				ball.speed_boosted = true
				for i = #powerup.right, 1, -1 do
					if powerup.right[i].type == "fast_ball" then
						table.remove(powerup.right, i)
						break
					end
				end
			end

			ball.x_vel = -math.abs(math.cos(angle) * speed)
			ball.y_vel = math.sin(angle) * speed
			ball.x = ball.x - 10
			
			if has_power_up("right", "invisible_ball") then
				ball.invisible = true
				ball.invisible_timer = 0.3
				for i = #powerup.right, 1, -1 do
					if powerup.right[i].type == "invisible_ball" then
						table.remove(powerup.right, i)
						break
					end
				end
			end
		end
		
		if ball.x < left.x + left.width + 2.5 and ball.y <= left.y + left.height and ball.y >= left.y - ball.height then
			local hit_pos = (ball.y + ball.height/2 - left.y) / left.height
			hit_pos = math.max(0, math.min(1, hit_pos))
			local max_angle = math.pi / 3
			local angle = (hit_pos - 0.5) * 2 * max_angle

			local speed
			if ball.speed_boosted then
				speed = ball.previous_speed
				ball.speed_boosted = false
			else
				speed = math.sqrt(ball.x_vel^2 + ball.y_vel^2) + 20
				ball.previous_speed = speed
				ball.previous_y_vel = math.sin(angle) * speed
			end

			if has_power_up("left", "fast_ball") then
				speed = speed * 1.5
				ball.speed_boosted = true
				for i = #powerup.left, 1, -1 do
					if powerup.left[i].type == "fast_ball" then
						table.remove(powerup.left, i)
						break
					end
				end
			end

			ball.x_vel = math.abs(math.cos(angle) * speed)
			ball.y_vel = math.sin(angle) * speed
			ball.x = ball.x + 10
			count = count + 1
			
			if has_power_up("left", "invisible_ball") then
				ball.invisible = true
				ball.invisible_timer = 0.3
				for i = #powerup.left, 1, -1 do
					if powerup.left[i].type == "invisible_ball" then
						table.remove(powerup.left, i)
						break 
					end
				end
			end
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
end

function get_power_up_colour(type)
	if type == "bigger" then
		return {0, 1, 0} 
	elseif type == "smaller" then
		return {1, 0, 0}
	elseif type == "fast_ball" then
		return {1, 1, 0} 
	elseif type == "invisible_ball" then
		return {0.5, 0.5, 1} 
	else
		return {1, 1, 1} 
	end
end

function get_active_powerups(player)
	local active = {}
	local powerup_table = (player == "left") and powerup.left or powerup.right
	
	for _, effect in ipairs(powerup_table) do
		if not active[effect.type] then
			active[effect.type] = effect.type
		end
	end
	
	local result = {}
	for type_name, _ in pairs(active) do
		if type_name == "bigger" then
			table.insert(result, "Mega Paddle")
		elseif type_name == "smaller" then
			table.insert(result, "Shrunk")
		elseif type_name == "big_ball" then
			table.insert(result, "Super Ball")
		elseif type_name == "fast_ball" then
			table.insert(result, "Speed Shot")
		elseif type_name == "invisible_ball" then
			table.insert(result, "Ghost Shot")
		end
	end
	
	return table.concat(result, ", ")
end

function get_most_recent_powerup(player)
    local powerup_table = (player == "left") and powerup.left or powerup.right
    if #powerup_table > 0 then
        local latest = powerup_table[#powerup_table].type
        if latest == "bigger" then
            return "Mega Paddle"
        elseif latest == "smaller" then
            return "Shrunk"
        elseif latest == "big_ball" then
            return "Super Ball"
        elseif latest == "fast_ball" then
            return "Speed Shot"
        elseif latest == "invisible_ball" then
            return "Ghost Shot"
        else
            return "Unknown"
        end
    else
        return "none"
    end
end

function reset_powerups()
	left.height = 85
	right.height = 85
	ball.height = 20
	ball.width = 20
	ball.invisible = false
	ball.invisible_timer = 0
	ball.speed_boosted = false
	powerup.right = {}
	powerup.left = {}
	powerup.ball_effects = {}
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
		ball.x_vel = 225
		ball.y_vel = 100
	else
		ball.x_vel = -225
		ball.y_vel = 100
	end
end


function draw_menu()
	love.graphics.setColor(0.2, 0.2, 0.4, 0.5)
	local wave1 = math.sin(menu_timer * 2) * 50
	local wave2 = math.cos(menu_timer * 1.5) * 30
	
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.printf("Pong With Power-Ups!", 0, 150, 800, "center")
	
	if math.sin(text_flash_timer * 4) > 0 then
		love.graphics.setColor(1, 1, 0.5)
		love.graphics.printf("PRESS SPACE TO PLAY", 0, 300, 800, "center")
	end
	
	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.printf("Controls:", 0, 440, 800, "center")
	love.graphics.printf("Up & Down Arrow Keys", 0, 460, 800, "center")
end

function love.draw()
	if game_state == "start" then
		draw_menu()
	elseif game_state == "play" then
		love.graphics.rectangle("line", left.x, left.y, left.width, left.height)
		love.graphics.rectangle("line", right.x, right.y, right.width, right.height)

		if not ball.invisible then
			love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
		end
		
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
		
		local right_powerup = get_most_recent_powerup("right")
		local left_powerup = get_most_recent_powerup("left")

		love.graphics.print("Power Up: " .. right_powerup, 505, 10)
		love.graphics.print("Power Up: " .. left_powerup, 200, 10)

		if best_count > current then
			love.graphics.print("Best Rally: " .. best_count, 370, 25)
		end

		if overtime then
			love.graphics.print("OVERTIME!", 372, 40)
		end

		if plyr1_wins then
			love.graphics.print("GAME OVER", 345, 205)
			love.graphics.print("Play Again? [y]", 336, 225)
		elseif plyr2_wins then
			love.graphics.print("YOU WIN!", 345, 205)
			love.graphics.print("Play Again? [y]", 336, 225)
		end
	end
end