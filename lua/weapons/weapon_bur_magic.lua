SWEP.PrintName 				= "Oblivion Magic"
SWEP.Author 				= "Burger" 
SWEP.Contact 				= "" 
SWEP.Category 				= "TES: Oblivion"
SWEP.Instructions 			= ""
SWEP.Purpose 				= ""

SWEP.Base 					= "weapon_base"	
SWEP.ViewModel 				= "models/weapons/c_arms_citizen.mdl" 
SWEP.WorldModel 			= ""
SWEP.HoldType 				= "normal" 
SWEP.ViewModelFlip 			= true
SWEP.UseHands				= false	

SWEP.Spawnable 				= true 
SWEP.AdminSpawnable 		= true                   			

SWEP.DrawCrosshair 			= rrue                          		
SWEP.DrawAmmo 				= true                                
                                	
SWEP.SlotPos 				= 0                                    	
SWEP.Slot 					= 1                                     

SWEP.Primary.Ammo         	= "HelicopterGun"
SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic   	= true					

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.CanSwitch 				= true
SWEP.WeaponSlot 			= 1
SWEP.DamageType 			= "fire"
SWEP.Damage 				= 0
SWEP.Duration 				= 3
SWEP.Radius 				= 0
SWEP.VelMul 				= 0
SWEP.Text 					= "yeah"
SWEP.RegenTime 				= 0
SWEP.NextChangeTime 		= 0
SWEP.Cost 					= 25
SWEP.Method 				= "target"


if CLIENT then

	language.Add("HelicopterGun_ammo","Mana")

	killicon.Add("ent_bur_magic_base", "vgui/hand", Color(255,255,255,255) )

	surface.CreateFont( "Oblivion", {
	font = "oblivion-font",
	size = 32,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
	} )
	
end


function SWEP:Deploy()

	self:UpdateSpell()
	self:SetUpSpells()

	return true
	
end

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + 2 )
	
	self:EmitEffects()
	
	if self.Cost <= self:Clip1() then
	
		self.RegenTime = CurTime() + 2.25
		self.NextChangeTime = CurTime() + 1.05
		
		timer.Simple(1, function()
		
			--self:UpdateSpell()
			
			if SERVER then
			
				self.Weapon:TakePrimaryAmmo(self.Cost)
				self.CastWhen = CurTime()
				
				if self.Method == "target" then
					self:SpellTarget()
				elseif self.Method == "touch" then
					self:SpellTouch()
				elseif self.Method == "self" then
					self:SpellSelf()
				end
				
			end	
			
			
			
		end)
		
	end
end

function SWEP:Think()

	self:RegenThink()
	self:CheckInputs()
	self:UpdateSpell()
	self:SetUpSpells()
	
	self:HealThink()
	self:ShieldThink()
	self:ConjureThink()
	

end

function SWEP:RegenThink()

	if SERVER then
		if self.RegenTime == nil then return end
		if self.RegenTime > CurTime() then return end
		
		if self.Weapon:Clip1() < 100 then
			self.RegenTime = CurTime() + 0.12
			self.Weapon:SetClip1(self.Weapon:Clip1()+1)
		end
	end

end


function SWEP:CheckInputs()

	if self.NextChangeTime >= CurTime() then return end


	if CLIENT then
		if self.Owner:KeyDown( IN_ATTACK2 ) then
			if self.Owner:KeyDown( IN_FORWARD ) and self.Owner:KeyDown( IN_MOVELEFT ) then
			
				self:SendSpellToServer(8)

			elseif self.Owner:KeyDown( IN_FORWARD ) and self.Owner:KeyDown( IN_MOVERIGHT ) then
			
				self:SendSpellToServer(2)

			elseif self.Owner:KeyDown( IN_BACK ) and self.Owner:KeyDown( IN_MOVELEFT ) then

				self:SendSpellToServer(6)

			elseif self.Owner:KeyDown( IN_BACK ) and self.Owner:KeyDown( IN_MOVERIGHT ) then
			
				self:SendSpellToServer(4)

			elseif self.Owner:KeyDown( IN_FORWARD ) then

				self:SendSpellToServer(1)

			elseif self.Owner:KeyDown( IN_MOVELEFT ) then

				self:SendSpellToServer(7)

			elseif self.Owner:KeyDown( IN_MOVERIGHT ) then

				self:SendSpellToServer(3)

			elseif self.Owner:KeyDown( IN_BACK ) then

				self:SendSpellToServer(5)
			
			end
		end
	end

end

if SERVER then
	util.AddNetworkString( "CLTOSV_Spells" )
	util.AddNetworkString( "SVTOCL_Spells" )
end


function SWEP:SendSpellToServer(spell)
	
	self.WeaponSlot = spell

	net.Start("CLTOSV_Spells")
		net.WriteFloat(spell)
	net.SendToServer()
	
end

if SERVER then

	net.Receive("CLTOSV_Spells", function(len,ply)

		local spell = net.ReadFloat()
	
		if IsValid(ply:GetActiveWeapon()) then
		
			if ply:GetActiveWeapon():GetClass() == "weapon_bur_magic" then
	
				ply:GetActiveWeapon().WeaponSlot = spell
				
			end
			
		end

	end)


end








function SWEP:DrawHUD()
	local BaseX = ScrW()*0.25
	local BaseY = ScrH()*0.90
	local BaseTrig = 1
	local ConVert = math.pi/180
	local Size = 64
	--local Icon = self:GetNWString("damagetype","nil")
	local Icon = self.DamageType
	local HelpText = self.Text or "ass"
	local HelpText2 = self.Text2 or "titties"
	--local HelpText = self:GetNWString("helptext","gg noob")
	
	if CanSwitch == true then
		helper = 255
	else
		helper = 0
	end
	
	if Icon == nil then return end
	if HelpText == nil then return end
	if HelpText2 == nil then return end
	
	surface.SetMaterial( Material("vgui/crosshairs/crosshair3") )
	surface.SetDrawColor(255,200,helper,1)
	surface.DrawTexturedRectRotated(ScrW()/2,ScrH()/2,64,64,0)
	
	surface.SetMaterial( Material("vgui/crosshairs/crosshair6") )
	surface.SetDrawColor(255,200,helper,1)
	surface.DrawTexturedRectRotated(ScrW()/2,ScrH()/2,64,64,0)

	surface.SetMaterial( Material("ob_icons/"..Icon..".png") )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRectRotated(BaseX,BaseY,Size,Size,0)
	
	surface.SetFont( "Oblivion" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( BaseX + Size/2 + 5 , BaseY - Size/2 ) 
	surface.DrawText( HelpText )
	
	surface.SetFont( "Oblivion" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( BaseX + Size/2 + 5, BaseY ) 
	surface.DrawText( HelpText2 )
	
end

function SWEP:UpdateSpell()

	if CLIENT then
	
		self.Text = self.DamageType .. " " .. self.Damage .. "pts "
			
		if self.Radius >= 2 then
			self.Text = self.Text .. "in " .. self.Radius .. "ft "
		end
			
		if self.Duration >= 2 then
			self.Text = self.Text .. "for " .. self.Duration .. "sec "
		end
			
		self.Text = self.Text .. "on " .. self.Method
		self.Text2 = self.Cost .. " mana"
		
	end
	
end

function SWEP:SpellTarget()

	if SERVER then
		local ent = ents.Create ("ent_bur_magic_base");	
			ent:SetPos(self.Owner:GetShootPos() - Vector(0,0,5))
			ent:SetAngles(self.Owner:EyeAngles())
			ent:SetOwner(self.Owner)	
			ent.Cost = self.Cost
			ent.Method = self.Method
			ent.DamageType = self.DamageType
			ent.Damage = self.Damage
			ent.Duration = self.Duration
			ent.Radius = self.Radius
			ent.CollisionRadius = self.CollisionRadius
			ent.VelMul = self.VelMul
			ent.LoopSound = self.LoopSound
			ent.RColor= self.RColor
			ent.GColor = self.GColor
			ent.BColor = self.BColor
			ent.AColor = self.AColor
			ent.TrailLength = self.TrailLength
			ent.TrailWidthStart = self.TrailWidthStart
			ent.TrailWidthEnd = self.TrailWidthEnd
			ent.TrailTexture = self.TrailTexture
			ent.Effect = self.Effect
			ent.TravelDamage = self.TravelDamage
			ent.FranticEffect = self.FranticEffect
			ent.ExplosionEffect = self.ExplosionEffect						
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:SetVelocity((self.Owner:EyeAngles():Forward() * 800 * self.VelMul))
			phys:AddAngleVelocity(Vector(20000,20000,20000))
		end
		
	end
	
end


function SWEP:SpellSelf()

	if self.DamageType == "heal" then
		self:SpellHeal()
	elseif self.DamageType == "armor" then
		self:SpellShield()
	elseif self.DamageType == "conjure" then
		self:SpellConjure()
	end
	
end

SWEP.HealValue = 0
SWEP.HealDuration = 0
SWEP.NextHealTick = 0


SWEP.ShieldValue = 0
SWEP.ShieldDuration = 0

SWEP.MinionDuration = 0


function SWEP:SpellHeal()

	self.HealValue = self.Damage
	self.HealDuration = self.Duration + CurTime()
	
end

function SWEP:HealThink()

	if CLIENT then return end

	if not IsValid(self.Owner) then
		return 
	elseif not self.Owner:Alive() then
		return
	end

	
	
	if self.HealDuration >= CurTime() then
	
		if self.NextHealTick <= CurTime() then
		
			local tick = 1
		
			self.Owner:SetHealth(math.Clamp(self.Owner:Health() + self.HealValue*tick,0,self.Owner:GetMaxHealth()))
			
			self.NextHealTick = CurTime() + tick
			
		end

	end

end

function SWEP:SpellConjure()

	self.MinionHealth = self.Damage
	self.MinionDuration = self.Duration + CurTime()
	
	
	for k,v in pairs(ents.FindByClass("npc_fastzombie")) do
		if v:GetOwner() == self.Owner then v:Remove() end
	end
				
	local minion = ents.Create("npc_fastzombie")
		minion:SetPos(self.Owner:GetPos() + self.Owner:GetForward()*50)
		minion:SetAngles(self.Owner:GetAngles())
		minion:SetOwner(self.Owner)
		minion:AddEntityRelationship(self.Owner, D_LI, 99 )
		minion:Spawn()
		minion:SetHealth(self.MinionHealth)
		minion:SetLastPosition( self.Owner:GetEyeTrace().HitPos + Vector(0,0,25) )
		minion:SetSchedule( SCHED_FORCED_GO_RUN )
	
end

function SWEP:ConjureThink()

	if CLIENT then return end

	if not IsValid(self.Owner) then
		minion:Remove()
		return 
	elseif not self.Owner:Alive() then
		minion:Remove()
		return
	end

	if self.MinionDuration <= CurTime() then
		if IsValid(minion) then 
			minion:Remove()
		end
	end

end

function SWEP:SpellShield()
	
	self.ShieldValue = self.Damage
	self.ShieldDuration = CurTime() + self.Duration
	
end

function SWEP:ShieldThink()

	if CLIENT then return end

	if not IsValid(self.Owner) then
		return 
	elseif not self.Owner:Alive() then
		return
	end


	if self.ShieldDuration >= CurTime() then
	
		self.Owner:SetArmor(self.ShieldValue)

	else
	
		self.Owner:SetArmor(0)
		
	end

end

function SWEP:SetUpSpells()

	if self.WeaponSlot == 1 then -- W Top Offensive
		self.Cost = 14
		self.Method = "target"
		self.DamageType = "fire"
		self.Damage = 8
		self.Duration = 5
		self.Radius = 10
		self.CollisionRadius = 2
		self.VelMul = 0.9
		self.LoopSound = "fx/spl/spl_fireball_travel_lp.wav"
		self.RColor = 255
		self.GColor = 200
		self.BColor = 0
		self.AColor = 255
		self.TrailLength = 0.25
		self.TrailWidthStart = 50
		self.TrailWidthEnd = 1
		self.TrailTexture = "trails/laser.vmt"
		self.Effect = "sentry_rocket_fire"
		self.TravelDamage = false
		self.FranticEffect = false
		self.ExplosionEffect = true
	elseif self.WeaponSlot == 2 then -- WD Top Right Offensive
		self.Cost = 5
		self.Method = "target"
		self.DamageType = "frost"
		self.Damage = 5
		self.Duration = 5
		self.Radius = 25
		self.CollisionRadius = 5
		self.VelMul = 0.5
		self.LoopSound = "fx/spl/spl_frost_travel_lp.wav"
		self.RColor = 0
		self.GColor = 255
		self.BColor = 255
		self.AColor = 255
		self.TrailLength = 0.5
		self.TrailWidthStart = 100
		self.TrailWidthEnd = 0
		self.TrailTexture = "trails/laser.vmt"
		self.Effect = "critical_rocket_blue"
		self.TravelDamage = true
		self.FranticEffect = false
		self.ExplosionEffect = false
	elseif self.WeaponSlot == 3 then -- D Right Blink
		self.Cost = 60
		self.Method = "target"
		self.DamageType = "unlock"
		self.Damage = 100
		self.Duration = 1
		self.Radius = 0
		self.CollisionRadius = 1
		self.VelMul = 1
		self.LoopSound = "fx/spl/spl_alteration_travel_lp.wav"
		self.RColor = 255
		self.GColor = 255
		self.BColor = 0
		self.AColor = 255
		self.TrailLength = 0.1
		self.TrailWidthStart = 10
		self.TrailWidthEnd = 1
		self.TrailTexture = "trails/laser.vmt"
		self.Effect = "community_sparkle"
		self.TravelDamage = false
		self.FranticEffect = false
		self.ExplosionEffect = true
	elseif self.WeaponSlot == 4 then -- SD Bottom Right Defensive
		self.Cost = 17
		self.Method = "self"
		self.DamageType = "conjure"
		self.Damage = 100
		self.Duration = 30
		self.Radius = 0
		self.CollisionRadius = nil
		self.VelMul = nil
		self.LoopSound = nil
		self.RColor = nil
		self.GColor = nil
		self.BColor = nil
		self.AColor = nil
		self.TrailLength = nil
		self.TrailWidthStart = nil
		self.TrailWidthEnd = nil
		self.TrailTexture = nil
		self.Effect = nil
		self.TravelDamage = nil
		self.FranticEffect = nil
		self.ExplosionEffect = nil
	elseif self.WeaponSlot == 5 then -- S Bottom Heal
		self.Cost = 20
		self.Method = "self"
		self.DamageType = "heal"
		self.Damage = 2
		self.Duration = 5
		self.Radius = 0
		self.CollisionRadius = nil
		self.VelMul = nil
		self.LoopSound = nil
		self.RColor = nil
		self.GColor = nil
		self.BColor = nil
		self.AColor = nil
		self.TrailLength = nil
		self.TrailWidthStart = nil
		self.TrailWidthEnd = nil
		self.TrailTexture = nil
		self.Effect = nil
		self.TravelDamage = nil
		self.FranticEffect = nil
		self.ExplosionEffect = nil
	elseif self.WeaponSlot == 6 then -- SA Bottom Left Defensive
		self.Cost = 50
		self.Method = "self"
		self.DamageType = "armor"
		self.Damage = 100
		self.Duration = 15
		self.Radius = 0
		self.CollisionRadius = nil
		self.VelMul = nil
		self.LoopSound = nil
		self.RColor = nil
		self.GColor = nil
		self.BColor = nil
		self.AColor = nil
		self.TrailLength = nil
		self.TrailWidthStart = nil
		self.TrailWidthEnd = nil
		self.TrailTexture = nil
		self.Effect = nil
		self.TravelDamage = nil
		self.FranticEffect = nil
		self.ExplosionEffect = nil
	elseif self.WeaponSlot == 7 then -- A Left Dash
		self.Cost = 80
		self.Method = "target"
		self.DamageType = "pure"
		self.Damage = 100
		self.Duration = 1
		self.Radius = 1
		self.CollisionRadius = 5
		self.VelMul = 0.25
		self.LoopSound = "fx/spl/spl_destruction_travel_lp.wav"
		self.RColor = 255
		self.GColor = 255
		self.BColor = 255
		self.AColor = 255
		self.TrailLength = 0.5
		self.TrailWidthStart = 32
		self.TrailWidthEnd = 1
		self.TrailTexture = "trails/laser.vmt"
		self.Effect = "critical_rocket_red"
		self.TravelDamage = false
		self.FranticEffect = false
		self.ExplosionEffect = true
	elseif self.WeaponSlot == 8 then -- WA Top Left Offensive
		self.Cost = 15
		self.Method = "target"
		self.DamageType = "shock"
		self.Damage = 50
		self.Duration = 1
		self.Radius = 1
		self.CollisionRadius = 1
		self.VelMul = 2
		self.LoopSound = "fx/spl/spl_shock_travel_lp.wav"
		self.RColor = 255
		self.GColor = 255
		self.BColor = 255
		self.AColor = 255
		self.TrailLength = 1
		self.TrailWidthStart = 5
		self.TrailWidthEnd = 5
		self.TrailTexture = "trails/electric.vmt"
		self.Effect = "critical_rocket_blue"
		self.TravelDamage = false
		self.FranticEffect = true
		self.ExplosionEffect = true
	end
end

function SWEP:EmitEffects()

	if self.Cost >= self.Weapon:Clip1() then
		self:EmitSound("fx/spl/fail/spl_destruction_fail.wav",500,100)
	return end
	
	if self.DamageType == "fire" then
		self.CastSound = "fx/spl/spl_fireball_cast.wav"
	elseif self.DamageType == "frost" then
		self.CastSound = "fx/spl/spl_frost_cast.wav"
	elseif self.DamageType == "shock" then
		self.CastSound = "fx/spl/spl_shock_cast.wav"
	elseif self.DamageType == "heal" then
		self.CastSound = "fx/spl/spl_restoration_cast.wav"
	elseif self.DamageType == "pure" then
		self.CastSound = "fx/spl/spl_destruction_cast.wav"
	elseif self.DamageType == "unlock" then
		self.CastSound = "fx/spl/spl_alteration_cast.wav"
	elseif self.DamageType == "conjure" then
		self.CastSound = "fx/spl/spl_conjuration_cast.wav"
	elseif self.DamageType == "armor" then
		self.CastSound = "fx/spl/spl_alteration_cast.wav"
	else end
	
	self.SoundRand = math.Rand(-5,5)
	self:EmitSound(self.CastSound, 500, 100 + self.SoundRand )
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()

end



