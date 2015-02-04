AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetNWBool("enablesprite",true)
	self.Collided = false
	self.FakeDieTime = 0
	self.TrailColor = Color(self.RColor,self.GColor,self.BColor,self.AColor)
	
	
	self:SetNWString("damagetype",self.DamageType)
	self:SetNWInt("damage",self.Damage)
	self:SetNWInt("duration",self.Duration)
	self:SetNWInt("radius",self.Radius)

	
	
	

	--[[
	--self.Method = "target"
	
	

	
	
	
	
	self.CollisionRadius = self:GetNWInt("collisionradius")
	--self.VelMul = self:GetNWFloat("radius")
	self.LoopSound = self:GetNWString("loopsound")
	self.RColor = self:GetNWInt("rcolor")
	self.GColor = self:GetNWInt("gcolor")
	self.BColor = self:GetNWInt("bcolor")
	self.AColor = self:GetNWInt("acolor")
	self.TrailLength = self:GetNWFloat("traillength")
	self.TrailWidthStart = self:GetNWFloat("trailwidthstart")
	self.TrailWidthEnd = self:GetNWFloat("traithwidthend")
	self.TrailTexture = self:GetNWString("trailtexture")
	self.Effect = self:GetNWString("effect")
	print(self.Effect)
	self.TravelDamage = self:GetNWBool("traveldamage")
	self.FranticEffect = self:GetNWBool("franticeffect")
	self.ExplosionEffect = self:GetNWBool("explosioneffect")
	--]]
	
	
	--print(self.TrailWidthStart)
	
	
	
	
	self:SetMaterial("Models/effects/vol_light001")
    self:SetModel("models/weapons/v_models/v_baseball.mdl")
	
	local r = self.CollisionRadius
	
	
    self:PhysicsInitSphere(r)
    self:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))

	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		phys:SetBuoyancyRatio(0)
	end
	
	self.LoopSoundFinal = CreateSound(self.Entity, self.LoopSound )
	
	self.LoopSoundFinal:Play()
	
	self.TrailRes = 1/(self.TrailWidthStart+self.TrailWidthEnd)*0.5
	
	ParticleEffectAttach(self.Effect,PATTACH_ABSORIGIN_FOLLOW,self.Entity,0)
	util.SpriteTrail(self.Entity, 0, self.TrailColor, false, self.TrailWidthStart, self.TrailWidthEnd, self.TrailLength, self.TrailRes, self.TrailTexture)
	
	self.SpawnTime = CurTime()
	
	if self.FranticEffect then
		local enttarget1 = ents.Create("info_target")
			enttarget1:SetParent(self)
			enttarget1:SetPos(self:GetPos() + Vector(0,0,10))
			enttarget1:Spawn()
			
		local enttarget2 = ents.Create("info_target")
			enttarget2:SetParent(self)
			enttarget2:SetPos(self:GetPos() + Vector(-10,0,-10))
			enttarget2:Spawn()
		local enttarget3 = ents.Create("info_target")
			enttarget3:SetParent(self)
			enttarget3:SetPos(self:GetPos() + Vector(10,0,-10))
			enttarget3:Spawn()
			
		--print("k dude")
		util.SpriteTrail(enttarget1, 0, self.TrailColor, false, self.TrailWidthStart, self.TrailWidthEnd, self.TrailLength, self.TrailRes, self.TrailTexture)
		util.SpriteTrail(enttarget2, 0, self.TrailColor, false, self.TrailWidthStart, self.TrailWidthEnd, self.TrailLength, self.TrailRes, self.TrailTexture)
		util.SpriteTrail(enttarget3, 0, self.TrailColor, false, self.TrailWidthStart, self.TrailWidthEnd, self.TrailLength, self.TrailRes, self.TrailTexture)
		
	end
	
	
	
	
end



function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	return false
end 


function ENT:PhysicsCollide(data, physobj)

	self.Collided = true
	
	self:GetPhysicsObject():EnableCollisions(false)
	
	
	self.LoopSoundFinal:Stop()

	self.EnableUltraEffects = false
	
	self.FakeDieTime = CurTime() + 1
	
	if data.HitEntity:GetClass() == "ent_bur_magic_base" and self.EnableUltraEffects == true then
		oe = data.HitEntity
		
		if oe:GetNWFloat("creation") > self:GetNWFloat("creation") then
			self:Remove()
		return end
		
		self.NewRadius = oe:GetNWInt("radius") + self:GetNWInt("radius")
		self.NewDamage = oe:GetNWInt("damage") + self:GetNWInt("damage")
		self.NewDuration = oe:GetNWInt("duration") + self:GetNWInt("duration")
		
		--if oe.Creation > self.Creation then
		--	self:Remove()
		--return end
		
		oe:Remove()
		
		--self.NewRadius = self.Radius + oe.Radius
		--self.NewDamage = self.Damage + oe.Damage
		--self.NewDuration = self.Duration + self.Duration

		if self.DamageType == "fire" and oe.DamageType == "fire" then
			self.NewDamageType = "nuke"
		elseif self.DamageType == "fire" and oe.DamageType == "frost" then
			self.NewDamageType = "rain"
		elseif self.DamageType == "fire" and oe.DamageType == "shock" then
			self.NewDamageType = "firestorm"
		elseif self.DamageType == "fire" and oe.DamageType == "pure" then
			self.NewDamageType = "firenova"
		
		elseif self.DamageType == "frost" and oe.DamageType == "fire" then
			self.NewDamageType = "rain"
		elseif self.DamageType == "frost" and oe.DamageType == "frost" then
			self.NewDamageType = "ice"
		elseif self.DamageType == "frost" and oe.DamageType == "shock" then
			self.NewDamageType = "blizzard"
		elseif self.DamageType == "frost" and oe.DamageType == "pure" then
			self.NewDamageType = "zero"
		
		elseif self.DamageType == "shock" and oe.DamageType == "fire" then
			self.NewDamageType = "firestorm"
		elseif self.DamageType == "shock" and oe.DamageType == "frost" then
			self.NewDamageType = "blizzard"
		elseif self.DamageType == "shock" and oe.DamageType == "shock" then
			self.NewDamageType = "overcharge"
		elseif self.DamageType == "shock" and oe.DamageType == "pure" then
			self.NewDamageType = "blackhole"
		
		elseif self.DamageType == "pure" and oe.DamageType == "fire" then
			self.NewDamageType = "firenova"
		elseif self.DamageType == "pure" and oe.DamageType == "frost" then
			self.NewDamageType = "zero"
		elseif self.DamageType == "pure" and oe.DamageType == "shock" then
			self.NewDamageType = "blackhole"
		elseif self.DamageType == "pure" and oe.DamageType == "pure" then
			self.NewDamageType = "plauge"
		end

		
		local nova = ents.Create("ent_bur_magic_super")
			nova:SetPos(self.GetPos())
			nova:SetAngles(self.GetAngles())
			nova:SetOwner(self.Owner)
			nova:SetNWString("damagetype",self.NewDamageType)
			nova:SetNWInt("damage",self.NewDamage)
			nova:SetNWInt("duration",self.NewDuration)
			nova:SetNWInt("radius",self.NewRadius)
			nova:Spawn();	
			
			
		local phys = ent:GetPhysicsObject();
			if IsValid(phys) then
				phys:SetVelocity(OurOldVelocity)
				phys:AddAngleVelocity(Vector(0,0,-1000))
			end
			
			self:Remove()

	return end
	
	
	
	
	
	
	
--DAMAGE PORTION--



	
	--ParticleEffect(self.Effect,data.HitPos,Angle(0,0,0),self)
	
	
	
	if self.DamageType == "fire" then
		self:EmitSound("fx/spl/spl_fireball_hit.wav")
		ApplyDamage(self,data.HitEntity)
	elseif self.DamageType == "frost" then
		self:EmitSound("fx/spl/spl_frost_hit.wav")
		ApplyDamage(self,data.HitEntity)
	elseif self.DamageType == "shock" then
		self:EmitSound("fx/spl/spl_shock_hit.wav")
		ApplyDamage(self,data.HitEntity)
	elseif self.DamageType == "unlock" then
		self:EmitSound("fx/spl/spl_alteration_hit.wav")
		Unlock(data.HitEntity)
	else
		self:EmitSound("fx/spl/spl_destruction_hit.wav")
		ApplyDamage(self,data.HitEntity)
	end
	
	
	
	
	if self.ExplosionEffect == true then
		self:SetNWBool("enableexplosion",true)
	end
	
	
	
	
	
	self:GetPhysicsObject():EnableMotion(false)
	
		timer.Simple(self.Duration*2, function()
			if not self:IsValid() then return end
			self.Entity:Remove()
		end)
end


function ENT:Think()

	
	if self.TravelDamage then 
		ApplyDamage(self,nil)
	end
	
	
	
	if self.Collided == true and self.FakeDieTime <= CurTime() then
		self:StopParticles( )
		self:DrawShadow(false)
		self:SetNWBool("enablesprite",false)
	end
	
	
	
	--self.FranticEffect = false
	

end


function ApplyDamage(self,ent)

	if self.EnableDamage == false then return end

	if ent ~= nil then
		--print("takedamage")
		local v = ent
		if v:Health() <= 0 then return end
		if v:GetNWBool( self:EntIndex() .. self.SpawnTime .. "damage", true) then
			if self.Duration >= 2 then 
				DamageOverTime(self,v,CurTime())
			else
				v:TakeDamage( self.Damage, self.Owner, self.Entity )
			end
			
			v:SetNWBool( self:EntIndex() .. self.SpawnTime .. "damage", false)
		end
		
	else
		if table.Count(ents.FindInSphere(self:GetPos(),self.Radius)) == 0 then return end
		for k,v in pairs(ents.FindInSphere(self:GetPos(),self.Radius)) do
		
			if v:Health() <= 0 then return end
			if v == self.Owner then return end

			if v:GetNWBool( self:EntIndex() .. self.SpawnTime .. "damage", true) then
				if self.Duration >= 2 then 
					DamageOverTime(self,v,CurTime())
				else
					v:TakeDamage( self.Damage, self.Owner, self.Entity )
				end
				v:SetNWBool( self:EntIndex() .. self.SpawnTime .. "damage", false)
			else
				--print("immunity")
			end
		end
	end

end


function DamageOverTime(self,victim,time)
	timer.Create(self:EntIndex() .. time .. "dottick", 0.25, self.Duration*4,function() 
		if self.Damage == nil then timer.Destroy(self:EntIndex() .. time .. "dottick") return end
		if victim:IsPlayer() then
			if victim:Alive() == false then timer.Destroy(self:EntIndex() .. time .. "dottick") end
		end
		if victim:IsValid() then
			if victim:Health() <= 0 then return end
			victim:TakeDamage( self.Damage/4, self.Owner, self.Entity )
		end
	end)
end

function Unlock(ent)
	if ent:GetClass() == "prop_door_rotating" then
		ent:Fire("unlock")
	end
	
end



