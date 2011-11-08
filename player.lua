Player = {}
Player.__index = Player

function Player.create(x,y)
	local self = {}
	setmetatable(self,Player)

	self.x = x
	self.y = y
	self.rot = 0
	self.dir = 1 -- 1 = left, -1 = right
	self.walking = false
	self.jumping = 0
	self.yspeed = 0
	self.frame = 0
	self.weapon = 0 -- gun

	return self
end

function Player:update(dt)
	self.rot = math.atan2(my-self.y-6, mx-self.x+2)

	self.walking = false
	if love.keyboard.isDown("a") then
		self.x = self.x - PLAYER_SPEED*dt
		self.walking = true
		self.dir = 1
	end
	if love.keyboard.isDown("d") then
		self.x = self.x + PLAYER_SPEED*dt
		self.walking = true
		self.dir = -1
	end

	if self.walking == true then
		self.frame = (self.frame+dt*12)%6
	else
		self.frame = 5
	end

	local newy,oldy
	newy, oldy = self.y+self.yspeed*dt, self.y

	-- check collision with ground
	self.y = newy
	if self:collidePlatforms() then
		if self.yspeed > 0 then
			self.y = oldy
			if self:collidePlatforms() == false then
				self.yspeed = self.yspeed/2
				self.jumping = 0
			else
				self.y = newy
				self.yspeed = self.yspeed + GRAVITY*dt
			end
		end
	end

	self.yspeed = self.yspeed + GRAVITY*dt
end

function Player:collidePlatforms()
	for i,v in ipairs(platforms) do
		if self:collidePlatform(v) then
			return true
		end
	end
	return false
end

function Player:collidePlatform(p)
	if self.x > p.x+p.w
	or self.x+6 < p.x
	or self.y > p.y+p.h
	or self.y+13 < p.y then
		return false
	end
	return true
end

function Player:draw()
	if self.dir == 1 then
		if self.walking then
			love.graphics.drawq(tiles,quadPlayer[math.floor(self.frame)+1],self.x,self.y)
		else
			love.graphics.drawq(tiles,quadPlayer[0],self.x,self.y)
		end
		love.graphics.drawq(tiles,quadWeapon[self.weapon],self.x+3,self.y+6,self.rot+math.pi,1,1,6,2.5)
	else 
		if self.walking then
			love.graphics.drawq(tiles,quadPlayer[math.floor(self.frame)+1],self.x+5,self.y,0,-1,1)
		else
			love.graphics.drawq(tiles,quadPlayer[0],self.x+5,self.y,0,-1,1)
		end
		love.graphics.drawq(tiles,quadWeapon[self.weapon],self.x+3,self.y+6,self.rot,-1,1,6,2.5)
	end
end

function Player:shoot()
	if self.weapon == 0 then -- gun
		table.insert(bullets,Bullet.create(self.x+2,self.y+5.5,self.rot))
	elseif self.weapon == 1 then -- shotgun
		table.insert(bullets,Bullet.create(self.x+2,self.y+6,self.rot+(math.random()-0.5)/4))
		table.insert(bullets,Bullet.create(self.x+2,self.y+6,self.rot+(math.random()-0.5)/4))
		table.insert(bullets,Bullet.create(self.x+2,self.y+6,self.rot+(math.random()-0.5)/4))
	elseif self.weapon == 2 then -- bazooka
		-- TODO: Create rocket }[]==>
	end
end

function Player:keypressed(k,unicode)
	if k == "w" and self.jumping < 2 then
		self.yspeed = -JUMP_POWER
		self.jumping = self.jumping + 1
	end
end

function Player:mousepressed(button)
	if button == 'l' then
		self:shoot()
	elseif button == 'wu' then
		self.weapon = (self.weapon+1)%3
	elseif button == 'wd' then
		self.weapon = (self.weapon-1)%3
	end
end
