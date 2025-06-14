ball = {}
ball.x = 333
ball.y = 260
ball.height = 20
ball.width = 20
ball.x_vel = 300
ball.y_vel = 100
count = 0
best_count = 0
current = 0

function love.load()
	left = {}
	left.x = 0
	left.y = 0
	left.width = 25
	left.height = 85
	
	right = {}
	right.x = 775
	right.y = 0
	right.width = 25
	right.height = 85

	powerup = {}
	powerup.right = "none"
	powerup.left = "none"

	plyr1_score = 0
	plyr2_score = 0

	plyr1_wins = false
	plyr2_wins = false

	overtime = false

end

function love.update(dt)		
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
			ball.x_vel = 400
			ball.y_vel = 100
			powerup.right_timer = 0
			powerup.left_timer = 0
			right.height = right.original_height
			right.width = right.original_width
			left.height = left.original_height
			left.width = left.original_width
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
	if ball.y >= 580 then
		ball.y_vel = -math.abs(ball.y_vel) + love.math.random(-0.1, 0.1)
		ball.y = 579
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

function ball:reset()
	if best_count > current then
		current = best_count
	end

	best_count = 0
	count = 0
	ball.x = 333
	ball.y = 260
	if plyr1_score > plyr2_score then
		ball.x_vel = 300
		ball.y_vel = 100
	else
		ball.x_vel = -300
		ball.y_vel = 100
	end
end

function love.draw()
	love.graphics.rectangle("line", left.x, left.y, left.width, left.height)
	love.graphics.rectangle("line", right.x, right.y, right.width, right.height)
	love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
	love.graphics.print(plyr1_score .. " - " .. plyr2_score, 385, 10)
	
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
		love.graphics.print("Play Again? [y/n]", 345, 225)
	elseif plyr2_wins then
		love.graphics.print("PLAYER 2 WINS!", 345, 205)
		love.graphics.print("Play Again? [y/n]", 345, 225)
	end
end

