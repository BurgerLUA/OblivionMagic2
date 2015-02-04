include("shared.lua")
--include("init.lua")




function ENT:Initialize()
	self.TTick = -1
	self.EnableUp = false
	self.Radius = 10
	self.EnableDown = false
end

function ENT:Draw()

	if self:GetNWBool("enablesprite",false) == false then return end
	
	
	self:DrawModel()

	self.DamageType = self:GetNWString("damagetype", "fire")
	self.Damage = self:GetNWInt("damage")
	self.Duration = self:GetNWInt("duration")
	self.Radius = self:GetNWInt("radius")
	
	if self.DamageType == "fire" then
		self.SpriteColor = Color(255,150,0,255)
		self.SpriteSize = 64
		self.ExplosionMul = 1
	elseif self.DamageType == "frost" then
		self.SpriteColor = Color(100,255,255,255)
		self.SpriteSize = self.Radius*10
		self.ExplosionMul = 1
	elseif self.DamageType == "shock" then
		self.SpriteColor = Color(100,100,255,255)
		self.SpriteSize = 16
		self.ExplosionMul = 1
	elseif self.DamageType == "pure" then
		self.SpriteColor = Color(255,255,255,255)
		self.SpriteSize = 64
		self.ExplosionMul = 5
	elseif self.DamageType == "unlock" then
		self.SpriteColor = Color(255,255,0,255)
		self.SpriteSize = 24
		self.ExplosionMul = 1
	end


	cam.Start3D(EyePos(),EyeAngles())
		render.SetMaterial( Material("sprites/glow04_noz") )
		render.DrawSprite( self:GetPos(), self.SpriteSize, self.SpriteSize, self.SpriteColor)
	cam.End3D()
	
	if self:GetNWBool("enableexplosion",false) then
		cam.Start3D(EyePos(),EyeAngles())
		render.SetMaterial( Material("sprites/glow04_noz") )
		render.DrawSprite( self:GetPos(), self.Radius*self.ExplosionMul*self.TTick, self.Radius*self.ExplosionMul*self.TTick, self.SpriteColor)
		--print("Up")
		
		if self.TTick == -1 then 
			self.TTick = 0
			self.EnableUp = true
		end
		
		
		
		for i=1, 5 do 
			local Rand = VectorRand()*self.ExplosionMul*self.Radius
				render.DrawSprite( self:GetPos() + Rand, self.ExplosionMul*self.SpriteSize/2, self.ExplosionMul*self.SpriteSize/2, self.SpriteColor)
		end
		cam.End3D()
		
	end

end
	
	
	


function ENT:Think()





if self:GetNWBool("enableexplosion",false) == true then

	if self.EnableUp == true and self.TTick+4 <= self.Radius*2 then
		self.TTick = self.TTick+4
	elseif self.EnableUp == true and self.TTick >= self.Radius*2 then
		--print("down")
		self.EnableUp = false
		self.EnableDown = true
	end
		
	if self.EnableDown == true and self.TTick-1 >= 0 then
		self.TTick = self.TTick-1
	elseif self.EnableDown == true then
		--print("none")
		self.EnableDown = false
		self.EnableUp = false
		self.TTick = 0
	end
	
	--print(self.TTick)
end
	
end 