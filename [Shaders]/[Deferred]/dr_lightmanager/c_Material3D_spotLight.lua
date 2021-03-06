-- 
-- file: c_material3D_spotLight.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/material3D_spotLight.fx, fx/material3D_spotLight_LOD.fx, c_common.lua

CMatLightSpot = { }
CMatLightSpot.__index = CMatLightSpot
 
-- worldPosition Vector3() , attenuation Vector1(0-n), color Vector4(0-255,0-255,0-255,0-255) 
function CMatLightSpot: create(pos, atten, col )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shaderLOD = DxShader( "fx/material3D_spotLight_LOD.fx" ),
		shader = DxShader( "fx/material3D_spotLight.fx" ),
		color = tocolor(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		attenuation = atten,
		attenuationPower = 1,
		theta = 0.1,
		phi = 0.6,
		falloff = 1,
		direction = Vector3(0, 0, -1),
		tickCount = 0,
		LODSwitch = false,
		distFade = Vector2(450, 400)
	}

	if cShader.shader and cShader.shaderLOD then
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		cShader.shader:setValue( "sLightDir", cShader.direction.x, cShader.direction.y, cShader.direction.z )
		cShader.shader:setValue( "sLightPhi", cShader.phi )
		cShader.shader:setValue( "sLightTheta", cShader.theta )
		cShader.shader:setValue( "sLightFalloff", cShader.falloff )
		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		
		cShader.shaderLOD:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shaderLOD:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shaderLOD:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		cShader.shaderLOD:setValue( "sLightDir", cShader.direction.x, cShader.direction.y, cShader.direction.z )
		cShader.shaderLOD:setValue( "sLightPhi", cShader.phi )
		cShader.shaderLOD:setValue( "sLightTheta", cShader.theta )
		cShader.shaderLOD:setValue( "sLightFalloff", cShader.falloff )
		cShader.shaderLOD:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		cShader.shaderLOD:setValue( "sPixelSize", 1 / scX, 1 / scY )
		
		if isSm3MrtDBSupported then
			local distFromCam = ( pos - getCamera().matrix.position ).length
			if ( distFromCam < atten * 12 ) then 	
				cShader.LODSwitch = true
			else
				cShader.LODSwitch = false
			end
			if renderTarget.isOn then
				cShader.shader:setValue( "ColorRT", renderTarget.RTColor )
				cShader.shader:setValue( "NormalRT", renderTarget.RTNormal )
				cShader.shaderLOD:setValue( "ColorRT", renderTarget.RTColor )
				cShader.shaderLOD:setValue( "NormalRT", renderTarget.RTNormal )
			end
		end			

		self.__index = self
		setmetatable( cShader, self )
		return cShader
	else
		return false
	end
end

function CMatLightSpot: setLODByDistance()
	if self.shader and self.shaderLOD and isSm3MrtDBSupported then
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < self.attenuation * 12 ) then 
			if not self.LODSwitch then
				self.LODSwitch = true
			end
		else
			if self.LODSwitch then
				self.LODSwitch = false
			end
		end		
	end
end

function CMatLightSpot: setTheta( thetaVal )
	if self.shader and self.shaderLOD then
		self.theta = thetaVal
		self.shader:setValue( "sLightTheta", thetaVal )
		self.shaderLOD:setValue( "sLightTheta", thetaVal )
	end
end

function CMatLightSpot: setPhi( phiVal )
	if self.shader and self.shaderLOD then
		self.phi = phiVal 
		self.shader:setValue( "sLightPhi", phiVal )
		self.shaderLOD:setValue( "sLightPhi", phiVal )
	end
end

function CMatLightSpot: setFalloff( falloff )
	if self.shader and self.shaderLOD then
		self.falloff = falloff 
		self.shader:setValue( "sLightFalloff", falloff )
		self.shaderLOD:setValue( "sLightFalloff", falloff )
	end
end

function CMatLightSpot: setDirection( dir )
	if self.shader and self.shaderLOD then
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
		self.shaderLOD:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	
	
function CMatLightSpot: setRotation( rotDeg )
	if self.shader and self.shaderLOD then
		local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
		local dir = Vector3(-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x))
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
		self.shaderLOD:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	

function CMatLightSpot: setDistFade( distFade )
	if self.shader and self.shaderLOD then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
		self.shaderLOD:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CMatLightSpot: setPosition( pos )
	if self.shader and self.shaderLOD then
		self.position = Vector3(pos.x, pos.y, pos.z)
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
		self.shaderLOD:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end


function CMatLightSpot: setAttenuation( atten )
	if self.shader and self.shaderLOD then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self.shaderLOD:setValue( "sLightAttenuation", atten )
	end
end

function CMatLightSpot: setAttenuationPower( attenPow )
	if self.shader and self.shaderLOD then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
		self.shaderLOD:setValue( "sLightAttenuationPower", attenPow )		
	end
end

function CMatLightSpot: setColor( col )
	if self.shader and self.shaderLOD then
		self.color = tocolor(col.x, col.y, col.z, col.w)
	end
end

function CMatLightSpot: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CMatLightSpot: getDistanceFromViewAngle( inAngle )
	if self.shader and self.shaderLOD then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CMatLightSpot: draw()
	if self.shader and self.shaderLOD then
		local clipDist = math.min( self.distFade.x, getFarClipDistance() + self.attenuation )
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		
		if ( distFromCam < clipDist ) then	
			self.tickCount = self.tickCount + lastFrameTickCount + math.random(500)
			if self.tickCount > LODSwitchDelta then            
				self:setLODByDistance()
				self.tickCount = 0
			end
			local thisShader
			if self.LODSwitch then
				-- draw the outcome
				-- x
				dxDrawMaterialLine3D( 0.5 + self.position.x, 0 + self.position.y, self.position.z + 0.5, 0.5 + self.position.x, 0 + self.position.y, 
					self.position.z - 0.5, self.shaderLOD, 1, self.color, - 1 + self.position.x, 0 +  self.position.y,0 + self.position.z )
				dxDrawMaterialLine3D( - 0.5 + self.position.x, 0 + self.position.y, self.position.z + 0.5, - 0.5 + self.position.x, 0 + self.position.y, 
					self.position.z - 0.5, self.shaderLOD, 1, self.color,  1 + self.position.x, 0 +  self.position.y, 0 + self.position.z )
				-- y
				dxDrawMaterialLine3D( 0 + self.position.x, 0.5 + self.position.y, self.position.z + 0.5, 0 + self.position.x, 0.5 + self.position.y, 
					self.position.z - 0.5, self.shaderLOD, 1, self.color, 0 + self.position.x, - 1 +  self.position.y, 0 + self.position.z )
				dxDrawMaterialLine3D( 0 + self.position.x, - 0.5 + self.position.y, self.position.z + 0.5, 0 + self.position.x,  - 0.5 + self.position.y, 
					self.position.z - 0.5, self.shaderLOD, 1, self.color, 0 + self.position.x,  1 +  self.position.y, 0 + self.position.z )
				-- z
				dxDrawMaterialLine3D( 0 + self.position.x, - 0.5 + self.position.y, self.position.z - 0.5, 0 + self.position.x, 0.5 + self.position.y, 
					self.position.z - 0.5, self.shaderLOD, 1, self.color, 0 + self.position.x, 0 +  self.position.y, 1 + self.position.z )
				dxDrawMaterialLine3D( 0 + self.position.x, - 0.5 + self.position.y, self.position.z + 0.5, 0 + self.position.x, 0.5 + self.position.y, 
					self.position.z + 0.5, self.shaderLOD, 1, self.color, 0 + self.position.x, 0 +  self.position.y, - 1 + self.position.z )
			else
				-- draw the outcome
				dxDrawMaterialLine3D( 0 + self.position.x, 0 + self.position.y, self.position.z + 0.5, 0 + self.position.x, 0 + self.position.y, 
					self.position.z - 0.5, self.shader, 1, self.color, 0 + self.position.x,1 +  self.position.y,0 + self.position.z )
			end
		end
	end
end
        
function CMatLightSpot: destroy()
	if self.shader then
		self.shader:destroy()
	end
	if self.shaderLOD then
		self.shaderLOD:destroy()
	end
	self = nil
end
